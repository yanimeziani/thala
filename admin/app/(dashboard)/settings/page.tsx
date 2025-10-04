import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Settings</h2>
        <p className="text-muted-foreground">Configure admin panel settings</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>API Configuration</CardTitle>
          <CardDescription>
            Configure backend API connection settings
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="api-url">Backend API URL</Label>
            <Input
              id="api-url"
              placeholder="https://backend.thala.app/api/v1"
              defaultValue={process.env.NEXT_PUBLIC_API_URL}
              disabled
            />
            <p className="text-xs text-muted-foreground">
              Set via NEXT_PUBLIC_API_URL environment variable
            </p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Authentication</CardTitle>
          <CardDescription>
            OAuth and authentication settings
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="text-sm text-muted-foreground">
            Authentication is configured via environment variables:
            <ul className="list-disc list-inside mt-2 space-y-1">
              <li>GOOGLE_CLIENT_ID</li>
              <li>GOOGLE_CLIENT_SECRET</li>
              <li>AUTH_SECRET</li>
            </ul>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Access Control</CardTitle>
          <CardDescription>
            Admin access configuration
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="text-sm">
            <p className="font-medium mb-2">Allowed Admin Email:</p>
            <code className="bg-muted px-2 py-1 rounded">mezianiyani0@gmail.com</code>
            <p className="text-muted-foreground mt-2 text-xs">
              Only this email address has access to the admin panel.
              To change this, update the ALLOWED_EMAIL constant in auth.ts
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
