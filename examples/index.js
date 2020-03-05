import {createRenderer, renderScene} from '../src'
import {addPrimitive, createScene} from '../src/scene'

const renderer = createRenderer(document.getElementById('example-1'))

let scene = createScene()
scene = addPrimitive(scene, {type: 'circle', attributes: [-40, 0, 50]})
scene = addPrimitive(scene, {type: 'box', attributes: [40, 0, 100, 100]})

renderScene(renderer, scene)