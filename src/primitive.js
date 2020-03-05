/**
 * @typedef Transform number[6]
 */

/**
 * @typedef Paint Object
 * @property {string} type
 * @property {number[]} attributes
 */

/**
 * @typedef Primitive Object
 * @property {string} type
 * @property {Paint} paint
 * @property {number[]} attributes
 * @property {Transform} [transform]
 */

const defaultPaint = makeSolidPaint(0.85, 0.9, 0.3, 1)


/**
 * @param {number} x
 * @param {number} y
 * @param {number} width
 * @param {number} height
 * @return {Primitive}
 */
export function makeBox(x, y, width, height) {
  return {type: 'box', attributes: [x, y, width, height], paint: defaultPaint}
}

/**
 * @param {number} x
 * @param {number} y
 * @param {number} radius
 * @return {Primitive}
 */
export function makeCircle(x, y, radius) {
  return { type: 'circle', attributes: [x, y, radius], paint: defaultPaint }
}

/**
 * @param {number} r
 * @param {number} g
 * @param {number} b
 * @param {number} a
 * @return {Paint}
 */
export function makeSolidPaint(r, g, b, a) {
  return { type: 'solid', attributes: [r, g, b, a] }
}

/**
 * @param {Primitive} primitive
 * @param {Paint} paint
 * @return {Primitive}
 */
export function applyPaint(primitive, paint) {
  return {
    ...primitive,
    paint
  }
}