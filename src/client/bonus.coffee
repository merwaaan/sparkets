boxedMixin = require './boxed'
ExplosionEffect = require './explosionEffect'
DislocateEffect = require './dislocateEffect'
utils = require '../utils'

class Bonus

  boxedMixin.call(@prototype)

  constructor: (@client, bonus) ->
    @serverUpdate(bonus)

    @radius = 10

    # Draw the box sprite
    s = 2 * @radius
    color = utils.color @color
    @sprite = @client.spriteManager.get 'bonus', s, s, color

    # Draw the bonus logo on the box
    @logo = @client.spriteManager.get @bonusType, 13, 13, color
    @sprite.getContext('2d').drawImage @logo, @sprite.width/2 - @logo.width/2, @sprite.height/2 - @logo.height/2

  serverUpdate: (bonus) ->
    utils.deepMerge(bonus, @)

  update: () ->
    @clientDelete = @serverDelete

  inView: (offset = {x:0, y:0}) ->
    @state isnt 'incoming' and
      @client.boxInView @pos.x + offset.x, @pos.y + offset.y, @radius

  draw: (ctx) ->
    return if @state isnt 'available' and @state isnt 'claimed'

    # When the holder is invisible, do not draw the bonus.
    # If the client is the holder, make it slightly transparent
    if @state is 'claimed'
      holder = @client.ships[@holderId]
      if holder.invisible
        if holder is @client.localShip
          ctx.globalAlpha = 0.5
        else
          return

    ctx.save()
    ctx.translate @pos.x, @pos.y
    ctx.globalCompositeOperation = 'destination-over'
    ctx.drawImage @sprite, -@sprite.width/2, -@sprite.height/2
    ctx.restore()

  drawOnRadar: (ctx) ->
    return if @state isnt 'incoming'

    bestPos = @client.closestGhost(@client.localShip.pos, @pos)
    dx = bestPos.x - @client.localShip.pos.x
    dy = bestPos.y - @client.localShip.pos.y

    margin = 20

    # Draw the radar on the edges of the screen if the bonus is too far
    if Math.abs(dx) > @client.canvasSize.w/2 or Math.abs(dy) > @client.canvasSize.h/2
      rx = Math.max -@client.canvasSize.w/2 + margin, dx
      rx = Math.min @client.canvasSize.w/2 - margin, rx
      ry = Math.max -@client.canvasSize.h/2 + margin, dy
      ry = Math.min @client.canvasSize.h/2 - margin, ry

      # Scale the symbol with the inverse distance, but ensure a
      # minimum scale of 0.5
      dist = Math.sqrt(dx*dx + dy*dy) - Math.sqrt(rx*rx + ry*ry)
      halfMap = @client.mapSize/2
      distRatio = (halfMap - dist) / halfMap
      scale = Math.max(.5, distRatio)

      # <blink>radar</blink>
      if @client.now % 500 < 250
        @drawRadarSymbol(ctx, @client.canvasSize.w/2 + rx,
          @client.canvasSize.h/2 + ry, scale)

    # Draw an X on the future bonus position if it lies within the screen
    else if @client.now % 500 < 250
      rx = -@client.canvasSize.w/2 + bestPos.x - @client.view.x
      ry = -@client.canvasSize.h/2 + bestPos.y - @client.view.y

      @drawRadarSymbol ctx, @client.canvasSize.w/2 + rx, @client.canvasSize.h/2 + ry

    return true

  drawRadarSymbol: (ctx, x, y, scale = 1) ->
    ctx.save()
    ctx.fillStyle = utils.color @color
    ctx.translate x, y
    ctx.scale scale, scale
    ctx.rotate Math.PI/4
    ctx.fillRect -4, -10, 8, 20
    ctx.rotate Math.PI/2
    ctx.fillRect -4, -10, 8, 20
    ctx.restore()

  explosionEffect: () ->
    @client.effects.push new ExplosionEffect @client, @pos, @color, 50, 8

  openingEffect: () ->

    positions = [[0, -10], [10, 0], [0, 10], [-10, 0]]

    edges = []
    for i in [0..3]
      edges.push
        x: @pos.x + positions[i][0]
        y: @pos.y + positions[i][1]
        r: Math.PI/2 * i
        vx: positions[i][0] * 0.05 * Math.random()
        vy: positions[i][1] * 0.05 * Math.random()
        vr: (Math.random()*2-1) * 0.05
        size: 20

    @client.effects.push new DislocateEffect @client, edges, @color, 1000


module.exports = Bonus
