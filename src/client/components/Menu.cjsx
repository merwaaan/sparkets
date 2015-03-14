Countdown = require './Countdown'
Customization = require './Customization'
Scoreboard = require './Scoreboard'
Client = require '../client'

PubSub = require 'pubsub-js'
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

  open: () ->
    @setState {opened: true}

  close: () ->
    @setState {opened: false}


module.exports = Menu
