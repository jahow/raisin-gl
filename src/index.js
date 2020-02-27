/**
 *
 * @param {HTMLElement} htmlElement Container element for the scene; sizing will be kept
 */
export function createScene(htmlElement) {
  const canvas = document.createElement('canvas');
  canvas.style.width = '100%';
  canvas.style.height = '100%';
  htmlElement.appendChild(canvas);

  const gl = canvas.getContext('webgl2');
}