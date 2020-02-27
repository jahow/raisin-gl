/**
 *
 * @param {HTMLElement} htmlElement Container element for the scene; sizing will be kept
 */
import {createProgramFromSources, resizeCanvasToDisplaySize} from './utils'

export function createScene(htmlElement) {
  const canvas = document.createElement('canvas');
  canvas.style.width = '100%';
  canvas.style.height = '100%';
  htmlElement.appendChild(canvas);

  const gl = canvas.getContext('webgl2');

  const vs = `#version 300 es
void main() {
  gl_Position = vec4(gl_VertexID >> 1, gl_VertexID & 1, 0.0, 1.0) * 2.0 - 1.0;
}
`;

  const fs = `#version 300 es
precision mediump float;

uniform vec2 u_resolution;

out vec4 outColor;

void main() {
  outColor = vec4(1, gl_FragCoord.x / u_resolution.x, gl_FragCoord.y / u_resolution.y, 1);
}
`;

  // setup GLSL program
  const program = createProgramFromSources(gl, [vs, fs]);
  const resolutionLoc = gl.getUniformLocation(program, 'u_resolution');

  // draw
  resizeCanvasToDisplaySize(gl.canvas);
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

  gl.useProgram(program);

  gl.uniform2f(resolutionLoc, gl.canvas.width, gl.canvas.height);

  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
}