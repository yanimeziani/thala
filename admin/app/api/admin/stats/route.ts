import { NextResponse } from "next/server"
import { withAuth } from "@/lib/auth-utils"
import { AdminPermission, hasPermission } from "@/lib/admin-config"
import { logAuditAction, AuditAction } from "@/lib/audit-log"

/**
 * GET /api/admin/stats
 * Get dashboard statistics
 * Protected route - requires authentication
 */
export async function GET() {
  return withAuth(async (session) => {
    // Check permission
    if (!hasPermission(session.user.email, AdminPermission.VIEW_SETTINGS)) {
      return NextResponse.json(
        { error: "Insufficient permissions" },
        { status: 403 }
      )
    }

    // Log the action
    logAuditAction({
      action: AuditAction.USER_VIEW,
      adminEmail: session.user.email,
      adminName: session.user.name || undefined,
      resourceType: "dashboard_stats",
      details: { timestamp: new Date().toISOString() },
    })

    // Fetch real stats from backend API
    const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "https://backend.thala.app/api/v1"

    try {
      const [users, events, videos, archive, communities] = await Promise.all([
        fetch(`${API_BASE_URL}/users`).then(r => r.ok ? r.json() : []),
        fetch(`${API_BASE_URL}/events`).then(r => r.ok ? r.json() : []),
        fetch(`${API_BASE_URL}/videos`).then(r => r.ok ? r.json() : []),
        fetch(`${API_BASE_URL}/archive`).then(r => r.ok ? r.json() : []),
        fetch(`${API_BASE_URL}/community`).then(r => r.ok ? r.json() : []),
      ])

      const stats = {
        totalUsers: Array.isArray(users) ? users.length : 0,
        totalEvents: Array.isArray(events) ? events.length : 0,
        totalVideos: Array.isArray(videos) ? videos.length : 0,
        totalArchiveEntries: Array.isArray(archive) ? archive.length : 0,
        totalMessages: 0, // TODO: Add messages endpoint
        totalCommunities: Array.isArray(communities) ? communities.length : 0,
        // Additional stats
        totalLikes: Array.isArray(videos) ? videos.reduce((sum: number, v: any) => sum + (v.likes || 0), 0) : 0,
        totalComments: Array.isArray(videos) ? videos.reduce((sum: number, v: any) => sum + (v.comments || 0), 0) : 0,
        totalShares: Array.isArray(videos) ? videos.reduce((sum: number, v: any) => sum + (v.shares || 0), 0) : 0,
      }

      return NextResponse.json(stats)
    } catch (error) {
      console.error('Error fetching stats:', error)
      // Return empty stats on error
      return NextResponse.json({
        totalUsers: 0,
        totalEvents: 0,
        totalVideos: 0,
        totalArchiveEntries: 0,
        totalMessages: 0,
        totalCommunities: 0,
        totalLikes: 0,
        totalComments: 0,
        totalShares: 0,
      })
    }
  })
}
