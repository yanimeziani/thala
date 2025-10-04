# Thala Admin Panel Setup Guide

## Overview

The Thala Admin Panel is a secure Next.js application for managing the Thala platform. It features Google OAuth authentication, role-based access control (RBAC), and audit logging.

## Features

✅ **Google OAuth Authentication** - Secure sign-in with Google
✅ **Role-Based Access Control** - Super Admin, Admin, Moderator, and Viewer roles
✅ **Permission System** - Granular permissions for different resources
✅ **Audit Logging** - Track all admin actions
✅ **Protected API Routes** - Middleware for securing endpoints
✅ **Modern UI** - Built with shadcn/ui and Tailwind CSS

## Prerequisites

- Node.js 20+ installed
- Google Cloud Project with OAuth 2.0 credentials
- Backend API running at `backend.thala.app`

## Installation

### 1. Install Dependencies

```bash
cd admin
npm install
```

### 2. Set Up Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Go to **Credentials** → **Create Credentials** → **OAuth Client ID**
5. Configure OAuth consent screen:
   - Application name: "Thala Admin"
   - Authorized domains: Your domain
6. Create OAuth 2.0 Client ID:
   - Application type: **Web application**
   - Authorized redirect URIs:
     - `http://localhost:3000/api/auth/callback/google` (development)
     - `https://admin.thala.app/api/auth/callback/google` (production)
7. Copy **Client ID** and **Client Secret**

### 3. Configure Environment Variables

Create `.env.local` file in the admin directory:

```bash
# Google OAuth Credentials
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# NextAuth Configuration
AUTH_SECRET=your_random_secret_here
AUTH_URL=http://localhost:3000

# Backend API URL
NEXT_PUBLIC_API_URL=https://backend.thala.app/api/v1
```

Generate `AUTH_SECRET` with:
```bash
openssl rand -base64 32
```

### 4. Configure Admin Users

Edit `lib/admin-config.ts` to add authorized admin users:

```typescript
export const ADMIN_USERS: AdminUser[] = [
  {
    email: "your-email@gmail.com",
    name: "Your Name",
    role: AdminRole.SUPER_ADMIN,
    permissions: ROLE_PERMISSIONS[AdminRole.SUPER_ADMIN],
  },
  {
    email: "moderator@example.com",
    name: "Moderator Name",
    role: AdminRole.MODERATOR,
    permissions: ROLE_PERMISSIONS[AdminRole.MODERATOR],
  },
]
```

## Admin Roles

### Super Admin
- Full access to everything
- Can manage other admins
- View audit logs
- All permissions

### Admin
- Manage users, content, events
- Cannot delete users
- Cannot manage other admins
- No audit log access

### Moderator
- View and moderate content
- Edit/delete videos and events
- Manage communities
- No user management

### Viewer
- Read-only access
- Can view all resources
- Cannot make any changes

## Permissions

Each role has specific permissions. See `lib/admin-config.ts` for the complete permission matrix.

Example permissions:
- `VIEW_USERS` - View user list
- `EDIT_USERS` - Modify user data
- `DELETE_VIDEOS` - Remove videos
- `MANAGE_ADMINS` - Add/remove admin users
- etc.

## Running the Application

### Development

```bash
npm run dev
```

Visit `http://localhost:3000`

### Production Build

```bash
npm run build
npm start
```

### Docker

```bash
docker-compose up -d
```

## Security Features

### 1. Email Allowlist
Only emails in `ADMIN_USERS` can sign in. Unauthorized attempts are logged.

### 2. Session Security
- JWT-based sessions
- 8-hour session timeout
- Secure httpOnly cookies

### 3. Permission Checks
All protected routes verify permissions before allowing access.

### 4. Audit Logging
All admin actions are logged with:
- Timestamp
- Admin email/name
- Action type
- Resource affected
- Additional details

### 5. HTTPS Only (Production)
Enforce HTTPS in production environments.

## API Routes Protection

Example of protecting an API route:

```typescript
import { withPermission } from "@/lib/auth-utils"
import { AdminPermission } from "@/lib/admin-config"

export async function POST(req: Request) {
  return withPermission(AdminPermission.EDIT_VIDEOS, async (session) => {
    // Your protected code here
    return NextResponse.json({ success: true })
  })
}
```

## Adding New Admin Users

1. Open `lib/admin-config.ts`
2. Add new entry to `ADMIN_USERS` array
3. Restart the application
4. New admin can now sign in with Google

## Troubleshooting

### "Unauthorized" after signing in
- Check that your email is in `ADMIN_USERS` array
- Verify `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are correct
- Check console logs for error messages

### "Invalid callback URL"
- Ensure redirect URIs in Google Console match exactly
- Include `/api/auth/callback/google` path
- Check for http vs https mismatch

### Session expires too quickly
- Adjust `maxAge` in `auth.ts` (currently 8 hours)

### TypeScript errors
- Run `npm run lint` to check
- Ensure all dependencies are installed

## Production Deployment

### Environment Variables (Production)

```bash
GOOGLE_CLIENT_ID=<production-client-id>
GOOGLE_CLIENT_SECRET=<production-client-secret>
AUTH_SECRET=<strong-random-secret>
AUTH_URL=https://admin.thala.app
NEXT_PUBLIC_API_URL=https://backend.thala.app/api/v1
NODE_ENV=production
```

### Security Checklist

- [ ] Strong `AUTH_SECRET` generated
- [ ] HTTPS enforced
- [ ] Google OAuth redirect URIs updated
- [ ] Admin users list reviewed
- [ ] Rate limiting enabled (via reverse proxy)
- [ ] Audit logs monitored
- [ ] Regular security updates

## Support

For issues or questions, contact the development team.

## License

Proprietary - Thala Platform
