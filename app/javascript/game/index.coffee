MARGIN_PIXELS = 5;

window.PIXI = require('pixi.js')
PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;
#PIXI.SCALE_MODES.DEFAULT = PIXI.SCALE_MODES.NEAREST;
window.app = new PIXI.Application({
  width: window.innerWidth,
  height: window.innerHeight
#  resolution: 1
})




document.querySelector('#frame').appendChild(app.view)


import spaceImage from '../images/space_128.gif'

# create a texture from an image path
texture = PIXI.Texture.from(spaceImage)

# /* create a tiling sprite ...
#  * requires a texture, a width and a height
#  * in WebGL the image size should preferably be a power of two
#  */
tilingSprite = new PIXI.TilingSprite(
  texture,
  app.screen.width,
  app.screen.height,
)
app.stage.addChild(tilingSprite)


spaceTilingX = 0
spaceTilingY = 0
lastUuid = null
tilingShiftScale = null
app.ticker.add((elapsed) ->
  tilingShiftScale *= 1.015
  spaceTilingX += .017 * tilingShiftScale
  spaceTilingY += .002 * tilingShiftScale

  tilingSprite.tilePosition.x = Math.floor(spaceTilingX)
  tilingSprite.tilePosition.y = Math.floor(spaceTilingY)

  callback(elapsed) for callback in updateCallbacks
)


container = new PIXI.Container()

app.stage.addChild(container);

import floorImage from '../images/floor_basic_8.gif'

texture = PIXI.Texture.from(floorImage)

shaderFrag = "
precision mediump float;

varying vec2 vTextureCoord;
varying vec4 vColor;

uniform sampler2D uSampler;
uniform float colorAmount;
uniform bool isRed;
uniform float time;

void main(void)
{
  vec2 uvs = vTextureCoord.xy;

  vec4 fg = texture2D(uSampler, vTextureCoord);
  float val = (fg.r+fg.g+fg.b) / 3.;
  float power = colorAmount * 2. + 1.;

  if (colorAmount > .8) {
    float extra = colorAmount - .8;

    power += 4. * extra*(.5 + sin(-vTextureCoord.x * 20. + 20.*sin(time / 40.) / 5.) / 2.);
    power += 4. * extra*(.5 + sin(-vTextureCoord.y * 10. + time / 30.) / 2.);
  }

  vec4 outp;
  if (isRed) {
    outp = vec4(pow(val,1./power),pow(val,power),pow(val,power),fg.a);
  } else {
    outp = vec4(pow(val,power),pow(val,power),pow(val,1./power),fg.a);
  }

  gl_FragColor = outp;
}
"

updateCallbacks = []

for col in [0..9]
  for row in [0..9]
    tile = new PIXI.Sprite(texture)
    tile.x = col * 8
    tile.y = row * 8
    do (filter = new PIXI.Filter(null, shaderFrag, {isRed: Math.random() < 0.5, colorAmount: Math.random(), time: 0})) ->
      # filter.autofit = false
      # filter.padding = 0
      updateCallbacks.push((elapsed) ->
        filter.uniforms.time += elapsed)
      tile.filters = [filter];
      container.addChild(tile)

container.x = MARGIN_PIXELS
container.y = MARGIN_PIXELS



import mobImage from '../images/mob_8.gif'
mobTexture = PIXI.Texture.from(mobImage)

import floorSelectionImage from '../images/floor_selection_8.gif'
floorSelectionTexture = PIXI.Texture.from(floorSelectionImage)

mobContainer = new PIXI.Container()

app.stage.addChild(mobContainer)

currentRound = null

window.GameAdapter.onNewRound = (data) ->
  mobContainer.destroy(children: true)
  mobContainer = new PIXI.Container()
  app.stage.addChild(mobContainer)
  # for child in mobContainer.children
  #   child.destroy()

  for participant in data.participants
    mob = new PIXI.Sprite(mobTexture)
    mob.x = participant.x * 8 + MARGIN_PIXELS
    mob.y = participant.y * 8 + MARGIN_PIXELS
    mobContainer.addChild(mob)

  if data.moves
    for move in data.moves
      m = new PIXI.Sprite(floorSelectionTexture)
      m.x = move.x * 8 + MARGIN_PIXELS
      m.y = move.y * 8 + MARGIN_PIXELS
      m.interactive = true
      m.buttonMode = true
      m.on('pointerdown', move.onClick)
      mobContainer.addChild(m)

  currentRound = data
  tilingShiftScale = 1.0

# Resize function window
resize = () ->
  # Get the parent
  parent = app.view.parentNode

  # Resize the renderer
  app.renderer.resize(window.innerWidth, window.innerHeight)

  # Scale the renderer to fit 128x128 plus extra on the bottom or right
  narrowest = Math.min(parent.clientWidth, parent.clientHeight)
  app.stage.scale.set(narrowest / (80 + MARGIN_PIXELS * 2))

# Listen for window resize events
window.addEventListener('resize', resize)

resize()
