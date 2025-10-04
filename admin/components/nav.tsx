"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import {
  Users,
  Calendar,
  Video,
  Music,
  Archive,
  Users as Community,
  MessageSquare,
  Settings,
  LayoutDashboard,
  FileText,
  Database,
  Bug,
} from "lucide-react"

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/users", label: "Users", icon: Users },
  { href: "/events", label: "Events", icon: Calendar },
  { href: "/videos", label: "Videos", icon: Video },
  { href: "/music", label: "Music Tracks", icon: Music },
  { href: "/archive", label: "Archive", icon: Archive },
  { href: "/community", label: "Community", icon: Community },
  { href: "/content-profiles", label: "Content Profiles", icon: FileText },
  { href: "/messages", label: "Messages", icon: MessageSquare },
  { href: "/feedback", label: "Feedback", icon: Bug },
  { href: "/sql-editor", label: "SQL Editor", icon: Database },
  { href: "/settings", label: "Settings", icon: Settings },
]

export function Nav() {
  const pathname = usePathname()

  return (
    <nav className="space-y-1">
      {navItems.map((item) => {
        const Icon = item.icon
        const isActive = pathname === item.href
        return (
          <Link
            key={item.href}
            href={item.href}
            className={cn(
              "flex items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors",
              isActive
                ? "bg-primary text-primary-foreground"
                : "text-muted-foreground hover:bg-muted hover:text-foreground"
            )}
          >
            <Icon className="h-4 w-4" />
            {item.label}
          </Link>
        )
      })}
    </nav>
  )
}
