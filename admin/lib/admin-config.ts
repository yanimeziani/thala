/**
 * Admin user configuration and role-based access control
 */

export enum AdminRole {
  SUPER_ADMIN = "super_admin",
  ADMIN = "admin",
  MODERATOR = "moderator",
  VIEWER = "viewer",
}

export interface AdminUser {
  email: string;
  role: AdminRole;
  name: string;
  permissions: AdminPermission[];
}

export enum AdminPermission {
  // User management
  VIEW_USERS = "view_users",
  EDIT_USERS = "edit_users",
  DELETE_USERS = "delete_users",

  // Content management
  VIEW_VIDEOS = "view_videos",
  EDIT_VIDEOS = "edit_videos",
  DELETE_VIDEOS = "delete_videos",

  // Event management
  VIEW_EVENTS = "view_events",
  EDIT_EVENTS = "edit_events",
  DELETE_EVENTS = "delete_events",

  // Archive management
  VIEW_ARCHIVE = "view_archive",
  EDIT_ARCHIVE = "edit_archive",
  DELETE_ARCHIVE = "delete_archive",

  // Music management
  VIEW_MUSIC = "view_music",
  EDIT_MUSIC = "edit_music",
  DELETE_MUSIC = "delete_music",

  // Community management
  VIEW_COMMUNITIES = "view_communities",
  EDIT_COMMUNITIES = "edit_communities",
  DELETE_COMMUNITIES = "delete_communities",

  // Message management
  VIEW_MESSAGES = "view_messages",
  DELETE_MESSAGES = "delete_messages",

  // Settings
  VIEW_SETTINGS = "view_settings",
  EDIT_SETTINGS = "edit_settings",

  // System
  VIEW_AUDIT_LOGS = "view_audit_logs",
  MANAGE_ADMINS = "manage_admins",
}

// Define permissions for each role
const ROLE_PERMISSIONS: Record<AdminRole, AdminPermission[]> = {
  [AdminRole.SUPER_ADMIN]: Object.values(AdminPermission),

  [AdminRole.ADMIN]: [
    AdminPermission.VIEW_USERS,
    AdminPermission.EDIT_USERS,
    AdminPermission.VIEW_VIDEOS,
    AdminPermission.EDIT_VIDEOS,
    AdminPermission.DELETE_VIDEOS,
    AdminPermission.VIEW_EVENTS,
    AdminPermission.EDIT_EVENTS,
    AdminPermission.DELETE_EVENTS,
    AdminPermission.VIEW_ARCHIVE,
    AdminPermission.EDIT_ARCHIVE,
    AdminPermission.DELETE_ARCHIVE,
    AdminPermission.VIEW_MUSIC,
    AdminPermission.EDIT_MUSIC,
    AdminPermission.DELETE_MUSIC,
    AdminPermission.VIEW_COMMUNITIES,
    AdminPermission.EDIT_COMMUNITIES,
    AdminPermission.VIEW_MESSAGES,
    AdminPermission.DELETE_MESSAGES,
    AdminPermission.VIEW_SETTINGS,
  ],

  [AdminRole.MODERATOR]: [
    AdminPermission.VIEW_USERS,
    AdminPermission.VIEW_VIDEOS,
    AdminPermission.EDIT_VIDEOS,
    AdminPermission.DELETE_VIDEOS,
    AdminPermission.VIEW_EVENTS,
    AdminPermission.EDIT_EVENTS,
    AdminPermission.VIEW_COMMUNITIES,
    AdminPermission.EDIT_COMMUNITIES,
    AdminPermission.VIEW_MESSAGES,
    AdminPermission.DELETE_MESSAGES,
  ],

  [AdminRole.VIEWER]: [
    AdminPermission.VIEW_USERS,
    AdminPermission.VIEW_VIDEOS,
    AdminPermission.VIEW_EVENTS,
    AdminPermission.VIEW_ARCHIVE,
    AdminPermission.VIEW_MUSIC,
    AdminPermission.VIEW_COMMUNITIES,
    AdminPermission.VIEW_MESSAGES,
  ],
};

/**
 * Authorized admin users
 * In production, this should be stored in a database
 */
export const ADMIN_USERS: AdminUser[] = [
  {
    email: "mezianiyani0@gmail.com",
    name: "Yani Meziani",
    role: AdminRole.SUPER_ADMIN,
    permissions: ROLE_PERMISSIONS[AdminRole.SUPER_ADMIN],
  },
  // Add more admin users here as needed
  // {
  //   email: "another@example.com",
  //   name: "Another Admin",
  //   role: AdminRole.ADMIN,
  //   permissions: ROLE_PERMISSIONS[AdminRole.ADMIN],
  // },
];

/**
 * Check if an email is authorized as an admin
 */
export function isAuthorizedAdmin(email: string | null | undefined): boolean {
  if (!email) return false;
  return ADMIN_USERS.some((admin) => admin.email === email);
}

/**
 * Get admin user by email
 */
export function getAdminUser(email: string | null | undefined): AdminUser | null {
  if (!email) return null;
  return ADMIN_USERS.find((admin) => admin.email === email) || null;
}

/**
 * Check if user has a specific permission
 */
export function hasPermission(
  email: string | null | undefined,
  permission: AdminPermission
): boolean {
  const admin = getAdminUser(email);
  if (!admin) return false;
  return admin.permissions.includes(permission);
}

/**
 * Check if user has any of the specified permissions
 */
export function hasAnyPermission(
  email: string | null | undefined,
  permissions: AdminPermission[]
): boolean {
  const admin = getAdminUser(email);
  if (!admin) return false;
  return permissions.some((permission) => admin.permissions.includes(permission));
}

/**
 * Check if user has all of the specified permissions
 */
export function hasAllPermissions(
  email: string | null | undefined,
  permissions: AdminPermission[]
): boolean {
  const admin = getAdminUser(email);
  if (!admin) return false;
  return permissions.every((permission) => admin.permissions.includes(permission));
}

/**
 * Check if user has a specific role or higher
 */
export function hasRole(
  email: string | null | undefined,
  role: AdminRole
): boolean {
  const admin = getAdminUser(email);
  if (!admin) return false;

  const roleHierarchy = [
    AdminRole.VIEWER,
    AdminRole.MODERATOR,
    AdminRole.ADMIN,
    AdminRole.SUPER_ADMIN,
  ];

  const userRoleLevel = roleHierarchy.indexOf(admin.role);
  const requiredRoleLevel = roleHierarchy.indexOf(role);

  return userRoleLevel >= requiredRoleLevel;
}
