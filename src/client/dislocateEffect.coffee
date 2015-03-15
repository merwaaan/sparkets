class DislocateEffect

  constructor: (@client, @edges, @color, @duration) ->
    @start = @client.now
    @end = @start + @duration

  update: () ->
    for e in @edges
      e.x += e.vx
      e.y += e.vy
      e.r += e.vr

  deletable: () ->
    @client.now > @end

  inView: (offset = {x:0, y:0}) ->
    true

  draw: (ctx) ->

    ctx.strokeStyle = utils.color @color, 1-(@client.now-@start)/@duration

    for e in @edges
      ctx.lineWidth = e.lineWidth or 2
      ctx.save()
      ctx.translate e.x, e.y
      ctx.rotate e.r
      ctx.beginPath()
      ctx.moveTo -e.size/2, 0
      ctx.lineTo e.size/2, 0
      ctx.stroke()
      ctx.restore()


module.exports = DislocateEffect
