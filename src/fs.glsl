#version 300 es
precision mediump float;

#define MAX_PRIMITIVES 100
#define MAX_PRIMITIVES_DATA 1000

uniform vec2 u_resolution;
uniform int u_primitiveCount;

uniform float u_primitiveData[MAX_PRIMITIVES_DATA];
uniform float u_paintData[MAX_PRIMITIVES_DATA];

uniform int u_primitiveOffsets[MAX_PRIMITIVES];

out vec4 outColor;

int SAMPLES = 8;

float randomOffset = 0.0;

// taken from https://www.shadertoy.com/view/MdtBzH
#define G(v) grad(hash(I+v),p-v)
#define fade(t)  t * t * t * (t * (t * 6. - 15.) + 10.) // super-smoothstep

// std int hash, inspired from https://www.shadertoy.com/view/XlXcW4
vec3 hash3i( uvec3 x )
{
    #   define scramble  x = ( (x>>8U) ^ x.yzx ) * 1103515245U // GLIB-C const
    scramble; scramble; scramble;
    return vec3(x) / float(0xffffffffU) + 1e-30; // <- eps to fix a windows/angle bug
}
    #define unsigned(v) ( (v) >= 0. ? uint(v) : -1U-uint(-(v)) ) // for uint(float < 0) is bugged
    #define hash(v) hash3i(uvec3(unsigned((v).x),unsigned((v).y),11)).x

float grad(float r, vec2 p) {
    int h = int(r*256.) & 15;
    float u = h<8 ? p.x : p.y,                 // 12 gradient directions
    v = h<4 ? p.y : h==12||h==14 ? p.x : 0.; // p.z;
    return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
}

float blurNoise(in vec2 p) {
    vec2 I = floor(p); p -= I;
    vec2 f = fade(p);

    return mix( mix( G(vec2(0,0)),G(vec2(1,0)), f.x),
    mix( G(vec2(0,1)),G(vec2(1,1)), f.x), f.y );
}

float circle(vec2 p, vec2 center, float radius) {
    return distance(p, center) - radius;
}

float box(vec2 p, vec2 center, vec2 size) {
    float dx = abs(center.x - p.x);
    float dy = abs(center.y - p.y);
    return max(dx - size.x * 0.5, dy - size.y * 0.5);
}

float opSmoothUnion(float sdf1, float sdf2) {
    float k = 10.0;
    float h = clamp(0.5 + 0.5 * (sdf2 - sdf1) / k, 0.0, 1.0);
    return mix(sdf2, sdf1, h) - k * h * (1.0 - h);
}

vec4 paintSolid(float sdf, int offset, vec4 previous, inout vec2 p) {
    // compute out color and alpha
    float intensity = smoothstep(1.0, -1.0, sdf);
    if (sdf < 0.0) {
        intensity *= 0.85 + 0.1 * smoothstep(-12.0, 0.0, sdf)
            + 0.05 * blurNoise(p * 0.4);
    }
    vec4 color = vec4(
        u_paintData[offset + 1],
        u_paintData[offset + 2],
        u_paintData[offset + 3],
        u_paintData[offset + 4] * intensity
    );
    float addedAlpha = previous.a + color.a * (1.0 - previous.a);

    // displace ray
    float scatter = u_paintData[offset + 5];
    float noiseX = blurNoise(p + 10.715 + randomOffset);
    float noiseY = blurNoise(p + 5.179 + randomOffset);
    p.x += noiseX * scatter;
    p.y += noiseY * scatter;

    return vec4(previous.rgb * previous.a + color.rgb * (1.0 - previous.a), addedAlpha);
}

float getSdf(vec2 p, int offset) {
    float type = u_primitiveData[offset];
    if (type == 1.0) {
        float x = u_primitiveData[offset + 2];
        float y = u_primitiveData[offset + 3];
        float radius = u_primitiveData[offset + 4];
        return circle(p, vec2(x, y), radius);
    } else if (type == 2.0) {
        float x = u_primitiveData[offset + 2];
        float y = u_primitiveData[offset + 3];
        float width = u_primitiveData[offset + 4];
        float height = u_primitiveData[offset + 5];
        return box(p, vec2(x, y), vec2(width, height));
    }
    return 0.0;
}

vec4 rayTrace(vec2 ray, vec4 startColor) {
    vec4 color = startColor;
    for (int i = 0; i < u_primitiveCount; i++) {
        int offset = u_primitiveOffsets[i];
        float sdf = 0.0;

        float type = u_primitiveData[offset];
        if (type == 1.0) {
            sdf = getSdf(ray, offset);
        } else if (type == 2.0) {
            sdf = getSdf(ray, offset);
        } else if (type == 10.0) {
            int offset1 = int(u_primitiveData[offset + 2]);
            int offset2 = int(u_primitiveData[offset + 3]);
            sdf = opSmoothUnion(getSdf(ray, offset1), getSdf(ray, offset2));
        }

        if (sdf >= 0.0) continue;

        int paintOffset = int(u_primitiveData[offset + 1]);
        float paintType = u_paintData[paintOffset];
        if (paintType == 1.0) {
            color = paintSolid(sdf, paintOffset, color, ray);
        }
    }
    return color;
}

void main() {
    float value = 0.0;
    float alpha = 0.0;

    vec2 ray = vec2(gl_FragCoord) - u_resolution * 0.5;;

    outColor = vec4(0.0);
    for (int i = 0; i < SAMPLES; i++) {
        outColor += 1.0 / float(SAMPLES) * rayTrace(ray, vec4(1.0, 1.0, 1.0, 0.0));
        randomOffset += 1435.0;
    }

    outColor.rgb *= outColor.a;
}