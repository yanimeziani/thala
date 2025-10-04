import { Header } from "@/components/header"
import { Nav } from "@/components/nav"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen">
      <Header />
      <div className="flex">
        <aside className="w-64 border-r min-h-[calc(100vh-4rem)] p-6">
          <Nav />
        </aside>
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  )
}
