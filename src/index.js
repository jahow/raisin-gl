import {createProgramFromSources, resizeCanvasToDisplaySize} from './utils'
import fs from './fs.glsl'
import vs from './vs.glsl'

const CIRCLE_PRIMITIVE = 1;
const BOX_PRIMITIVE = 2;

/**
 * @param {HTMLElement} htmlElement Container element for the scene; sizing will be kept
 */
export function createScene(htmlElement) {
  const canvas = document.createElement('canvas');
  canvas.style.width = '100%';
  canvas.style.height = '100%';
  htmlElement.appendChild(canvas);

  /**
   * @type {WebGLRenderingContext}
   */
  const gl = canvas.getContext('webgl2');

  // setup GLSL program
  const program = createProgramFromSources(gl, [vs, fs]);

  // uniform locations
  const resolutionLoc = gl.getUniformLocation(program, 'u_resolution');
  const primitiveCountLoc = gl.getUniformLocation(program, 'u_primitiveCount');
  const primitivesDataLoc = gl.getUniformLocation(program, 'u_primitiveData');
  const primitivesOffsetsLoc = gl.getUniformLocation(program, 'u_primitiveOffsets');

  // primitives arrays
  const primitives = new Float32Array([
    CIRCLE_PRIMITIVE, 30, 50, 80, // x, y, radius
    CIRCLE_PRIMITIVE, 270, 100, 50, // x, y, radius
    CIRCLE_PRIMITIVE, 400, 180, 30, // x, y, radius
    BOX_PRIMITIVE, 300, 350, 40, 60, // x, y, width, height
    BOX_PRIMITIVE, 20, 230, 10, 10, // x, y, width, height
  ]);
  const primitivesOffsets = new Int32Array([
    0,
    4,
    8,
    12,
    17,
  ]);

  resizeCanvasToDisplaySize(gl.canvas);
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

  gl.useProgram(program);

  // set uniforms
  gl.uniform2f(resolutionLoc, gl.canvas.width, gl.canvas.height);
  gl.uniform1i(primitiveCountLoc, 5);

  gl.uniform1fv(primitivesDataLoc, primitives);
  gl.uniform1iv(primitivesOffsetsLoc, primitivesOffsets);

  // draw
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
}