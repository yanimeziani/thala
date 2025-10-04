import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, Calendar, Video, Archive, MessageSquare, Users as Community, Shield } from "lucide-react"
import { auth } from "@/auth"
import { getAdminUser } from "@/lib/admin-config"

async function getDashboardStats() {
  // TODO: Fetch real stats from backend API
  return {
    totalUsers: 0,
    totalEvents: 0,
    totalVideos: 0,
    totalArchiveEntries: 0,
    totalMessages: 0,
    totalCommunities: 0,
  }
}

export default async function DashboardPage() {
  const session = await auth()
  const adminUser = session?.user?.email ? getAdminUser(session.user.email) : null
  const stats = await getDashboardStats()

  const statCards = [
    {
      title: "Total Users",
      value: stats.totalUsers,
      description: "Registered users",
      icon: Users,
    },
    {
      title: "Events",
      value: stats.totalEvents,
      description: "Cultural events",
      icon: Calendar,
    },
    {
      title: "Videos",
      value: stats.totalVideos,
      description: "Published videos",
      icon: Video,
    },
    {
      title: "Archive Entries",
      value: stats.totalArchiveEntries,
      description: "Heritage items",
      icon: Archive,
    },
    {
      title: "Messages",
      value: stats.totalMessages,
      description: "User messages",
      icon: MessageSquare,
    },
    {
      title: "Communities",
      value: stats.totalCommunities,
      description: "Community profiles",
      icon: Community,
    },
  ]

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Dashboard</h2>
          <p className="text-muted-foreground">
            Welcome back, {adminUser?.name || session?.user?.name || "Admin"}
          </p>
        </div>
        {adminUser && (
          <div className="flex items-center gap-2 rounded-lg border px-4 py-2">
            <Shield className="h-4 w-4 text-muted-foreground" />
            <span className="text-sm font-medium capitalize">
              {adminUser.role.replace("_", " ")}
            </span>
          </div>
        )}
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {statCards.map((stat) => {
          const Icon = stat.icon
          return (
            <Card key={stat.title}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  {stat.title}
                </CardTitle>
                <Icon className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                <p className="text-xs text-muted-foreground">
                  {stat.description}
                </p>
              </CardContent>
            </Card>
          )
        })}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
          <CardDescription>
            Common tasks and shortcuts
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="text-sm text-muted-foreground">
            Use the navigation sidebar to manage different aspects of the Thala platform.
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
