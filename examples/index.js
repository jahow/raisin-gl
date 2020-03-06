import {
  addPrimitive,
  applyPaint,
  createRenderer,
  createScene,
  makeBox,
  makeCircle,
  makeSolidPaint, makeUnion,
  renderScene
} from '../src'

const renderer = createRenderer(document.getElementById('example-1'))

let scene = createScene()
scene = addPrimitive(scene, makeUnion(
  makeCircle(-30, -15, 50),
  makeCircle(30, -22, 30)
))
scene = addPrimitive(scene,
  applyPaint(
    makeBox(25, 15, 100, 100),
    makeSolidPaint(0.45, 0.88, 1, 0.7)
  )
)
scene = addPrimitive(scene,
  applyPaint(
    makeBox(68, 15, 120, 70),
    makeSolidPaint(1, 0.2, 0.1, 0.7)
  )
)

renderScene(renderer, scene)