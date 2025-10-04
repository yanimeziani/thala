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
import { communityApi } from "@/lib/api"
import Link from "next/link"

export default async function CommunityPage() {
  const { data: communities, error: communitiesError } =
    await communityApi.getAll()
  const { data: hostRequests, error: requestsError } =
    await communityApi.getHostRequests()

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Community</h2>
        <p className="text-muted-foreground">
          Manage community profiles and host requests
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Community Profiles</CardTitle>
          <CardDescription>View and manage community profiles</CardDescription>
        </CardHeader>
        <CardContent>
          {communitiesError && (
            <div className="text-sm text-red-500">
              Error loading communities: {communitiesError}
            </div>
          )}
          {communities && communities.length === 0 && (
            <div className="text-sm text-muted-foreground">
              No communities found
            </div>
          )}
          {communities && communities.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>ID</TableHead>
                  <TableHead>Region</TableHead>
                  <TableHead>Languages</TableHead>
                  <TableHead>Priority</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {communities.map((community: any) => (
                  <TableRow key={community.id}>
                    <TableCell className="font-medium">{community.id}</TableCell>
                    <TableCell>{community.region}</TableCell>
                    <TableCell>
                      {community.languages?.join(", ") || "-"}
                    </TableCell>
                    <TableCell>{community.priority}</TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/community/${community.id}`}>Edit</Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Host Requests</CardTitle>
          <CardDescription>
            Review and manage community host requests
          </CardDescription>
        </CardHeader>
        <CardContent>
          {requestsError && (
            <div className="text-sm text-red-500">
              Error loading host requests: {requestsError}
            </div>
          )}
          {hostRequests && hostRequests.length === 0 && (
            <div className="text-sm text-muted-foreground">
              No host requests found
            </div>
          )}
          {hostRequests && hostRequests.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Message</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {hostRequests.map((request: any) => (
                  <TableRow key={request.id}>
                    <TableCell className="font-medium">{request.name}</TableCell>
                    <TableCell>{request.email}</TableCell>
                    <TableCell className="max-w-xs truncate">
                      {request.message}
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={
                          request.status === "approved"
                            ? "default"
                            : request.status === "rejected"
                            ? "destructive"
                            : "secondary"
                        }
                      >
                        {request.status}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {new Date(request.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" asChild>
                        <Link href={`/community/requests/${request.id}`}>
                          Review
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
