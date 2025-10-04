# Thala Admin Dashboard

Modern admin interface for the Thala cultural platform, built with Next.js 15 and shadcn/ui.

## Features

- 🔐 **Secure Authentication**: Google OAuth with email restriction (only `mezianiyani0@gmail.com`)
- 🎨 **Modern UI**: Built with shadcn/ui components and Tailwind CSS
- 📊 **Dashboard**: Overview of platform statistics
- 👥 **User Management**: View and manage registered users
- 📅 **Events**: Create and manage cultural events
- 🎥 **Videos**: Manage video content library
- 🎵 **Music**: Manage music tracks
- 📚 **Archive**: Cultural heritage archive management
- 🌍 **Community**: Community profiles and host requests
- 📝 **Content Profiles**: Content categorization and cultural profiling

## Tech Stack

- **Framework**: Next.js 15 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS v4
- **UI Components**: shadcn/ui
- **Authentication**: NextAuth.js v5 (with Google OAuth)
- **Icons**: Lucide React

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Google OAuth credentials
- Access to Thala backend API

### Installation

1. Install dependencies:

```bash
npm install
```

2. Set up environment variables:

```bash
cp .env.example .env.local
```

Edit `.env.local` and add your credentials:

```env
# Google OAuth Credentials
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# NextAuth Configuration
AUTH_SECRET=your_random_secret_here # Generate with: openssl rand -base64 32
AUTH_URL=http://localhost:3000

# Backend API URL
NEXT_PUBLIC_API_URL=https://backend.thala.app/api/v1
```

### Development

Run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

Build for production:

```bash
npm run build
```

### Start Production Server

```bash
npm start
```

## Docker Deployment

### Build Docker Image

```bash
docker build -t thala-admin .
```

### Run with Docker

```bash
docker run -p 3000:3000 \
  -e GOOGLE_CLIENT_ID=your_client_id \
  -e GOOGLE_CLIENT_SECRET=your_client_secret \
  -e AUTH_SECRET=your_secret \
  -e AUTH_URL=https://admin.thala.app \
  -e NEXT_PUBLIC_API_URL=https://backend.thala.app/api/v1 \
  thala-admin
```

### Using Docker Compose

1. Create a `.env` file with your credentials:

```env
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
AUTH_SECRET=your_auth_secret
AUTH_URL=https://admin.thala.app
NEXT_PUBLIC_API_URL=https://backend.thala.app/api/v1
```

2. Run with docker-compose:

```bash
docker-compose up -d
```

## Project Structure

```
admin/
├── app/
│   ├── (dashboard)/          # Protected dashboard routes
│   │   ├── layout.tsx        # Dashboard layout with sidebar
│   │   ├── page.tsx          # Dashboard home
│   │   ├── users/            # User management
│   │   ├── events/           # Events management
│   │   ├── videos/           # Videos management
│   │   ├── music/            # Music tracks
│   │   ├── archive/          # Archive entries
│   │   ├── community/        # Community profiles
│   │   ├── content-profiles/ # Content categorization
│   │   ├── messages/         # Messages
│   │   └── settings/         # Settings
│   ├── auth/                 # Authentication pages
│   │   ├── signin/           # Sign in page
│   │   └── error/            # Auth error page
│   ├── api/
│   │   └── auth/             # NextAuth API routes
│   └── globals.css           # Global styles
├── components/
│   ├── ui/                   # shadcn/ui components
│   ├── nav.tsx               # Sidebar navigation
│   └── header.tsx            # Top header with user menu
├── lib/
│   ├── utils.ts              # Utility functions
│   └── api.ts                # API client for backend
├── auth.ts                   # NextAuth configuration
├── middleware.ts             # Auth middleware
└── components.json           # shadcn/ui configuration
```

## Authentication

The admin panel uses NextAuth.js v5 with Google OAuth provider. Access is restricted to a single email address (`mezianiyani0@gmail.com`) configured in `auth.ts`.

To change the allowed email:
1. Open `auth.ts`
2. Update the `ALLOWED_EMAIL` constant
3. Rebuild the application

## API Integration

The admin panel communicates with the Thala backend API. API client functions are defined in `lib/api.ts`.

Available API modules:
- `usersApi` - User management
- `eventsApi` - Cultural events
- `videosApi` - Video content
- `musicApi` - Music tracks
- `archiveApi` - Archive entries
- `communityApi` - Community profiles and host requests

## Customization

### Adding New Pages

1. Create a new directory under `app/(dashboard)/`
2. Add a `page.tsx` file
3. Update the navigation in `components/nav.tsx`

### Adding New shadcn/ui Components

```bash
npx shadcn@latest add [component-name]
```

### Styling

The app uses Tailwind CSS v4 with custom color variables defined in `app/globals.css`. Modify the CSS variables to customize the theme.

## Security

- ✅ Only authorized email can access admin panel
- ✅ All routes protected by middleware
- ✅ Server-side session validation
- ✅ Secure OAuth flow

## License

Part of the Thala cultural platform.
