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

	#getInitialState: ->

	render: ->

		label = (quantity) =>
			_.find @labels, (label, index) ->
				quantity <= index * 0.25

		<div>

			<canvas ref='canvas'
				width='100'
				height='100'>
			</canvas>

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
