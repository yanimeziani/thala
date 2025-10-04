"use client"

import { useState, useEffect } from "react"
import Editor from "@monaco-editor/react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Database, Play, Clock, TrendingUp, FileJson, FileText, ChartBar } from "lucide-react"
import { parse } from "papaparse"
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts"

interface QueryResult {
  columns: string[]
  rows: Record<string, unknown>[]
  rowCount: number
  executionTime: number
}

interface QueryHistory {
  id: string
  query: string
  timestamp: Date
  executionTime: number
  rowCount: number
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8', '#82CA9D']

export default function SQLEditorPage() {
  const [query, setQuery] = useState("-- Write your SQL query here\nSELECT * FROM users LIMIT 10;")
  const [result, setResult] = useState<QueryResult | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [history, setHistory] = useState<QueryHistory[]>([])
  const [showHistory, setShowHistory] = useState(false)
  const [visualizationType, setVisualizationType] = useState<"table" | "bar" | "line" | "pie">("table")

  // Load history from localStorage
  useEffect(() => {
    const savedHistory = localStorage.getItem("sql_query_history")
    if (savedHistory) {
      setHistory(JSON.parse(savedHistory).map((h: QueryHistory & { timestamp: string }) => ({
        ...h,
        timestamp: new Date(h.timestamp)
      })))
    }
  }, [])

  // Save history to localStorage
  const saveHistory = (newHistory: QueryHistory[]) => {
    localStorage.setItem("sql_query_history", JSON.stringify(newHistory))
    setHistory(newHistory)
  }

  const executeQuery = async () => {
    setLoading(true)
    setError(null)
    setResult(null)

    const startTime = performance.now()

    try {
      const response = await fetch("/api/admin/sql", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ query }),
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || "Query execution failed")
      }

      const data = await response.json()
      const executionTime = performance.now() - startTime

      setResult({
        ...data,
        executionTime,
      })

