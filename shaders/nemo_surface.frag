#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uRadius;
uniform vec4 uBaseColor;
uniform vec2 uLightDirection;
uniform float uRimStrength;
uniform float uAmbientOcclusion;
uniform float uGrainOpacity;

out vec4 fragColor;

float roundedBoxSdf(vec2 point, vec2 halfSize, float radius) {
  vec2 corner = abs(point) - halfSize + radius;
  return length(max(corner, 0.0)) - radius + min(max(corner.x, corner.y), 0.0);
}

void main() {
  vec2 point = FlutterFragCoord().xy - uSize * 0.5;
  float distance = roundedBoxSdf(point, uSize * 0.5, uRadius);
  float edge = clamp(1.0 - abs(distance) / max(uRadius, 1.0), 0.0, 1.0);
  vec2 normal = normalize(max(abs(point), vec2(0.001))) * sign(point);
  float light = clamp(dot(-normal, normalize(uLightDirection)), -1.0, 1.0);
  float rim = light * uRimStrength * edge;
  float occlusion = -uAmbientOcclusion * edge * (1.0 - edge);
  float grain = fract(sin(dot(FlutterFragCoord().xy, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
  vec3 color = clamp(uBaseColor.rgb + rim + occlusion + grain * uGrainOpacity, 0.0, 1.0);
  fragColor = vec4(color, uBaseColor.a);
}
