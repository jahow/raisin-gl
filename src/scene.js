/**
 * @typedef Transform number[6]
 */

/**
 * @typedef Primitive Object
 * @property {string} type
 * @property {number[]} attributes
 * @property {Transform} [transform]
 */

/**
 * @typedef Scene Object
 * @property {Array} primitives
 */


/**
 * @return {Scene} scene
 */
export function createScene() {
  return {
    primitives: []
  }
}

/**
 * @param {Scene} scene
 * @param {...Primitive} primitives
 * @return {Scene}
 */
export function addPrimitive(scene, ...primitives) {
  return {
    ...scene,
    primitives: [ ...scene.primitives, ...primitives]
  }
}

/**
 * @param {Scene[]} scenes
 * @return {Scene}
 */
export function mergeScenes(...scenes) {
  return {
    primitives: [].concat(scenes.map(scene => scene.primitives))
  }
}