      // Add to history
      const newHistoryItem: QueryHistory = {
        id: Date.now().toString(),
        query,
        timestamp: new Date(),
        executionTime,
        rowCount: data.rowCount,
      }
      const newHistory = [newHistoryItem, ...history].slice(0, 50) // Keep last 50
      saveHistory(newHistory)

    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred")
    } finally {
      setLoading(false)
    }
  }

  const exportToCSV = () => {
    if (!result) return

    const csv = parse.unparse({
      fields: result.columns,
      data: result.rows
    })

    const blob = new Blob([csv], { type: "text/csv" })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `query_result_${Date.now()}.csv`
    a.click()
    window.URL.revokeObjectURL(url)
  }

  const exportToJSON = () => {
    if (!result) return

    const json = JSON.stringify(result.rows, null, 2)
    const blob = new Blob([json], { type: "application/json" })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `query_result_${Date.now()}.json`
    a.click()
    window.URL.revokeObjectURL(url)
  }

  const loadHistoryQuery = (historyQuery: string) => {
    setQuery(historyQuery)
    setShowHistory(false)
  }

  const clearHistory = () => {
    saveHistory([])
  }

  const prepareChartData = () => {
    if (!result || result.rows.length === 0) return []

    // Try to find numeric columns for visualization
    const numericColumns = result.columns.filter((col) => {
      const firstValue = result.rows[0][col]
      return typeof firstValue === "number"
    })

    if (numericColumns.length === 0) return []

    // Use first column as label, first numeric column as value
    const labelColumn = result.columns[0]
    const valueColumn = numericColumns[0]

    return result.rows.slice(0, 20).map((row) => ({
      name: String(row[labelColumn]),
      value: Number(row[valueColumn]) || 0,
    }))
  }

  const chartData = prepareChartData()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">SQL Editor</h2>
          <p className="text-muted-foreground">
            Execute SQL queries and visualize results
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowHistory(!showHistory)}
          >
            <Clock className="mr-2 h-4 w-4" />
            History ({history.length})
          </Button>
        </div>
      </div>

      {showHistory && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Query History</CardTitle>
              <CardDescription>Recent SQL queries</CardDescription>
            </div>
            <Button variant="outline" size="sm" onClick={clearHistory}>
              Clear History
            </Button>
          </CardHeader>
          <CardContent>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {history.length === 0 ? (
                <p className="text-sm text-muted-foreground">No query history</p>
              ) : (
                history.map((h) => (
                  <button
                    key={h.id}
                    onClick={() => loadHistoryQuery(h.query)}
                    className="w-full text-left p-3 rounded-lg border hover:bg-accent transition-colors"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <code className="text-xs font-mono flex-1 truncate">
                        {h.query.split("\n")[0]}
                      </code>
                      <div className="flex flex-col items-end text-xs text-muted-foreground">
                        <span>{h.timestamp.toLocaleTimeString()}</span>
                        <span>{h.rowCount} rows • {h.executionTime.toFixed(0)}ms</span>
                      </div>
                    </div>
                  </button>
                ))
              )}
            </div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Database className="h-5 w-5" />
            Query Editor
          </CardTitle>
          <CardDescription>
            Write and execute SQL queries against the database
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="border rounded-lg overflow-hidden">
            <Editor
              height="300px"
              defaultLanguage="sql"
              value={query}
              onChange={(value) => setQuery(value || "")}
              theme="vs-dark"
              options={{
                minimap: { enabled: false },
                fontSize: 14,
                lineNumbers: "on",
                scrollBeyondLastLine: false,
                automaticLayout: true,
              }}
            />
          </div>

          <div className="flex gap-2">
            <Button onClick={executeQuery} disabled={loading}>
              <Play className="mr-2 h-4 w-4" />
              {loading ? "Executing..." : "Execute Query"}
            </Button>
          </div>
        </CardContent>
      </Card>

      {error && (
        <Card className="border-destructive">
          <CardHeader>
            <CardTitle className="text-destructive">Error</CardTitle>
          </CardHeader>
          <CardContent>
            <code className="text-sm text-destructive">{error}</code>
          </CardContent>
        </Card>
      )}

      {result && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUp className="h-5 w-5" />
                  Query Results
                </CardTitle>
                <CardDescription>
                  {result.rowCount} row{result.rowCount !== 1 ? "s" : ""} • Executed in {result.executionTime.toFixed(2)}ms
                </CardDescription>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={() => setVisualizationType("table")}>
                  Table
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setVisualizationType("bar")}
                  disabled={chartData.length === 0}
                >
                  <ChartBar className="mr-2 h-4 w-4" />
                  Bar
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setVisualizationType("line")}
                  disabled={chartData.length === 0}
                >
                  Line
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setVisualizationType("pie")}
                  disabled={chartData.length === 0}
                >
                  Pie
                </Button>
                <Button variant="outline" size="sm" onClick={exportToCSV}>
                  <FileText className="mr-2 h-4 w-4" />
                  CSV
                </Button>
                <Button variant="outline" size="sm" onClick={exportToJSON}>
                  <FileJson className="mr-2 h-4 w-4" />
                  JSON
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {visualizationType === "table" && (
              <div className="border rounded-lg overflow-auto max-h-96">
                <table className="w-full text-sm">
                  <thead className="bg-muted sticky top-0">
                    <tr>
                      {result.columns.map((col) => (
                        <th key={col} className="px-4 py-2 text-left font-medium">
                          {col}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {result.rows.map((row, idx) => (
                      <tr key={idx} className="border-t hover:bg-muted/50">
                        {result.columns.map((col) => (
                          <td key={col} className="px-4 py-2">
                            {typeof row[col] === "object"
                              ? JSON.stringify(row[col])
                              : String(row[col] ?? "")}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {visualizationType === "bar" && chartData.length > 0 && (
              <ResponsiveContainer width="100%" height={400}>
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="value" fill="#8884d8" />
                </BarChart>
              </ResponsiveContainer>
            )}

            {visualizationType === "line" && chartData.length > 0 && (
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="value" stroke="#8884d8" />
                </LineChart>
              </ResponsiveContainer>
            )}

            {visualizationType === "pie" && chartData.length > 0 && (
              <ResponsiveContainer width="100%" height={400}>
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                    outerRadius={120}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {chartData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}
