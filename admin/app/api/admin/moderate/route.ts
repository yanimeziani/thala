import { NextRequest, NextResponse } from "next/server"
import { withAuth } from "@/lib/auth-utils"
import { AdminPermission, hasPermission } from "@/lib/admin-config"
import { logAuditAction, AuditAction } from "@/lib/audit-log"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "https://backend.thala.app/api/v1"

export async function POST(request: NextRequest) {
  return withAuth(async (session) => {
    const body = await request.json()
    const { action, resourceType, resourceId, reason } = body

    // Check permissions based on resource type
    let requiredPermission: AdminPermission | null = null
    let auditAction: AuditAction | null = null

    switch (resourceType) {
      case "video":
        requiredPermission = AdminPermission.DELETE_VIDEOS
        auditAction = AuditAction.VIDEO_DELETE
        break
      case "message":
        requiredPermission = AdminPermission.DELETE_MESSAGES
        auditAction = AuditAction.MESSAGE_DELETE
        break
      case "user":
        requiredPermission = AdminPermission.DELETE_USERS
        auditAction = AuditAction.USER_DELETE
        break
      default:
        return NextResponse.json(
          { error: "Invalid resource type" },
          { status: 400 }
        )
    }

    if (!hasPermission(session.user.email, requiredPermission)) {
      return NextResponse.json(
        { error: "Insufficient permissions" },
        { status: 403 }
      )
    }

    try {
      let response

      switch (action) {
        case "delete":
          response = await fetch(`${API_BASE_URL}/${resourceType}s/${resourceId}`, {
            method: "DELETE",
          })
          break

        case "flag":
          // TODO: Implement flagging/suspension logic
          response = await fetch(`${API_BASE_URL}/${resourceType}s/${resourceId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ flagged: true, flag_reason: reason }),
          })
          break

        default:
          return NextResponse.json(
            { error: "Invalid action" },
            { status: 400 }
          )
      }

      if (!response.ok) {
        throw new Error(`Moderation action failed: ${response.status}`)
      }

      // Log the moderation action
      if (auditAction) {
        logAuditAction({
          action: auditAction,
          adminEmail: session.user.email,
          adminName: session.user.name || undefined,
          resourceType,
          resourceId,
          details: { moderationAction: action, reason },
        })
      }

      return NextResponse.json({
        success: true,
        message: `${resourceType} ${action}d successfully`,
      })
    } catch (error) {
      console.error("Moderation error:", error)
      return NextResponse.json(
        { error: error instanceof Error ? error.message : "Moderation failed" },
        { status: 500 }
      )
    }
  })
}
