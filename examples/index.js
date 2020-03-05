import {
  addPrimitive,
  applyPaint,
  createRenderer,
  createScene,
  makeBox,
  makeCircle,
  makeSolidPaint,
  renderScene
} from '../src'

const renderer = createRenderer(document.getElementById('example-1'))

let scene = createScene()
scene = addPrimitive(scene, makeCircle(-25, -15, 50))
scene = addPrimitive(scene,
  applyPaint(
    makeBox(25, 15, 100, 100),
    makeSolidPaint(0.4, 0.8, 0.9, 1)
  )
)

renderScene(renderer, scene)