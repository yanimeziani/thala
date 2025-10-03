# syntax=docker/dockerfile:1

FROM node:20-alpine AS base
WORKDIR /app
RUN apk add --no-cache libc6-compat
ENV NEXT_TELEMETRY_DISABLED=1

FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci

FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
RUN apk add --no-cache libc6-compat \
  && addgroup -g 1001 -S nodejs \
  && adduser -S nextjs -G nodejs
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --chown=nextjs:nodejs package.json package-lock.json ./
COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules
RUN npm prune --omit=dev
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

USER nextjs
EXPOSE 3000
CMD ["npm", "run", "start"]
