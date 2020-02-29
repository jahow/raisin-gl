#version 300 es
precision mediump float;

#define MAX_PRIMITIVES 100
#define MAX_PRIMITIVES_DATA 1000

uniform vec2 u_resolution;
uniform int u_primitiveCount;

uniform float u_primitiveData[MAX_PRIMITIVES_DATA];

uniform int u_primitiveOffsets[MAX_PRIMITIVES];

out vec4 outColor;

float circle(vec2 center, float radius) {
    float d = radius - distance(vec2(gl_FragCoord), center);
    return smoothstep(-1.0, 1.0, d);
}

float box(vec2 center, vec2 size) {
    float dx = abs(center.x - gl_FragCoord.x);
    float dy = abs(center.y - gl_FragCoord.y);
    return min(size.x * 0.5 - dx, size.y * 0.5 - dy);
}

float transfer(float new, float previous) {
    return min(1.0, max(0.0, new) + previous);
}

void main() {
    float value = 0.0;

    for (int i = 0; i < u_primitiveCount; i++) {
        int offset = u_primitiveOffsets[i];
        float type = u_primitiveData[offset];
        if (type == 1.0) {
            float x = u_primitiveData[offset + 1];
            float y = u_primitiveData[offset + 2];
            float radius = u_primitiveData[offset + 3];
            value = transfer(circle(vec2(x, y), radius), value);
        } else if (type == 2.0) {
            float x = u_primitiveData[offset + 1];
            float y = u_primitiveData[offset + 2];
            float width = u_primitiveData[offset + 3];
            float height = u_primitiveData[offset + 4];
            value = transfer(box(vec2(x, y), vec2(width, height)), value);
        }
    }

    outColor = value * vec4(1, gl_FragCoord.x / u_resolution.x, gl_FragCoord.y / u_resolution.y, 1);
}