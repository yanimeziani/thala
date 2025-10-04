/**
 * Audit logging system for admin actions
 */

export enum AuditAction {
  // Auth
  LOGIN = "login",
  LOGOUT = "logout",
  UNAUTHORIZED_ACCESS = "unauthorized_access",

  // User actions
  USER_CREATE = "user_create",
  USER_UPDATE = "user_update",
  USER_DELETE = "user_delete",
  USER_VIEW = "user_view",

  // Video actions
  VIDEO_CREATE = "video_create",
  VIDEO_UPDATE = "video_update",
  VIDEO_DELETE = "video_delete",

  // Event actions
  EVENT_CREATE = "event_create",
  EVENT_UPDATE = "event_update",
  EVENT_DELETE = "event_delete",

  // Archive actions
  ARCHIVE_CREATE = "archive_create",
  ARCHIVE_UPDATE = "archive_update",
  ARCHIVE_DELETE = "archive_delete",

  // Music actions
  MUSIC_CREATE = "music_create",
  MUSIC_UPDATE = "music_update",
  MUSIC_DELETE = "music_delete",

  // Community actions
  COMMUNITY_CREATE = "community_create",
  COMMUNITY_UPDATE = "community_update",
  COMMUNITY_DELETE = "community_delete",

  // Message actions
  MESSAGE_VIEW = "message_view",
  MESSAGE_DELETE = "message_delete",

  // Settings
  SETTINGS_UPDATE = "settings_update",
}

export interface AuditLogEntry {
  timestamp: Date
  action: AuditAction
  adminEmail: string
  adminName?: string
  resourceType?: string
  resourceId?: string
  details?: Record<string, string | number | boolean | null>
  ipAddress?: string
  userAgent?: string
}

/**
 * In-memory audit log (in production, store in database)
 */
const auditLogs: AuditLogEntry[] = []

/**
 * Log an admin action
 */
export function logAuditAction(entry: Omit<AuditLogEntry, "timestamp">): void {
  const logEntry: AuditLogEntry = {
    ...entry,
    timestamp: new Date(),
  }

  auditLogs.push(logEntry)

  // Log to console in development
  if (process.env.NODE_ENV === "development") {
    console.log(
      `[AUDIT] ${logEntry.adminEmail} performed ${logEntry.action}`,
      logEntry.details ? JSON.stringify(logEntry.details) : ""
    )
  }

  // In production, send to logging service (e.g., Sentry, DataDog, etc.)
  // or save to database
}

/**
 * Get recent audit logs (for admin viewing)
 */
export function getRecentAuditLogs(limit: number = 100): AuditLogEntry[] {
  return auditLogs.slice(-limit).reverse()
}

/**
 * Get audit logs for a specific admin
 */
export function getAuditLogsByAdmin(adminEmail: string, limit: number = 100): AuditLogEntry[] {
  return auditLogs
    .filter((log) => log.adminEmail === adminEmail)
    .slice(-limit)
    .reverse()
}

/**
 * Get audit logs for a specific action
 */
export function getAuditLogsByAction(action: AuditAction, limit: number = 100): AuditLogEntry[] {
  return auditLogs
    .filter((log) => log.action === action)
    .slice(-limit)
    .reverse()
}

/**
 * Get audit logs for a specific resource
 */
export function getAuditLogsByResource(
  resourceType: string,
  resourceId: string,
  limit: number = 100
): AuditLogEntry[] {
  return auditLogs
    .filter(
      (log) =>
        log.resourceType === resourceType && log.resourceId === resourceId
    )
    .slice(-limit)
    .reverse()
}
