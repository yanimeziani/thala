import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, Calendar, Video, Archive, MessageSquare, Users as Community, Shield, Heart, MessageCircle, Share2, TrendingUp, Activity } from "lucide-react"
import { auth } from "@/auth"
import { getAdminUser } from "@/lib/admin-config"
import { videosApi, eventsApi } from "@/lib/api"
import Link from "next/link"
import { Button } from "@/components/ui/button"

async function getDashboardStats() {
  try {
    const response = await fetch(`${process.env.NEXT_PUBLIC_ADMIN_URL || 'http://localhost:3001'}/api/admin/stats`, {
      cache: 'no-store'
    })
    if (!response.ok) throw new Error('Failed to fetch stats')
    return await response.json()
  } catch (error) {
    console.error('Error fetching dashboard stats:', error)
    return {
      totalUsers: 0,
      totalEvents: 0,
      totalVideos: 0,
      totalArchiveEntries: 0,
      totalMessages: 0,
      totalCommunities: 0,
      totalLikes: 0,
      totalComments: 0,
      totalShares: 0,
    }
  }
}

export default async function DashboardPage() {
  const session = await auth()
  const adminUser = session?.user?.email ? getAdminUser(session.user.email) : null
  const stats = await getDashboardStats()

  // Fetch recent videos and events for activity feed
  const { data: recentVideos } = await videosApi.getAll()
  const { data: recentEvents } = await eventsApi.getAll()

  const latestVideos = recentVideos?.slice(0, 5) || []
  const latestEvents = recentEvents?.slice(0, 3) || []

  const statCards = [
    {
      title: "Total Users",
      value: stats.totalUsers,
      description: "Registered users",
      icon: Users,
      trend: "+12%",
    },
    {
      title: "Videos",
      value: stats.totalVideos,
      description: "Published videos",
      icon: Video,
      trend: "+8%",
    },
    {
      title: "Events",
      value: stats.totalEvents,
      description: "Cultural events",
      icon: Calendar,
      trend: "+5%",
    },
    {
      title: "Archive Entries",
      value: stats.totalArchiveEntries,
      description: "Heritage items",
      icon: Archive,
      trend: "+3%",
    },
    {
      title: "Communities",
      value: stats.totalCommunities,
      description: "Community profiles",
      icon: Community,
      trend: "0%",
    },
    {
      title: "Messages",
      value: stats.totalMessages,
      description: "User messages",
      icon: MessageSquare,
      trend: "+20%",
    },
  ]

  const engagementStats = [
    {
      title: "Total Likes",
      value: stats.totalLikes || 0,
      icon: Heart,
      color: "text-red-500",
    },
    {
      title: "Total Comments",
      value: stats.totalComments || 0,
      icon: MessageCircle,
      color: "text-blue-500",
    },
    {
      title: "Total Shares",
      value: stats.totalShares || 0,
      icon: Share2,
      color: "text-green-500",
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
                <div className="flex items-center gap-2">
                  <p className="text-xs text-muted-foreground">
                    {stat.description}
                  </p>
                  {stat.trend && (
                    <span className="text-xs text-green-600 font-medium flex items-center">
                      <TrendingUp className="h-3 w-3 mr-1" />
                      {stat.trend}
                    </span>
                  )}
                </div>
              </CardContent>
            </Card>
          )
        })}
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        {engagementStats.map((stat) => {
          const Icon = stat.icon
          return (
            <Card key={stat.title}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  {stat.title}
                </CardTitle>
                <Icon className={`h-4 w-4 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value.toLocaleString()}</div>
              </CardContent>
            </Card>
          )
        })}
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="h-5 w-5" />
              Recent Videos
            </CardTitle>
            <CardDescription>
              Latest video uploads
            </CardDescription>
          </CardHeader>
          <CardContent>
            {latestVideos.length === 0 ? (
              <p className="text-sm text-muted-foreground">No recent videos</p>
            ) : (
              <div className="space-y-3">
                {latestVideos.map((video) => (
                  <div key={video.id} className="flex items-center justify-between">
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">
                        {video.title_en || video.title || 'Untitled'}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {video.creator_handle || 'Unknown'} • {new Date(video.created_at).toLocaleDateString()}
                      </p>
                    </div>
                    <Button variant="ghost" size="sm" asChild>
                      <Link href={`/videos/${video.id}`}>View</Link>
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Calendar className="h-5 w-5" />
              Upcoming Events
            </CardTitle>
            <CardDescription>
              Next cultural events
            </CardDescription>
          </CardHeader>
          <CardContent>
            {latestEvents.length === 0 ? (
              <p className="text-sm text-muted-foreground">No upcoming events</p>
            ) : (
              <div className="space-y-3">
                {latestEvents.map((event) => (
                  <div key={event.id} className="flex items-center justify-between">
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">
                        {event.title?.en || 'Untitled Event'}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {new Date(event.start_at).toLocaleDateString()} • {event.mode}
                      </p>
                    </div>
                    <Button variant="ghost" size="sm" asChild>
                      <Link href={`/events/${event.id}`}>View</Link>
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
          <CardDescription>
            Common management tasks
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-3 md:grid-cols-3">
            <Button variant="outline" className="justify-start" asChild>
              <Link href="/videos">
                <Video className="mr-2 h-4 w-4" />
                Manage Videos
              </Link>
            </Button>
            <Button variant="outline" className="justify-start" asChild>
              <Link href="/events">
                <Calendar className="mr-2 h-4 w-4" />
                Manage Events
              </Link>
            </Button>
            <Button variant="outline" className="justify-start" asChild>
              <Link href="/users">
                <Users className="mr-2 h-4 w-4" />
                Manage Users
              </Link>
            </Button>
            <Button variant="outline" className="justify-start" asChild>
              <Link href="/archive">
                <Archive className="mr-2 h-4 w-4" />
                Manage Archive
              </Link>
            </Button>
            <Button variant="outline" className="justify-start" asChild>
              <Link href="/community">
                <Community className="mr-2 h-4 w-4" />
                Communities
              </Link>
            </Button>
            <Button variant="outline" className="justify-start" asChild>
              <Link href="/settings">
                <Shield className="mr-2 h-4 w-4" />
                Settings
              </Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
