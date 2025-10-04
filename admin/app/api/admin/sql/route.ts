import { NextRequest, NextResponse } from "next/server"
import { auth } from "@/auth"

export async function POST(request: NextRequest) {
  try {
    // Check authentication
    const session = await auth()
    if (!session?.user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      )
    }

    const { query } = await request.json()

    if (!query || typeof query !== "string") {
      return NextResponse.json(
        { error: "Invalid query" },
        { status: 400 }
      )
    }

    // Security: Only allow SELECT queries for safety
    const trimmedQuery = query.trim().toLowerCase()
    if (!trimmedQuery.startsWith("select")) {
      return NextResponse.json(
        { error: "Only SELECT queries are allowed for security reasons" },
        { status: 403 }
      )
    }

    // Execute query against backend
    const backendUrl = process.env.BACKEND_URL || "http://localhost:8000"
    const response = await fetch(`${backendUrl}/api/v1/admin/sql`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        // TODO: Add authentication header when backend supports it
      },
      body: JSON.stringify({ query }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ error: "Query execution failed" }))
      return NextResponse.json(
        { error: errorData.error || errorData.detail || "Query execution failed" },
        { status: response.status }
      )
    }

    const data = await response.json()

    return NextResponse.json({
      columns: data.columns || [],
      rows: data.rows || [],
      rowCount: data.row_count || data.rows?.length || 0,
    })

  } catch (error) {
    console.error("SQL query error:", error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Internal server error" },
      { status: 500 }
    )
  }
}
