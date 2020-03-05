import {createProgramFromSources, resizeCanvasToDisplaySize} from './utils'
import fs from './fs.glsl'
import vs from './vs.glsl'

const CIRCLE_PRIMITIVE = 1
const BOX_PRIMITIVE = 2
const UNION_OPERATOR = 10

/**
 * @param {string} type
 */
function getPrimitiveConst(type) {
  switch (type) {
    case 'circle':
      return CIRCLE_PRIMITIVE
    case 'box':
      return BOX_PRIMITIVE
    case 'union':
      return UNION_OPERATOR
  }
}

/**
 * @typedef Renderer Object
 * @property {WebGL2RenderingContext} gl
 * @property {WebGLProgram} program
 */

/**
 * @param {HTMLElement} htmlElement Container element for the scene; sizing will be kept
 * @return {Renderer} renderer
 */
export function createRenderer(htmlElement) {
  const canvas = document.createElement('canvas')
  canvas.style.width = '100%'
  canvas.style.height = '100%'
  htmlElement.appendChild(canvas)

  /**
   * @type {WebGLRenderingContext}
   */
  const gl = canvas.getContext('webgl2')

  // setup GLSL program
  const program = createProgramFromSources(gl, [vs, fs])

  return {
    gl,
    program
  }
}

/**
 * @param {Renderer} renderer
 * @param {Scene} scene
 */
export function renderScene(renderer, scene) {
  const gl = renderer.gl;
  const program = renderer.program;

  // uniform locations
  const resolutionLoc = gl.getUniformLocation(program, 'u_resolution')
  const primitiveCountLoc = gl.getUniformLocation(program, 'u_primitiveCount')
  const primitivesDataLoc = gl.getUniformLocation(program, 'u_primitiveData')
  const primitivesOffsetsLoc = gl.getUniformLocation(program, 'u_primitiveOffsets')

  // primitives arrays
  const primitives = new Float32Array(
    scene.primitives.reduce((prev, curr) => [...prev, getPrimitiveConst(curr.type), ...curr.attributes], [])
  )

  let offset = 0
  const primitivesOffsets = new Int32Array(
    scene.primitives.reduce((prev, curr) => {
      const result = [...prev, offset]
      offset += curr.attributes.length + 1
      return result
    }, [])
  )

  resizeCanvasToDisplaySize(gl.canvas)
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)

  gl.useProgram(program)

  // set uniforms
  gl.uniform2f(resolutionLoc, gl.canvas.width, gl.canvas.height)
  gl.uniform1i(primitiveCountLoc, scene.primitives.length)

  gl.uniform1fv(primitivesDataLoc, primitives)
  gl.uniform1iv(primitivesOffsetsLoc, primitivesOffsets)

  // draw
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
}