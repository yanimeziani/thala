#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

layout(location = 0) out vec4 fragColor;

float swirl(float radius, float angle, float time) {
  float wave = sin(angle * 4.0 + time * 0.8) * 0.18;
  wave += sin(radius * 6.5 - time * 1.2) * 0.12;
  wave += sin((radius + angle) * 9.2 + time * 0.6) * 0.05;
  return wave;
}

void main() {
  vec2 fragCoord = FlutterFragCoord();
  vec2 uv = fragCoord / uResolution;
  vec2 centered = uv - 0.5;
  centered.y *= uResolution.y / uResolution.x;

  float radius = length(centered) * 2.0;
  float angle = atan(centered.y, centered.x);

  float wave = swirl(radius, angle, uTime);
  float glow = smoothstep(0.9, 0.1, radius + wave);
  float rings = sin((radius + wave) * 22.0 - uTime * 2.6);
  float sparks = smoothstep(0.95, 0.5, rings * rings);

  vec3 core = vec3(0.93, 0.58, 0.18);
  vec3 horizon = vec3(0.04, 0.17, 0.22);
  float blend = clamp(radius + wave * 0.5, 0.0, 1.0);

  vec3 base = mix(core, horizon, blend);
  vec3 color = base + glow * vec3(0.08, 0.45, 0.40) + sparks * 0.25 * vec3(0.95, 0.6, 0.18);
  color = clamp(color, 0.0, 1.0);

  fragColor = vec4(color, 1.0);
}
