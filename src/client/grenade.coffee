boxedMixin = require './boxed'
FlashEffect = require './flashEffect'

class Grenade

  boxedMixin.call(@prototype)

  constructor: (@client, grenade) ->
    @serverUpdate(grenade)

    @color = @client.gameObjects[@ownerId].color

    # Create the sprite
    r = @client.serverPrefs.grenade.radius
    color = utils.color @color
    @sprite = @client.spriteManager.get 'grenade', r, r, color

  serverUpdate: (grenade) ->
    utils.deepMerge grenade, @

  update: () ->
    @clientDelete = @serverDelete

  draw: (ctx) ->
    return if @state is 'exploding' or @state is 'dead'

    ctx.save()
    ctx.translate @pos.x, @pos.y
    ctx.drawImage @sprite, -@sprite.width/2, -@sprite.height/2
    ctx.restore()

  inView: (offset = {x:0, y:0}) ->
    @client.boxInView @pos.x + offset.x, @pos.y + offset.y, @radius

  explosionEffect: () ->
    @client.effects.push new FlashEffect @client, @pos, 20, @color, 500


module.exports = Grenade
