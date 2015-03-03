Chat = React.createClass

	getInitialState: ->
		opened: false

	render: ->

		inputStyle = {visibility: if @state.opened then 'visible' else 'hidden'}

		<div className='chat'>

			<div className='messages'>
			</div>

			<input ref='input'
				type='text'
				style={inputStyle} />

		</div>

	componentDidMount: () ->

		document.addEventListener 'keyup', ({keyCode}) =>

			#return if @client.menu.isOpen()

			# T: open the chat
			if keyCode is 84 and not @state.opened
				@open()

			# Esc: close the chat
			else if keyCode is 27 and @state.opened
				@close()

			# Enedtefalseend message
			else if keyCode is 13 and @state.opened
				@send(@input.val())
				@close()

	open: () ->
		@setState {opened: true}
		@refs.input.getDOMNode().value = ''
		@refs.input.getDOMNode().focus()

	close: () ->
		@setState {opened: false}
		@refs.input.getDOMNode().blur()

	send: (message) ->
		@client.socket.emit 'message',
				message: message

	display: (data) ->
		###
		colorize = (text, color) ->
			'<span style="color:hsl('+color[0]+','+color[1]+'%,'+color[2]+'%)">'+text+'</span>'

		name = @client.ships[data.id].name
		color = @client.ships[data.id].color
		img = '<img width="30" src="/img/iconTalk.svg"/>'
		message = colorize(name, color) + ' ' + img + ' "' + data.message + '"'

		# Append the message to the chat.
		line = $('<div style="display:none">' + message + '</div>').appendTo(@chat)
		line.fadeIn(300)

		# Program its disappearance.
		setTimeout( (() =>
			line.animate({opacity: 'hide', height: 'toggle'}, 300, () -> line.detach())),
			@displayDuration)
		###

module.exports = Chat
