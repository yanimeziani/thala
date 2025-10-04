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

// Sample data - last 12 months engagement metrics
const generateEngagementData = () => {
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  const currentMonth = new Date().getMonth()

  return months.map((month, index) => {
    const baseLikes = 200
    const baseComments = 80
    const baseShares = 40

    return {
      month,
      likes: Math.floor(baseLikes + index * 85 + Math.random() * 50),
      comments: Math.floor(baseComments + index * 35 + Math.random() * 25),
      shares: Math.floor(baseShares + index * 20 + Math.random() * 15),
    }
  }).slice(0, currentMonth + 1)
}

const chartData = generateEngagementData()

const chartConfig = {
  likes: {
    label: "Likes",
    color: "hsl(var(--chart-1))",
  },
  comments: {
    label: "Comments",
    color: "hsl(var(--chart-2))",
  },
  shares: {
    label: "Shares",
    color: "hsl(var(--chart-3))",
  },
} satisfies ChartConfig

export function EngagementChart() {
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
          dataKey="likes"
          type="monotone"
          fill="var(--color-likes)"
          fillOpacity={0.4}
          stroke="var(--color-likes)"
          stackId="a"
        />
        <Area
          dataKey="comments"
          type="monotone"
          fill="var(--color-comments)"
          fillOpacity={0.4}
          stroke="var(--color-comments)"
          stackId="a"
        />
        <Area
          dataKey="shares"
          type="monotone"
          fill="var(--color-shares)"
          fillOpacity={0.4}
          stroke="var(--color-shares)"
          stackId="a"
        />
      </AreaChart>
    </ChartContainer>
  )
}
