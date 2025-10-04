import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Link from "next/link"

export default function ErrorPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center text-red-600">
            Access Denied
          </CardTitle>
          <CardDescription className="text-center">
            You don&apos;t have permission to access this admin panel.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex justify-center">
          <Link href="/auth/signin">
            <Button>Try Again</Button>
          </Link>
        </CardContent>
      </Card>
    </div>
  )
}
