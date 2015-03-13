Client = require '../client'
Ship = require '../ship'
utils = require '../../utils'

React = require 'react'

Chat = React.createClass

  propTypes:
    client: React.PropTypes.instanceOf(Client).isRequired
    maxMessages: React.PropTypes.number

  getDefaultProps: ->
    maxMessages: 5

  getInitialState: ->
    opened: false
    messages: []

  render: ->

    inputStyle = {visibility: if @state.opened then 'visible' else 'hidden'}

    messages = <Message
      data={data}
      ship={@props.client.ships[data.shipId]} /> for data in @state.messages

    <section className='chat'>

      <input ref='input'
        type='text'
        style={inputStyle} />

      <div className='messages'>
        {messages}
      </div>

    </section>

  componentDidMount: () ->

    @input = @refs.input.getDOMNode()

    # Server events
    @props.client.socket.on 'player says', @onPlayerSays

    # Keyboard events
    document.addEventListener 'keyup', ({keyCode}) =>

      # T: open the chat
      if keyCode is 84 and not @state.opened
        @open()

      # Esc: close the chat
      else if keyCode is 27 and @state.opened
        @close()

      # Enter: send message
      else if keyCode is 13 and @state.opened
        @send @input.value
        @close()

  componentWillUnmount: ->

    @props.client.socket.removeListener 'player says', @onPlayerSays

  open: () ->
    @setState {opened: true}
    @input.value = ''
    @input.focus()

  close: () ->
    @setState {opened: false}
    @input.blur()

  send: (message) ->
    if message.length > 0
      @props.client.socket.emit 'player says',
        message: message

  onPlayerSays: (data) ->

    messages = @state.messages.slice()
    messages.push data

    if messages.length > @props.maxMessages
      messages.pop()

    @setState {messages: messages}


Message = React.createClass

  propTypes:
    ship: React.PropTypes.instanceOf(Ship).isRequired
    data: React.PropTypes.shape(
      shipId: React.PropTypes.number
      message: React.PropTypes.string
    ).isRequired

  render: ->
    <span style={{color: utils.color(@props.ship.color)}}>
      {@props.ship.name}
      <img width='30px' src='/img/iconTalk.svg' />
      {@props.data.message}
    </span>


module.exports = Chat
