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
 * @property {(number|Primitive)[]} attributes
 * @property {Transform} [transform]
 */

const defaultPaint = makeSolidPaint(0.65, 0.95, 0.4, 0.7)


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
 * @param {Primitive} p1
 * @param {Primitive} p2
 * @return {Primitive}
 */
export function makeUnion(p1, p2) {
  return {
    type: 'union',
    attributes: [p1, p2],
    paint: defaultPaint
  }
}

/**
 * @param {number} r
 * @param {number} g
 * @param {number} b
 * @param {number} a
 * @param {number} [scatter]
 * @return {Paint}
 */
export function makeSolidPaint(r, g, b, a, scatter) {
  return { type: 'solid', attributes: [r, g, b, a, scatter !== undefined ? scatter : 5] }
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