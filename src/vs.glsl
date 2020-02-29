#version 300 es
void main() {
    gl_Position = vec4(gl_VertexID >> 1, gl_VertexID & 1, 0.0, 1.0) * 2.0 - 1.0;
}