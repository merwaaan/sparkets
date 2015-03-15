boxedMixin = require './boxed'

class Shield

  boxedMixin.call @prototype

  constructor: (@client, shield) ->
    @serverUpdate shield

    # Take owner's color
    @owner = @client.gameObjects[@ownerId]
    @color = @owner.color
    @pos = @owner.pos

    # Create the sprite
    @radius = @client.serverPrefs.shield.radius
    s = 2 * @radius
    color = utils.color @color
    @sprite = @client.spriteManager.get 'shield', s, s, color

  serverUpdate: (shield) ->
    utils.deepMerge shield, @

  update: () ->
    @clientDelete = @serverDelete

  inView: (offset = {x: 0, y: 0}) ->
    @client.boxInView @pos.x + offset.x, @pos.y + offset.y, @radius

  draw: (ctx) ->

    if @blink and
        @owner is @client.localShip and
        @client.now % 400 < 200
      ctx.globalAlpha = 0.3

    # When the holder is invisible, hide from other ships
    # and draw a special effect if the client is the holder
    if @owner.invisible
      if @owner is @client.localShip
        # Preserve blinking alpha
        ctx.globalAlpha = Math.min ctx.globalAlpha, 0.5
      else
        return

    ctx.save()
    ctx.translate @pos.x, @pos.y
    ctx.drawImage @sprite, -@sprite.width/2, -@sprite.height/2
    ctx.restore()


module.exports = Shield
