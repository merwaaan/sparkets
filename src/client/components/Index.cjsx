Footer = require './Footer'
GameList = require './GameList'
Header = require './Header'

React = require 'react'
Link = require('react-router').Link

Index = React.createClass

  render: ->

    <div>

      <Header animated=true />

      <Link to='create'>
        <button className="create-game">
          Create a new Game
        </button>
      </Link>

      <Footer />

    </div>

module.exports = Index
