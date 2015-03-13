Ship = require('../ship')

React = require 'react'

Scoreboard = React.createClass

  propTypes:
    ships: React.PropTypes.object.isRequired

  render: ->

    rows = (<ScoreboardRow
      index={0}
      name={ship.name}
      kills={ship.stats.kills}
      deaths={ship.stats.deaths}
      score={ship.stats.kills - ship.stats.deaths} /> for id, ship of @props.ships)

    ### TODO
    # Sort scores.
    scores.sort( (a, b) -> b.score - a.score)

    for i in [0...scores.length]
      s = scores[i]
      cssColor = 'hsl('+s.color[0]+','+s.color[1]+'%,'+s.color[2]+'%)'
      @scoreTable.append(
          '<tr><td>' + (i+1) + '</td>' +
          '<td><span class="colorBullet" style="background-color: ' + cssColor + '">&nbsp;</span>' + s.name + '</span></td>' +
          '<td>' +  s.deaths + '</td>' +
          '<td>' +  s.kills + '</td>' +
          '<td>' + s.score + '</td></tr>')
    ###

    <table className='scoreboard'>
      <thead>
        <tr>
          <th>#</th>
          <th></th>
          <th><img src="/img/iconDeath.svg" alt="Deaths" width="30"/></th>
          <th><img src="/img/iconKill.svg" alt="Kills" width="30"/></th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {rows}
      </tbody>
    </table>


ScoreboardRow = React.createClass

  propTypes:
    index: React.PropTypes.number.isRequired
    name: React.PropTypes.string.isRequired
    kills: React.PropTypes.number.isRequired
    deaths: React.PropTypes.number.isRequired
    score: React.PropTypes.number.isRequired

  render: ->
    <tr>
      <td># {@props.index + 1}</td>
      <td>{@props.name}</td>
      <td>{@props.kills}</td>
      <td>{@props.deaths}</td>
      <td>{@props.score}</td>
    </tr>


module.exports = Scoreboard
