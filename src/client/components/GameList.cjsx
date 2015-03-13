Countdown = require './Countdown'

React = require 'react'
Router = require 'react-router'

GameList = React.createClass

  propTypes:
    socket: React.PropTypes.object.isRequired

  getInitialState: ->
    games: {}

  render: ->

    games = (<Game {...@props}
      key = {name}
      name={name}
      players={game.players}
      startTime={game.startTime}
      duration={game.duration * 60 * 1000} /> for name, game of @state.games)

    # If there is no available games, say so
    if games.length is 0
      games =
        <tr>
          <td colSpan=3>No games available</td>
        </tr>

    <table className='game-list'>
      <thead>
        <th>Name</th>
        <th>Players</th>
        <th>Time left</th>
      </thead>
      <tbody id="games">
        {games}
      </tbody>
    </table>

  componentDidMount: ->

    # Fetch the game list before mounting...
    @props.socket.emit 'get game list'

    # ... and then every minute
    @updateInterval = setInterval @update, 1000

    # Update the list of active games
    @props.socket.on 'game list', @onGameList

  componentWillUnmount: ->

    clearInterval @updateInterval

    @props.socket.removeListener 'game list', @onGameList

  update: ->
    @props.socket.emit 'get game list'

  onGameList: (data) ->
    @setState {games: data}


Game = React.createClass

  render: ->
    <tr>
      <td>
        <Router.Link to='play' params={{gameId: @props.name}}>
        {@props.name}
        </Router.Link>
      </td>
      <td>
        {@props.players}
      </td>
      <td>
        <Countdown
          startTime={@props.startTime}
          duration={@props.duration} />
      </td>
    </tr>


module.exports = GameList
