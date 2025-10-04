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
import { archiveApi } from "@/lib/api"
import Link from "next/link"

export default async function ArchivePage() {
  const { data: entries, error } = await archiveApi.getAll()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Archive</h2>
          <p className="text-muted-foreground">
            Manage cultural heritage archive
          </p>
        </div>
        <Button asChild>
          <Link href="/archive/new">Add Entry</Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Archive Entries</CardTitle>
          <CardDescription>
            View and manage heritage archive items
          </CardDescription>
        </CardHeader>
        <CardContent>
          {error && (
            <div className="text-sm text-red-500">
              Error loading archive: {error}
            </div>
          )}
          {entries && entries.length === 0 && (
            <div className="text-sm text-muted-foreground">
              No archive entries found
            </div>
          )}
          {entries && entries.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Era</TableHead>
                  <TableHead>Community Votes</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {entries.map((entry: any) => (
                  <TableRow key={entry.id}>
                    <TableCell className="font-medium">
                      {entry.title?.en || entry.title}
                    </TableCell>
                    <TableCell>
                      {entry.category ? (
                        <Badge variant="outline">{entry.category}</Badge>
                      ) : (
                        "-"
                      )}
                    </TableCell>
                    <TableCell>
                      {entry.era?.en || entry.era || "-"}
                    </TableCell>
                    <TableCell>
                      👍 {entry.community_upvotes} / {entry.registered_users}
                    </TableCell>
                    <TableCell>
                      {new Date(entry.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/archive/${entry.id}`}>Edit</Link>
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
