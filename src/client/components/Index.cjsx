Footer = require './Footer'
GameList = require './GameList'
Header = require './Header'

React = require 'react/addons'
Link = require('react-router').Link

Index = React.createClass

	propTypes:
		socket: React.PropTypes.object.isRequired

	render: ->

		<div>

			<Header animated=true />

			<GameList {...@props} />

			<Link to='create'>
				<button className="create-game">
					Create a new Game
				</button>
			</Link>

			<Footer />

		</div>

module.exports = Index
