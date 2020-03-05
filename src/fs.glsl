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

// from https://www.shadertoy.com/view/lsf3WH
float hash(vec2 p)  // replace this by something better
{
    p  = 50.0*fract( p*0.3183099 + vec2(0.71,0.113));
    return -1.0+2.0*fract( p.x*p.y*(p.x+p.y) );
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ),
    hash( i + vec2(1.0,0.0) ), u.x),
    mix( hash( i + vec2(0.0,1.0) ),
    hash( i + vec2(1.0,1.0) ), u.x), u.y);
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
    //return sdf1 + sdf2;
    float k = 10.0;
    float h = clamp(0.5 + 0.5 * (sdf2 - sdf1) / k, 0.0, 1.0);
    return mix(sdf2, sdf1, h) - k * h * (1.0 - h);
}

vec4 paintSolid(float sdf, int offset, vec4 previous, inout vec2 p) {
    vec4 color = vec4(
        u_paintData[offset + 1],
        u_paintData[offset + 2],
        u_paintData[offset + 3],
        u_paintData[offset + 4] * smoothstep(1.0, -1.0, sdf)
    );
    float alpha = clamp(0.0, 1.0, color.a + previous.a);
    float scatter = u_paintData[offset + 5];
    float noiseX = noise(p * 110.0 + randomOffset);
    float noiseY = noise(p * -130.0 + randomOffset);
    p.x += noiseX * noiseX * sign(noiseX) * scatter;
    p.y += noiseY * noiseY * sign(noiseY) * scatter;
    return vec4(color.rgb * previous.rgb, alpha);
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