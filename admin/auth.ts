import NextAuth, { type DefaultSession } from "next-auth"
import Google from "next-auth/providers/google"
import { isAuthorizedAdmin, getAdminUser, type AdminRole } from "@/lib/admin-config"

// Extend the built-in session type
declare module "next-auth" {
  interface Session {
    user: {
      role: AdminRole
    } & DefaultSession["user"]
  }
}

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
  callbacks: {
    async signIn({ user, account }) {
      // Only allow authorized admin emails
      if (!user.email || !isAuthorizedAdmin(user.email)) {
        console.warn(`Unauthorized access attempt by: ${user.email}`)
        return false
      }

      // Log successful signin
      console.log(`Admin signed in: ${user.email} via ${account?.provider}`)
      return true
    },
    async jwt({ token, user }) {
      if (user?.email) {
        const adminUser = getAdminUser(user.email)
        if (adminUser) {
          token.role = adminUser.role
          token.permissions = adminUser.permissions
        }
      }
      return token
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub!
        session.user.role = token.role as AdminRole
      }
      return session
    },
  },
  session: {
    strategy: "jwt",
    maxAge: 8 * 60 * 60, // 8 hours
  },
  pages: {
    signIn: "/auth/signin",
    error: "/auth/error",
  },
  secret: process.env.AUTH_SECRET,
})
