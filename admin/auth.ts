import NextAuth from "next-auth"
import Google from "next-auth/providers/google"

const ALLOWED_EMAIL = "mezianiyani0@gmail.com"

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
  ],
  callbacks: {
    async signIn({ user }) {
      // Only allow the specific admin email
      if (user.email === ALLOWED_EMAIL) {
        return true
      }
      return false
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub!
      }
      return session
    },
  },
  pages: {
    signIn: "/auth/signin",
    error: "/auth/error",
  },
})
