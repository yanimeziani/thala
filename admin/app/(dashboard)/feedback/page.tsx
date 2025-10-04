"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Bug, Lightbulb, MessageCircle, Filter, CheckCircle2, Clock, XCircle, AlertTriangle } from "lucide-react"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

interface Feedback {
  id: string
  feedback_type: "bug" | "feature" | "general"
  title: string
  description: string
  user_email: string | null
  user_name: string | null
  platform: string | null
  app_version: string | null
  status: "new" | "reviewing" | "planned" | "in_progress" | "completed" | "wont_fix" | "duplicate"
  priority: string | null
  created_at: string
  is_public: boolean
}

const statusIcons: Record<string, any> = {
  new: Clock,
  reviewing: AlertTriangle,
  planned: CheckCircle2,
  in_progress: Clock,
  completed: CheckCircle2,
  wont_fix: XCircle,
  duplicate: XCircle,
}

const statusColors: Record<string, string> = {
  new: "text-blue-600",
  reviewing: "text-yellow-600",
  planned: "text-purple-600",
  in_progress: "text-orange-600",
  completed: "text-green-600",
  wont_fix: "text-gray-600",
  duplicate: "text-gray-600",
}

export default function FeedbackPage() {
  const [feedback, setFeedback] = useState<Feedback[]>([])
  const [loading, setLoading] = useState(true)
  const [typeFilter, setTypeFilter] = useState<string>("all")
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    loadFeedback()
  }, [])

  const loadFeedback = async () => {
    setLoading(true)
    try {
      const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000"
      const response = await fetch(`${backendUrl}/api/v1/feedback?limit=100`)

      if (response.ok) {
        const data = await response.json()
        setFeedback(data)
      }
    } catch (error) {
      console.error("Failed to load feedback:", error)
    } finally {
      setLoading(false)
    }
  }

  const updateFeedbackStatus = async (id: string, status: string, priority?: string) => {
    try {
      const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL || "http://localhost:8000"
      const response = await fetch(`${backendUrl}/api/v1/feedback/${id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ status, priority }),
      })

      if (response.ok) {
        loadFeedback()
      }
    } catch (error) {
      console.error("Failed to update feedback:", error)
    }
  }

  const filteredFeedback = feedback.filter((item) => {
    if (typeFilter !== "all" && item.feedback_type !== typeFilter) return false
    if (statusFilter !== "all" && item.status !== statusFilter) return false
    return true
  })

  const stats = {
    total: feedback.length,
    bugs: feedback.filter((f) => f.feedback_type === "bug").length,
    features: feedback.filter((f) => f.feedback_type === "feature").length,
    general: feedback.filter((f) => f.feedback_type === "general").length,
    new: feedback.filter((f) => f.status === "new").length,
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Feedback & Bug Reports</h2>
          <p className="text-muted-foreground">
            Manage user feedback, bug reports, and feature requests
          </p>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Feedback</CardTitle>
            <MessageCircle className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Bug Reports</CardTitle>
            <Bug className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.bugs}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Feature Requests</CardTitle>
            <Lightbulb className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.features}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">New (Unreviewed)</CardTitle>
            <Clock className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.new}</div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>All Feedback</CardTitle>
              <CardDescription>Filter and manage user feedback</CardDescription>
            </div>
            <div className="flex gap-2">
              <Select value={typeFilter} onValueChange={setTypeFilter}>
                <SelectTrigger className="w-[160px]">
                  <SelectValue placeholder="Type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Types</SelectItem>
                  <SelectItem value="bug">Bugs</SelectItem>
                  <SelectItem value="feature">Features</SelectItem>
                  <SelectItem value="general">General</SelectItem>
                </SelectContent>
              </Select>

              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[160px]">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  <SelectItem value="new">New</SelectItem>
                  <SelectItem value="reviewing">Reviewing</SelectItem>
                  <SelectItem value="planned">Planned</SelectItem>
                  <SelectItem value="in_progress">In Progress</SelectItem>
                  <SelectItem value="completed">Completed</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            </div>
          ) : filteredFeedback.length === 0 ? (
            <p className="text-center text-muted-foreground py-8">No feedback found</p>
          ) : (
            <div className="space-y-4">
              {filteredFeedback.map((item) => {
                const Icon = item.feedback_type === "bug" ? Bug : item.feedback_type === "feature" ? Lightbulb : MessageCircle
                const StatusIcon = statusIcons[item.status]

                return (
                  <div key={item.id} className="border rounded-lg p-4 space-y-3">
                    <div className="flex items-start justify-between">
                      <div className="flex items-start gap-3 flex-1">
                        <Icon className={`h-5 w-5 mt-0.5 ${
                          item.feedback_type === "bug" ? "text-red-600" :
                          item.feedback_type === "feature" ? "text-yellow-600" :
                          "text-blue-600"
                        }`} />
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <h4 className="font-medium">{item.title}</h4>
                            <span className={`text-xs px-2 py-0.5 rounded-full bg-opacity-10 ${statusColors[item.status]}`}>
                              {item.status.replace("_", " ")}
                            </span>
                            {item.priority && (
                              <span className="text-xs px-2 py-0.5 rounded-full bg-orange-100 text-orange-700">
                                {item.priority}
                              </span>
                            )}
                          </div>
                          <p className="text-sm text-muted-foreground mb-2">{item.description}</p>
                          <div className="flex items-center gap-4 text-xs text-muted-foreground">
                            {item.user_name && <span>From: {item.user_name}</span>}
                            {item.platform && <span>Platform: {item.platform}</span>}
                            {item.app_version && <span>v{item.app_version}</span>}
                            <span>{new Date(item.created_at).toLocaleDateString()}</span>
                          </div>
                        </div>
                      </div>
                      <div className="flex gap-1">
                        <Select
                          value={item.status}
                          onValueChange={(value) => updateFeedbackStatus(item.id, value, item.priority || undefined)}
                        >
                          <SelectTrigger className="w-[140px] h-8 text-xs">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="new">New</SelectItem>
                            <SelectItem value="reviewing">Reviewing</SelectItem>
                            <SelectItem value="planned">Planned</SelectItem>
                            <SelectItem value="in_progress">In Progress</SelectItem>
                            <SelectItem value="completed">Completed</SelectItem>
                            <SelectItem value="wont_fix">Won't Fix</SelectItem>
                            <SelectItem value="duplicate">Duplicate</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
