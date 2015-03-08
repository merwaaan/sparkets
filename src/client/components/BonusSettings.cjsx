React = require 'react/addons'
_ = require('lodash') # remove lodash

BonusSettings = React.createClass

	labels: [
		'None' # == 0
		'Few' # <= 0.25
		'Average' # <= 0.5
		'Lots' # <= 0.75
		'Unreasonnable' # == 1
	]

	donut: (size, from, to, width) ->

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

		<svg width={size} height={size}>
			<path d={d} fill='none' stroke='black'></path>
		</svg>

	render: ->

		label = (quantity) =>
			_.find @labels, (label, index) ->
				quantity <= index * 0.25

		<div className='bonus-settings'>

			<div>

				<canvas ref='canvas'
					width='100'
					height='100'>
				</canvas>

				{@donut 200, 0.1, 0.9, 0.35}

			</div>

			<input
				type='range'
				value={@props.quantity}
				min=0
				max=1
				step=0.05
				onChange={() => @props.onChangeQuantity(event.target.value)} />

			{label @props.quantity}

		</div>

	componentDidMount: ->

		sprite = @props.spriteManager.get(@props.type, 50, 50, 'black')
		ctx = @refs.canvas.getDOMNode().getContext('2d')
		ctx.drawImage(sprite, 0, 0)


module.exports = BonusSettings
