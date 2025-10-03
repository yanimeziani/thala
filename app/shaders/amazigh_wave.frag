#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uLevel;

layout(location = 0) out vec4 fragColor;

float waveField(float y, float time) {
  float wave = sin((y * 6.283) + time * 0.8) * 0.18;
  wave += sin((y * 9.21) - time * 1.3) * 0.12;
  wave += sin((y * 14.31) + time * 0.6) * 0.05;
  return wave;
}

void main() {
  vec2 fragCoord = FlutterFragCoord();
  vec2 uv = fragCoord / uResolution;
  float y = 1.0 - uv.y;

  float wave = waveField(y, uTime) * uLevel;
  float distance = abs(uv.x - 0.5 - wave);
  float glow = smoothstep(0.28, 0.0, distance);
  float intenseGlow = smoothstep(0.08, 0.0, distance);

  vec3 base = mix(vec3(0.02, 0.14, 0.16), vec3(0.88, 0.56, 0.15), y);
  float pulse = 0.35 + 0.65 * sin(uTime * 1.4 + y * 8.0);

  vec3 color = base + glow * vec3(0.1, 0.55, 0.52) + intenseGlow * pulse * vec3(0.95, 0.62, 0.1);
  color = clamp(color, 0.0, 1.0);

  fragColor = vec4(color, 1.0);
}
