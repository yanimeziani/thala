import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { eventsApi } from "@/lib/api"
import { formatLocalizedField } from "@/lib/utils"
import Link from "next/link"

export default async function EventsPage() {
  const { data: events, error } = await eventsApi.getAll()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Cultural Events</h2>
          <p className="text-muted-foreground">
            Manage Amazigh cultural events
          </p>
        </div>
        <Button asChild>
          <Link href="/events/new">Create Event</Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Events</CardTitle>
          <CardDescription>View and manage cultural events</CardDescription>
        </CardHeader>
        <CardContent>
          {error && (
            <div className="text-sm text-red-500">
              Error loading events: {error}
            </div>
          )}
          {events && events.length === 0 && (
            <div className="text-sm text-muted-foreground">
              No events found
            </div>
          )}
          {events && events.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Mode</TableHead>
                  <TableHead>Date</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Host</TableHead>
                  <TableHead>Interested</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {events.map((event) => (
                  <TableRow key={event.id}>
                    <TableCell className="font-medium">
                      {formatLocalizedField(event.title)}
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{event.mode}</Badge>
                    </TableCell>
                    <TableCell>
                      {new Date(event.start_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      {formatLocalizedField(event.location)}
                    </TableCell>
                    <TableCell>{event.host_name || "-"}</TableCell>
                    <TableCell>{event.interested_count || 0}</TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/events/${event.id}`}>Edit</Link>
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
