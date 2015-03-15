class ChargingEffect

  constructor: (@client, @obj, @color, @radius, @duration, @pause) ->

    @start = @client.now
    @end = @start + @duration

    # Particles are generated until @fakeEnd to create
    # a pause effect.
    @fakeEnd = @end - @pause

    @particles = []

  update: () ->

    @progress = (@client.now - @start) / (@fakeEnd - @start)

    # Instanciate new particles
    if @progress < 1 and Math.random() < 0.1 + @progress * 0.9 # Density increases as the animation progresses
      angle = Math.random() * 2 * Math.PI
      @particles.push
        x: @radius * Math.cos angle
        y: @radius * Math.sin angle
        s: 0.99 - @progress * 0.18 # Speed increases
        a: 0.1 + Math.random() * 0.5 # Opacity increases
        w: 1 + Math.random() * 3 * @progress # Width increases

    # Update existing particles
    for p in @particles
      p.x *= p.s
      p.y *= p.s

    # Delete particles that reached the center
    for i in [0...@particles]
      p = @particles[i]
      if p.x < 10 and p.y < 10
        @particles.splice(i, 1)

  deletable: () ->
    @client.now > @end and @particles.length is 0

  inView: (offset = {x:0, y:0}) ->
    # TODO?
    true

  draw: (ctx, offset = {x:0, y:0}) ->

    for p in @particles
      ctx.save()

      ctx.strokeStyle = utils.color @color, p.a
      ctx.lineWidth = p.w

      ctx.beginPath()
      ctx.moveTo @obj.pos.x + p.x * 1.3, @obj.pos.y  + p.y * 1.3
      ctx.lineTo @obj.pos.x + p.x, @obj.pos.y + p.y
      ctx.stroke()

      ctx.restore()


module.exports = ChargingEffect
