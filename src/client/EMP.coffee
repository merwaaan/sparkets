boxedMixin = require('./boxed')

class EMP

  boxedMixin.call(@prototype)

  constructor: (@client, emp) ->
    @serverUpdate(emp)

  serverUpdate: (emp) ->
    utils.deepMerge emp, @

  update: () ->
    @clientDelete = @serverDelete

  draw: (ctx) ->
    return if not @waves?

    ctx.save()
    ctx.translate @pos.x, @pos.y
    ctx.rotate Math.random() * Math.PI

    for i in [0...@waves.length]

      ctx.fillStyle = utils.color @color, 0.1 + Math.random() * 0.1

      ctx.beginPath()

      for j in [0...@waves[i].length]
        p = @waves[i][j]
        x = Math.cos(p.angle) * (@radius + p.offset)
        y = Math.sin(p.angle) * (@radius + p.offset)
        ctx.lineTo x, y

      ctx.closePath()
      ctx.fill()

    ctx.restore()

  inView: (offset = {x:0, y:0}) ->
    @client.boxInView @pos.x + offset.x, @pos.y + offset.y, @radius

  chargingEffect: () ->
    @client.effects.push new ChargingEffect(
      @client,
      @,
      @color,
      60,
      2500,
      200)

  wavesEffect: () ->
    @waves = []

    for i in [0...3]
      @waves.push []
      for a in [0...2*Math.PI] by Math.PI / 32
        @waves[i].push
          angle: a
          offset: Math.random() * 10 - 5


module.exports = EMP
