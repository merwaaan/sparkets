React = require 'react'

WorldSettings = React.createClass

	render: ->

		<div className='world-settings'>

			Duration
			<input type='range' />

			Planet density
			<input type='range' />

		</div>


module.exports = WorldSettings
