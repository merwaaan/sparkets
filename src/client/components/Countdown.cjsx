React = require 'react/addons'

Countdown = React.createClass

	propTypes:
		startTime: React.PropTypes.number.isRequired
		duration: React.PropTypes.number.isRequired

	getInitialState: ->
		minutes: 0
		seconds: 0

	render: ->

		if @validProps()
			countdown = @state.minutes + ':' + @state.seconds
		else
			countdown = '...'

		<span className='countdown'>
			{countdown}
		</span>

	componentDidMount: ->
		@update()
		@timerInterval = setInterval @update, 1000

	componentWillUnmount: ->
		clearInterval @timerInterval

	validProps: ->
		@props.startTime? and @props.duration?

	update: ->

		return if not @validProps()

		remaining = new Date @props.duration - (Date.now() - @props.startTime)

		@setState
			minutes: pad remaining.getMinutes()
			seconds: pad remaining.getSeconds()


pad = (t) ->
	if t.toString().length is 1 then '0' + t else t


module.exports = Countdown
