"use client";

import { useEffect, useRef } from "react";

export function AnimatedBackground() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let animationFrameId: number;
    let time = 0;

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    resize();
    window.addEventListener("resize", resize);

    const render = () => {
      const { width, height } = canvas;
      time += 0.005;

      // Create animated gradient background inspired by the splash shader
      const gradient1 = ctx.createLinearGradient(0, 0, width, height);
      gradient1.addColorStop(0, `rgba(24, 39, 64, ${0.8 + Math.sin(time * 0.5) * 0.2})`);
      gradient1.addColorStop(0.5, `rgba(12, 15, 25, ${0.9 + Math.cos(time * 0.3) * 0.1})`);
      gradient1.addColorStop(1, "rgba(5, 6, 10, 1)");

      ctx.fillStyle = gradient1;
      ctx.fillRect(0, 0, width, height);

      // Add animated wave-like patterns
      for (let i = 0; i < 3; i++) {
        const offset = i * 120;
        const gradient2 = ctx.createRadialGradient(
          width / 2 + Math.sin(time + offset) * 200,
          height / 2 + Math.cos(time * 0.7 + offset) * 150,
          50,
          width / 2 + Math.sin(time + offset) * 200,
          height / 2 + Math.cos(time * 0.7 + offset) * 150,
          300
        );

        const opacity = 0.05 + Math.sin(time + offset) * 0.03;
        gradient2.addColorStop(0, `rgba(255, 149, 105, ${opacity})`);
        gradient2.addColorStop(0.5, `rgba(240, 106, 62, ${opacity * 0.5})`);
        gradient2.addColorStop(1, "rgba(5, 6, 10, 0)");

        ctx.fillStyle = gradient2;
        ctx.fillRect(0, 0, width, height);
      }

      animationFrameId = requestAnimationFrame(render);
    };

    render();

    return () => {
      window.removeEventListener("resize", resize);
      cancelAnimationFrame(animationFrameId);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full"
      style={{ background: "linear-gradient(135deg, #182740 0%, #05060A 100%)" }}
    />
  );
}
