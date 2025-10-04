const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "https://backend.thala.app/api/v1"

export interface ApiResponse<T> {
  data?: T
  error?: string
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

    const data = await response.json()
    return { data }
  } catch (error) {
    return { error: error instanceof Error ? error.message : "Unknown error" }
  }
}

// Users API
export const usersApi = {
  getAll: () => apiRequest<any[]>("/users"),
  getById: (id: string) => apiRequest<any>(`/users/${id}`),
  update: (id: string, data: any) =>
    apiRequest<any>(`/users/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
}

// Events API
export const eventsApi = {
  getAll: () => apiRequest<any[]>("/events"),
  getById: (id: string) => apiRequest<any>(`/events/${id}`),
  create: (data: any) =>
    apiRequest<any>("/events", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: any) =>
    apiRequest<any>(`/events/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<any>(`/events/${id}`, { method: "DELETE" }),
}

// Videos API
export const videosApi = {
  getAll: () => apiRequest<any[]>("/videos"),
  getById: (id: string) => apiRequest<any>(`/videos/${id}`),
  create: (data: any) =>
    apiRequest<any>("/videos", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: any) =>
    apiRequest<any>(`/videos/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<any>(`/videos/${id}`, { method: "DELETE" }),
}

// Music Tracks API
export const musicApi = {
  getAll: () => apiRequest<any[]>("/music"),
  getById: (id: string) => apiRequest<any>(`/music/${id}`),
  create: (data: any) =>
    apiRequest<any>("/music", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: any) =>
    apiRequest<any>(`/music/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<any>(`/music/${id}`, { method: "DELETE" }),
}

// Archive API
export const archiveApi = {
  getAll: () => apiRequest<any[]>("/archive"),
  getById: (id: string) => apiRequest<any>(`/archive/${id}`),
  create: (data: any) =>
    apiRequest<any>("/archive", {
      method: "POST",
      body: JSON.stringify(data),
    }),
  update: (id: string, data: any) =>
    apiRequest<any>(`/archive/${id}`, {
      method: "PUT",
      body: JSON.stringify(data),
    }),
  delete: (id: string) =>
    apiRequest<any>(`/archive/${id}`, { method: "DELETE" }),
}

// Community API
export const communityApi = {
  getAll: () => apiRequest<any[]>("/community"),
  getById: (id: string) => apiRequest<any>(`/community/${id}`),
  getHostRequests: () => apiRequest<any[]>("/community/host-requests"),
  updateHostRequest: (id: string, status: string) =>
    apiRequest<any>(`/community/host-requests/${id}`, {
      method: "PUT",
      body: JSON.stringify({ status }),
    }),
}
