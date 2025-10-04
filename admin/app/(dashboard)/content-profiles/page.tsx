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
import Link from "next/link"

// TODO: Add content profiles API endpoint
async function getContentProfiles() {
  return { data: [], error: null }
}

export default async function ContentProfilesPage() {
  const { data: profiles, error } = await getContentProfiles()

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Content Profiles</h2>
        <p className="text-muted-foreground">
          Manage content categorization and cultural profiles
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Content Profiles</CardTitle>
          <CardDescription>
            View and manage content cultural profiles
          </CardDescription>
        </CardHeader>
        <CardContent>
          {error && (
            <div className="text-sm text-red-500">
              Error loading profiles: {error}
            </div>
          )}
          {profiles && profiles.length === 0 && (
            <div className="text-sm text-muted-foreground">
              No content profiles found
            </div>
          )}
          {profiles && profiles.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Content ID</TableHead>
                  <TableHead>Cultural Families</TableHead>
                  <TableHead>Regions</TableHead>
                  <TableHead>Languages</TableHead>
                  <TableHead>Guardian Approved</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {profiles.map((profile: any) => (
                  <TableRow key={profile.content_id}>
                    <TableCell className="font-medium">
                      {profile.content_id}
                    </TableCell>
                    <TableCell>
                      {profile.cultural_families?.join(", ") || "-"}
                    </TableCell>
                    <TableCell>{profile.regions?.join(", ") || "-"}</TableCell>
                    <TableCell>
                      {profile.languages?.join(", ") || "-"}
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={
                          profile.is_guardian_approved ? "default" : "secondary"
                        }
                      >
                        {profile.is_guardian_approved ? "Yes" : "No"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/content-profiles/${profile.content_id}`}>
                          Edit
                        </Link>
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
