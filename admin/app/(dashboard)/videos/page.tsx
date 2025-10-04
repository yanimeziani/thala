import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { videosApi } from "@/lib/api"
import Link from "next/link"

export default async function VideosPage() {
  const { data: videos, error } = await videosApi.getAll()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Videos</h2>
          <p className="text-muted-foreground">Manage video content</p>
        </div>
        <Button asChild>
          <Link href="/videos/new">Upload Video</Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Videos</CardTitle>
          <CardDescription>View and manage video content</CardDescription>
        </CardHeader>
        <CardContent>
          {error && (
            <div className="text-sm text-red-500">
              Error loading videos: {error}
            </div>
          )}
          {videos && videos.length === 0 && (
            <div className="text-sm text-muted-foreground">No videos found</div>
          )}
          {videos && videos.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Creator</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Stats</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {videos.map((video: any) => (
                  <TableRow key={video.id}>
                    <TableCell className="font-medium">
                      {video.title_en || video.title}
                    </TableCell>
                    <TableCell>{video.creator_handle}</TableCell>
                    <TableCell>
                      <Badge variant="outline">{video.media_kind}</Badge>
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      ❤️ {video.likes} 💬 {video.comments} 🔄 {video.shares}
                    </TableCell>
                    <TableCell>
                      {new Date(video.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/videos/${video.id}`}>Edit</Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
