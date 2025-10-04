import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export type LocalizedField =
  | string
  | null
  | undefined
  | Record<string, string | null | undefined>

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatLocalizedField(
  value: LocalizedField,
  fallback = "-"
): string {
  if (!value) {
    return fallback
  }

  if (typeof value === "string") {
    return value
  }

  const preferred = value.en ?? value["en-US"] ?? value["en-GB"]
  if (typeof preferred === "string" && preferred.trim().length > 0) {
    return preferred
  }

  const firstAvailable = Object.values(value).find(
    (text): text is string => typeof text === "string" && text.trim().length > 0
  )

  return firstAvailable ?? fallback
}
