"use client"

import { Area, AreaChart, CartesianGrid, XAxis, YAxis } from "recharts"
import {
  ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart"

// Sample data - last 12 months
const generateMonthlyData = () => {
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  const currentMonth = new Date().getMonth()

  return months.map((month, index) => {
    // Generate realistic growth data
    const baseUsers = 100
    const growth = index * 45 + Math.random() * 30
    return {
      month,
      users: Math.floor(baseUsers + growth),
    }
  }).slice(0, currentMonth + 1)
}

const chartData = generateMonthlyData()

const chartConfig = {
  users: {
    label: "Users",
    color: "hsl(var(--chart-1))",
  },
} satisfies ChartConfig

export function UserGrowthChart() {
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
          content={<ChartTooltipContent indicator="line" />}
        />
        <Area
          dataKey="users"
          type="monotone"
          fill="var(--color-users)"
          fillOpacity={0.4}
          stroke="var(--color-users)"
          strokeWidth={2}
        />
      </AreaChart>
    </ChartContainer>
  )
}
