import { NextResponse } from "next/server"
import { auth } from "@/auth"

export async function GET() {
  try {
    // Check authentication
    const session = await auth()
    if (!session?.user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      )
    }

    // Fetch stats from backend
    const backendUrl = process.env.BACKEND_URL || "http://localhost:8000"
    const response = await fetch(`${backendUrl}/api/v1/admin/stats`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
      cache: 'no-store'
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ error: "Failed to fetch stats" }))
      return NextResponse.json(
        { error: errorData.error || "Failed to fetch stats" },
        { status: response.status }
      )
    }

    const data = await response.json()

    return NextResponse.json({
      totalUsers: data.total_users || 0,
      totalEvents: data.total_events || 0,
      totalVideos: data.total_videos || 0,
      totalArchiveEntries: data.total_archive_entries || 0,
      totalMessages: data.total_messages || 0,
      totalCommunities: data.total_communities || 0,
      totalLikes: data.total_likes || 0,
      totalComments: data.total_comments || 0,
      totalShares: data.total_shares || 0,
    })

  } catch (error) {
    console.error("Stats fetch error:", error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Internal server error" },
      { status: 500 }
    )
  }
}
