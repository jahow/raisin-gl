#version 300 es
precision mediump float;

#define MAX_PRIMITIVES 100
#define MAX_PRIMITIVES_DATA 1000

uniform vec2 u_resolution;
uniform int u_primitiveCount;

uniform float u_primitiveData[MAX_PRIMITIVES_DATA];

uniform int u_primitiveOffsets[MAX_PRIMITIVES];

out vec4 outColor;

float circle(vec2 p, vec2 center, float radius) {
    return distance(p, center) - radius;
}

float box(vec2 p, vec2 center, vec2 size) {
    float dx = abs(center.x - p.x);
    float dy = abs(center.y - p.y);
    return max(dx - size.x * 0.5, dy - size.y * 0.5);
}

float opSmoothUnion(float sdf1, float sdf2) {
    //return sdf1 + sdf2;
    float k = 10.0;
    float h = clamp(0.5 + 0.5 * (sdf2 - sdf1) / k, 0.0, 1.0);
    return mix(sdf2, sdf1, h) - k * h * (1.0 - h);
}

//float transfer(float new, float previous) {
//    return clamp(-1.0, 1.0, new) + previous);
//}

float getSdf(vec2 p, int offset) {
    float type = u_primitiveData[offset];
    if (type == 1.0) {
        float x = u_primitiveData[offset + 1];
        float y = u_primitiveData[offset + 2];
        float radius = u_primitiveData[offset + 3];
        return circle(p, vec2(x, y), radius);
    } else if (type == 2.0) {
        float x = u_primitiveData[offset + 1];
        float y = u_primitiveData[offset + 2];
        float width = u_primitiveData[offset + 3];
        float height = u_primitiveData[offset + 4];
        return box(p, vec2(x, y), vec2(width, height));
    }
    return 0.0;
}

void main() {
    float value = 0.0;
    float alpha = 0.0;

    vec2 ray = vec2(gl_FragCoord) - u_resolution * 0.5;;

    for (int i = 0; i < u_primitiveCount; i++) {
        int offset = u_primitiveOffsets[i];
        float sdf = 0.0;

        float type = u_primitiveData[offset];
        if (type == 1.0) {
            sdf = getSdf(ray, offset);
        } else if (type == 2.0) {
            sdf = getSdf(ray, offset);
        } else if (type == 10.0) {
            int offset1 = int(u_primitiveData[offset + 1]);
            int offset2 = int(u_primitiveData[offset + 2]);
            sdf = opSmoothUnion(getSdf(ray, offset1), getSdf(ray, offset2));
        }

        //value = transfer(sdf, value);
        value = sdf;
        //alpha = clamp(0.0, 1.0, alpha + smoothstep(-1.0, 1.0, value));
        alpha = clamp(0.0, 1.0, alpha + smoothstep(1.0, -1.0, value));
    }

    outColor = alpha * vec4(1, gl_FragCoord.x / u_resolution.x, gl_FragCoord.y / u_resolution.y, 1);
}