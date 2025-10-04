import { NextResponse } from "next/server"
import { withAuth } from "@/lib/auth-utils"
import { getAdminUser } from "@/lib/admin-config"

/**
 * GET /api/admin/me
 * Get current admin user info
 * Protected route - requires authentication
 */
export async function GET() {
  return withAuth(async (session) => {
    const adminUser = getAdminUser(session.user.email!)

    if (!adminUser) {
      return NextResponse.json(
        { error: "Admin user not found" },
        { status: 404 }
      )
    }

    return NextResponse.json({
      email: adminUser.email,
      name: adminUser.name,
      role: adminUser.role,
      permissions: adminUser.permissions,
    })
  })
}
