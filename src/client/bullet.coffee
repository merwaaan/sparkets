boxedMixin = require './boxed'
ExplosionEffect = require './explosionEffect'

class Bullet

  boxedMixin.call @prototype

  onstructor: (@client, bullet) ->
    @clientPoints = []

    @serverUpdate bullet

    @color = @client.gameObjects[@ownerId].color

  serverUpdate: (bullet) ->
    utils.deepMerge bullet, @
    @clientPoints.push @lastPoint

  update: () ->
    @clientPoints.shift() if @serverDelete or @clientPoints.length > @client.maxBulletLength
    @clientDelete = yes if @serverDelete and @clientPoints.length == 0

  inView: (offset = {x: 0, y: 0}) ->
    # Bullets are culled from view on a segment basis in @draw
    true

  bulletWarp: (x1, y1, x2, y2) ->
    Math.abs(x1 - x2) > 50 or
      Math.abs(y1 - y2) > 50

  segmentInView: (x1, y1, x2, y2, offset = {x: 0, y: 0}) ->
    @client.inView(x1 + offset.x, y1 + offset.y) or
      @client.inView(x2  + offset.x, y2 + offset.y)

  drawSegment: (ctx, x1, y1, x2, y2, alpha1, alpha2) ->

    gradient = ctx.createLinearGradient x1, y1, x2, y2
    gradient.addColorStop 0, utils.color(@color, alpha1 / 1.85)
    gradient.addColorStop 1, utils.color(@color, alpha2 / 1.85)

    ctx.lineWidth = @client.serverPrefs.bullet.hitWidth - 1 / alpha2
    ctx.strokeStyle = gradient
    ctx.beginPath()
    ctx.moveTo x1, y1
    ctx.lineTo x2, y2
    ctx.stroke()

  drawActiveSegment: (ctx, x1, y1, x2, y2, alpha1, alpha2) ->

    gradient = ctx.createLinearGradient x1, y1, x2, y2
    gradient.addColorStop 0, utils.color(@color, alpha1)
    gradient.addColorStop 1, utils.color(@color, alpha2)

    ctx.lineWidth = @client.serverPrefs.bullet.hitWidth
    ctx.strokeStyle = gradient
    ctx.beginPath()
    ctx.moveTo x1, y1
    ctx.lineTo x2, y2
    ctx.stroke()

    # Let there be light!

    ctx.globalCompositeOperation = 'source-atop'
    r = @power * 40
    x = (x1 + x2) / 2
    y = (y1 + y2) / 2
    gradient = ctx.createRadialGradient x, y, 0, x, y, r

    gradient.addColorStop 0.3, "hsla(#{ @color[0] }, #{ @color[1] }%, 60%,.8)"
    gradient.addColorStop 1, "hsla(#{ @color[0] },70%,100%,0)"
    ctx.fillStyle = gradient
    ctx.beginPath()
    ctx.arc x, y, r, 0, Math.PI*2
    ctx.fill()

  draw: (ctx, offset = {x:0, y:0}) ->

    ctx.globalCompositeOperation = 'destination-over'

    p = @clientPoints
    x1 = p[0][0]
    y1 = p[0][1]

    for i in [1...p.length]
      x2 = p[i][0]
      y2 = p[i][1]

      draw = if i is p.length-1 then @drawActiveSegment else @drawSegment
      draw = @drawSegment if @serverDelete

      if not @bulletWarp x1, y1, x2, y2
        if @segmentInView x1, y1, x2, y2, offset
          draw.call @, ctx, x1, y1, x2, y2, (i-1)/p.length, i/p.length
      else
        unwarped = utils.unwarp({x: x1, y: y1}, {x: x2, y: y2}, @client.mapSize)
        draw.call @, ctx, x1, y1, unwarped.x, unwarped.y, (i-1)/p.length, i/p.length

      x1 = x2
      y1 = y2

  explosionEffect: () ->

    pos =
      x: @lastPoint[0]
      y: @lastPoint[1]

    @client.effects.push new ExplosionEffect @client, pos, @color, 20, 4


module.exports = Bullet
