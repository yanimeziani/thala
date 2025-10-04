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
import { musicApi } from "@/lib/api"
import Link from "next/link"

export default async function MusicPage() {
  const { data: tracks, error } = await musicApi.getAll()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Music Tracks</h2>
          <p className="text-muted-foreground">Manage music library</p>
        </div>
        <Button asChild>
          <Link href="/music/new">Add Track</Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Music Tracks</CardTitle>
          <CardDescription>View and manage music tracks</CardDescription>
        </CardHeader>
        <CardContent>
          {error && (
            <div className="text-sm text-red-500">
              Error loading music: {error}
            </div>
          )}
          {tracks && tracks.length === 0 && (
            <div className="text-sm text-muted-foreground">No tracks found</div>
          )}
          {tracks && tracks.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Artist</TableHead>
                  <TableHead>Duration</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {tracks.map((track: any) => (
                  <TableRow key={track.id}>
                    <TableCell className="font-medium">{track.title}</TableCell>
                    <TableCell>{track.artist}</TableCell>
                    <TableCell>
                      {Math.floor(track.duration_seconds / 60)}:
                      {(track.duration_seconds % 60).toString().padStart(2, "0")}
                    </TableCell>
                    <TableCell>
                      {new Date(track.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/music/${track.id}`}>Edit</Link>
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
