window.PIXI = require('pixi.js')

window.app = new PIXI.Application({
  width: window.innerWidth,
  height: window.innerHeight
#  resolution: 1
})

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;

document.querySelector('#frame').appendChild(app.view)

# Lets create a red square, this isn't
# necessary only to show something that can be position
# to the bottom-right corner
# rect = new PIXI.Graphics()
#   .beginFill(0xff0000)
#   .drawRect(-100, -100, 100, 100)

# # Add it to the stage
# app.stage.addChild(rect)



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

container.x = 5
container.y = 5





# Resize function window
resize = () ->
  # Get the parent
  parent = app.view.parentNode

  # Resize the renderer
  app.renderer.resize(window.innerWidth, window.innerHeight)

  # Scale the renderer to fit 128x128 plus extra on the bottom or right
  narrowest = Math.min(parent.clientWidth, parent.clientHeight)
  app.stage.scale.set(narrowest / 90)

# Listen for window resize events
window.addEventListener('resize', resize)

resize()
