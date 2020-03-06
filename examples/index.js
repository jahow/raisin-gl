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
scene = addPrimitive(scene,
  applyPaint(
    makeUnion(
      makeCircle(-30, -15, 50),
      makeCircle(30, -22, 30)
    ),
    makeSolidPaint(0.9059, 0.4431, 0.4902, 0.8)
))
scene = addPrimitive(scene,
  applyPaint(
    makeBox(25, 15, 100, 100),
    makeSolidPaint(0.6863, 0.8235, 0.4589, 0.8)
  )
)
scene = addPrimitive(scene,
  applyPaint(
    makeBox(68, 15, 120, 70),
    makeSolidPaint(39/255, 198/255, 210/255, 0.8)
  )
)

renderScene(renderer, scene)