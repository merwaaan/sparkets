React = require 'react'
$ = require 'jquery'

GaugeMixin =

  propTypes:
    size: React.PropTypes.number
    from: React.PropTypes.number
    to: React.PropTypes.number
    thickness: React.PropTypes.number

  getDefaultProps: ->
    size: 200
    from: 0.1
    to: 0.9
    thickness: 0.35

  getInitialState: ->
    value: 0.5

  gauge: (size, from, to, width) ->

    radius = size / 2
    unit = Math.PI * 2
    from = from * unit
    to = to * unit
    big = if to - from > Math.PI then 1 else 0

    x0 = radius + radius * (1 - width) * Math.sin(from)
    y0 = radius + radius * (1 - width) * Math.cos(from)
    d = "M #{x0}, #{y0} "

    x1 = radius + radius * Math.sin(from)
    y1 = radius + radius * Math.cos(from)
    d += "L #{x1}, #{y1} "

    x2 = radius + radius * Math.sin(to)
    y2 = radius + radius * Math.cos(to)
    d += "A #{radius}, #{radius} 0 #{big} 0 #{x2}, #{y2} "

    x3 = x2 + (radius - x2) * width
    y3 = y2 + (radius - y2) * width
    d+= "L #{x3}, #{y3} "

    radius2 = (1 - width) * radius
    d += "A #{radius2}, #{radius2} 0 #{big} 1 #{x0}, #{y0}"

    <path d={d} fill='grey' onClick={@onClick}>
    </path>

  cursor: (value) ->

    radius = @props.size / 2
    a = (@props.to - value * (@props.to - @props.from)) * Math.PI * 2

    pos =
      x: radius + Math.sin(a) * 50
      y: radius + Math.cos(a) * 50

    <circle
      cx={pos.x}
      cy={pos.y}
      r=10
      fill='red'/>

  subrender: (before, after) ->

    <div className='gauge'>

      {before}

      <svg width={@props.size} height={@props.size}>
        {@gauge @props.size, @props.from, @props.to, @props.thickness}
        {@cursor @state.value}
      </svg>

      {after}

    </div>

  onClick: (event) ->

    event.preventDefault()

    radius = @props.size / 2
    unit = Math.PI * 2

    # Transform the click coordinates to a normalized quantity

    to =
      x: Math.sin(@props.to * unit) * 100
      y: Math.cos(@props.to * unit) * 100

    pos = $(event.target.parentNode).offset()
    click =
      x: (event.pageX - pos.left) - @props.size / 2
      y: (event.pageY - pos.top) - @props.size / 2

    angle = Math.atan2(to.y, to.x) - Math.atan2(click.y, click.x)
    angle += unit if angle < 0
    angle = (unit - angle) / (unit * (@props.to - @props.from))

    @setState {value: angle}


module.exports = GaugeMixin
