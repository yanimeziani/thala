"use client"

import { Area, AreaChart, CartesianGrid, XAxis, YAxis } from "recharts"
import {
  ChartConfig,
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart"

// Sample data - last 12 months platform activity
const generateActivityData = () => {
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  const currentMonth = new Date().getMonth()

  return months.map((month, index) => {
    const baseVideos = 20
    const baseEvents = 5
    const baseArchive = 10

    return {
      month,
      videos: Math.floor(baseVideos + index * 12 + Math.random() * 8),
      events: Math.floor(baseEvents + index * 3 + Math.random() * 3),
      archive: Math.floor(baseArchive + index * 6 + Math.random() * 5),
    }
  }).slice(0, currentMonth + 1)
}

const chartData = generateActivityData()

const chartConfig = {
  videos: {
    label: "Videos",
    color: "hsl(var(--chart-1))",
  },
  events: {
    label: "Events",
    color: "hsl(var(--chart-4))",
  },
  archive: {
    label: "Archive",
    color: "hsl(var(--chart-5))",
  },
} satisfies ChartConfig

export function ActivityChart() {
  return (
    <ChartContainer config={chartConfig}>
      <AreaChart
        accessibilityLayer
        data={chartData}
        margin={{
          left: 12,
          right: 12,
        }}
      >
        <CartesianGrid vertical={false} />
        <XAxis
          dataKey="month"
          tickLine={false}
          axisLine={false}
          tickMargin={8}
        />
        <YAxis
          tickLine={false}
          axisLine={false}
          tickMargin={8}
        />
        <ChartTooltip
          cursor={false}
          content={<ChartTooltipContent indicator="dot" />}
        />
        <ChartLegend content={<ChartLegendContent />} />
        <Area
          dataKey="videos"
          type="natural"
          fill="var(--color-videos)"
          fillOpacity={0.4}
          stroke="var(--color-videos)"
          strokeWidth={2}
        />
        <Area
          dataKey="events"
          type="natural"
          fill="var(--color-events)"
          fillOpacity={0.4}
          stroke="var(--color-events)"
          strokeWidth={2}
        />
        <Area
          dataKey="archive"
          type="natural"
          fill="var(--color-archive)"
          fillOpacity={0.4}
          stroke="var(--color-archive)"
          strokeWidth={2}
        />
      </AreaChart>
    </ChartContainer>
  )
}
