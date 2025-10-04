import type { LocalizedField } from "./utils"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "https://backend.thala.app/api/v1"

export interface ApiResponse<T> {
  data?: T
  error?: string
}

type JsonPrimitive = string | number | boolean | null
type JsonValue = JsonPrimitive | JsonValue[] | { [key: string]: JsonValue }
type JsonObject = { [key: string]: JsonValue }

type WritePayload<T> = Partial<Omit<T, "id" | "created_at">> & JsonObject

export interface User {
  id: string
  email: string
  full_name?: string | null
  locale?: string | null
  is_active: boolean
  last_login_at?: string | null
  created_at: string
}

export type UpdateUserPayload = Partial<
  Pick<User, "full_name" | "locale" | "is_active">
> & JsonObject

export interface Event {
  id: string
  title?: LocalizedField
  mode: string
  start_at: string
  location?: LocalizedField
  host_name?: string | null
  interested_count?: number | null
  created_at: string
}

export type EventWritePayload = WritePayload<Event>

export interface Video {
  id: string
  title: string | null
  title_en?: string | null
  creator_handle?: string | null
  media_kind?: string | null
  likes?: number | null
  comments?: number | null
  shares?: number | null
  created_at: string
}

export type VideoWritePayload = WritePayload<Video>

export interface MusicTrack {
  id: string
  title: string
  artist: string
  duration_seconds: number
  created_at: string
}

export type MusicTrackWritePayload = WritePayload<MusicTrack>

export interface ArchiveEntry {
  id: string
  title?: LocalizedField
  category?: string | null
  era?: LocalizedField
  community_upvotes?: number | null
  registered_users?: number | null
  created_at: string
}

export type ArchiveEntryWritePayload = WritePayload<ArchiveEntry>

export interface CommunityProfile {
  id: string
  region?: string | null
  languages?: string[]
  priority?: number | string | null
}

export type CommunityProfileWritePayload = WritePayload<CommunityProfile>

export type HostRequestStatus =
  | "pending"
  | "approved"
  | "rejected"
  | (string & {})

export interface CommunityHostRequest {
  id: string
  name: string
  email: string
  message: string
  status: HostRequestStatus
  created_at: string
}

export async function apiRequest<T>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...options?.headers,
      },
    })

    if (!response.ok) {
      return { error: `HTTP error! status: ${response.status}` }
    }

    const data = (await response.json()) as T
    return { data }
  } catch (error) {
    return { error: error instanceof Error ? error.message : "Unknown error" }
  }
}

// Users API
export const usersApi = {
  getAll: () => apiRequest<User[]>("/users"),
  getById: (id: string) => apiRequest<User>(`/users/${id}`),
  update: (id: string, data: UpdateUserPayload) =>
    apiRequest<User>(`/users/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
}

// Events API
export const eventsApi = {
  getAll: () => apiRequest<Event[]>("/events"),
  getById: (id: string) => apiRequest<Event>(`/events/${id}`),
  create: (data: EventWritePayload) =>
    apiRequest<Event>("/events", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: EventWritePayload) =>
    apiRequest<Event>(`/events/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<Event>(`/events/${id}`, { method: "DELETE" }),
}

// Videos API
export const videosApi = {
  getAll: () => apiRequest<Video[]>("/videos"),
  getById: (id: string) => apiRequest<Video>(`/videos/${id}`),
  create: (data: VideoWritePayload) =>
    apiRequest<Video>("/videos", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: VideoWritePayload) =>
    apiRequest<Video>(`/videos/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<Video>(`/videos/${id}`, { method: "DELETE" }),
}

// Music Tracks API
export const musicApi = {
  getAll: () => apiRequest<MusicTrack[]>("/music"),
  getById: (id: string) => apiRequest<MusicTrack>(`/music/${id}`),
  create: (data: MusicTrackWritePayload) =>
    apiRequest<MusicTrack>("/music", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: MusicTrackWritePayload) =>
    apiRequest<MusicTrack>(`/music/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<MusicTrack>(`/music/${id}`, { method: "DELETE" }),
}

// Archive API
export const archiveApi = {
  getAll: () => apiRequest<ArchiveEntry[]>("/archive"),
  getById: (id: string) => apiRequest<ArchiveEntry>(`/archive/${id}`),
  create: (data: ArchiveEntryWritePayload) =>
    apiRequest<ArchiveEntry>("/archive", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: ArchiveEntryWritePayload) =>
    apiRequest<ArchiveEntry>(`/archive/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<ArchiveEntry>(`/archive/${id}`, { method: "DELETE" }),
}

// Community API
export const communityApi = {
  getAll: () => apiRequest<CommunityProfile[]>("/community"),
  getById: (id: string) => apiRequest<CommunityProfile>(`/community/${id}`),
  getHostRequests: () =>
    apiRequest<CommunityHostRequest[]>("/community/host-requests"),
  updateHostRequest: (id: string, status: HostRequestStatus) =>
    apiRequest<CommunityHostRequest>(`/community/host-requests/${id}`, {
      method: "PUT",
      body: JSON.stringify({ status }),
    }),
}
