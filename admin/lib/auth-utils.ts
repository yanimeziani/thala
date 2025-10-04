import { auth } from "@/auth"
import { NextResponse } from "next/server"
import { hasPermission, type AdminPermission } from "./admin-config"

/**
 * Require authentication for server actions or API routes
 */
export async function requireAuth() {
  const session = await auth()
  if (!session?.user?.email) {
    throw new Error("Unauthorized")
  }
  return session
}

/**
 * Require specific permission for server actions or API routes
 */
export async function requirePermission(permission: AdminPermission) {
  const session = await requireAuth()
  if (!hasPermission(session.user.email, permission)) {
    throw new Error("Forbidden: Insufficient permissions")
  }
  return session
}

/**
 * Middleware helper to protect API routes
 */
export async function withAuth<T>(
  handler: (session: NonNullable<Awaited<ReturnType<typeof auth>>>) => Promise<T>
): Promise<T | NextResponse> {
  try {
    const session = await auth()
    if (!session?.user?.email) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }
    return await handler(session)
  } catch (error) {
    console.error("Auth error:", error)
    return NextResponse.json(
      { error: "Authentication failed" },
      { status: 401 }
    )
  }
}

/**
 * Middleware helper to protect API routes with permission check
 */
export async function withPermission<T>(
  permission: AdminPermission,
  handler: (session: NonNullable<Awaited<ReturnType<typeof auth>>>) => Promise<T>
): Promise<T | NextResponse> {
  try {
    const session = await auth()
    if (!session?.user?.email) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    if (!hasPermission(session.user.email, permission)) {
      return NextResponse.json(
        { error: "Forbidden: Insufficient permissions" },
        { status: 403 }
      )
    }

    return await handler(session)
  } catch (error) {
    console.error("Permission check error:", error)
    return NextResponse.json(
      { error: "Authorization failed" },
      { status: 403 }
    )
  }
}

/**
 * Get current admin user from session
 */
export async function getCurrentAdmin() {
  const session = await auth()
  return session?.user || null
}
