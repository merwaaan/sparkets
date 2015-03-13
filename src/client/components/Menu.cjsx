Countdown = require './Countdown'
Customization = require './Customization'
Scoreboard = require './Scoreboard'
Client = require '../client'

React = require 'react'
Router = require 'react-router'

Menu = React.createClass

  propTypes:
    client = React.PropTypes.instanceOf(Client).isRequired

  getInitialState: ->
    opened: true

  render: ->

    style =
      display: if @state.opened then 'block' else 'none'

    <section className='menu'
      style={style}>

      <h1>Sparkets!</h1>

      <Countdown
        startTime={@props.client.gameStartTime}
        duration={@props.client.gameDuration} />

      <Scoreboard
        ships={@props.client.ships}/>

      <Customization
        client={@props.client} />

      <div className='buttons'>
        <button onClick={@close}>Resume</button>
        <Router.Link to='/'><button>Quit</button></Router.Link>
      </div>
    </section>

  componentDidMount: ->

    # Tab: toggle the menu
    document.addEventListener 'keydown', (event) =>
      if event.keyCode is 9
        event.preventDefault()
        if not @state.opened then @open() else @close()

    # Render on connection, to bind server data to
    # the countdown and the customization panel
    @props.client.socket.on 'connected', () =>
      @forceUpdate()
      # XXX not working because of wrong callback order

  open: () ->
    @setState {opened: true}

  close: () ->
    @setState {opened: false}


module.exports = Menu


###

  open: () ->
    @updateScores()

    @updateTime()
    @clockInterval = setInterval( (() =>
      @updateTime()), 1000)

    # Make the cursor constantly visible when
    # the menu is open.
    @client.staticCursorMode()

    @menu.removeClass('hidden')
    @menu.addClass('visible')

  close: () ->
    @menu.removeClass('visible')
    @menu.addClass('hidden')

    clearInterval(@clockInterval)

    # The cursor disappears after some time
    # when the menu is closed.
    @client.disappearingCursorMode()

  isOpen: () ->
    @menu.hasClass('visible')


  updatePreview: (color) ->
    # Change the color of the ship preview.
    style = @shipPreview.attr('style')

    style = style.replace(/stroke: [^\n]+/,
      'stroke: hsl('+color[0]+','+color[1]+'%,'+color[2]+'%);')

    @shipPreview.attr('style', style)

###