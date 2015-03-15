utils = require '../utils'

animationCurve = utils.cubicBezier(
  utils.vec.point(1,0),
  utils.vec.point(0,0),
  utils.vec.point(1,1),
  utils.vec.point(0,1))

class FlashEffect

  constructor: (@client, @pos, @radius, @color, @duration) ->
    @start = @client.now
    @end = @start + @duration

  update: () ->

  deletable: () ->
    @client.now > @end

  inView: (offset = {x:0, y:0}) ->
    @client.boxInView @pos.x + offset.x, @pos.y + offset.y, @radius

  draw: (ctx, offset = {x:0, y:0}) ->

    t = animationCurve((@client.now - @start) / @duration).y
    ctx.fillStyle = utils.color @color, t

    ctx.beginPath()
    ctx.arc @pos.x, @pos.y, @radius, 0, 2*Math.PI, false
    ctx.fill()


module.exports = FlashEffect
