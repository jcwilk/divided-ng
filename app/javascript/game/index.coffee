MARGIN_PIXELS = 5;

window.PIXI = require('pixi.js')

window.app = new PIXI.Application({
  width: window.innerWidth,
  height: window.innerHeight
#  resolution: 1
})

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;

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

count = 0

# tilingSprite.tileScale.x = 10
# tilingSprite.tileScale.y = 10

spaceTilingX = 0
spaceTilingY = 0
app.ticker.add(() ->
  count += 0.005

  # tilingSprite.tileScale.x = 2 + Math.sin(count)
  # tilingSprite.tileScale.y = 2 + Math.cos(count)

  spaceTilingX += .01
  spaceTilingY += .002

  tilingSprite.tilePosition.x = Math.floor(spaceTilingX)
  tilingSprite.tilePosition.y = Math.floor(spaceTilingY)
)



container = new PIXI.Container()

app.stage.addChild(container);

import floorImage from '../images/floor_basic_8.gif'

texture = PIXI.Texture.from(floorImage)

for col in [0..9]
  for row in [0..9]
    tile = new PIXI.Sprite(texture)
    tile.x = col * 8
    tile.y = row * 8
    container.addChild(tile)

container.x = MARGIN_PIXELS
container.y = MARGIN_PIXELS



import mobImage from '../images/mob_8.gif'
mobTexture = PIXI.Texture.from(mobImage)

import floorSelectionImage from '../images/floor_selection_8.gif'
floorSelectionTexture = PIXI.Texture.from(floorSelectionImage)

mobContainer = new PIXI.Container()

app.stage.addChild(mobContainer)

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
