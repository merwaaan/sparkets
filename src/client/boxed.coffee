mixin = () ->

  @drawHitbox = (ctx) ->

    return if not @hitBox?

    ctx.strokeStyle = 'red'
    ctx.lineWidth = 2

    switch @hitBox.type

      when 'circle'

        utils.strokeCircle ctx, @hitBox.x, @hitBox.y, @hitBox.radius

      when 'segments', 'polygon'

        ctx.beginPath()
        ctx.moveTo @hitBox.points[0].x, @hitBox.points[0].y

        for i in [1...@hitBox.points.length]
          ctx.lineTo @hitBox.points[i].x, @hitBox.points[i].y

        ctx.closePath() if @hitBox.type is 'polygon'
        ctx.stroke()

  @drawBoundingBox = (ctx) ->

    return if not @boundingBox?

    ctx.strokeStyle = 'blue'
    ctx.lineWidth = 2.5

    r = @boundingBox.radius
    d = 2*r
    ctx.strokeRect @boundingBox.x - r, @boundingBox.y - r, d, d

  return @


module.exports = mixin
