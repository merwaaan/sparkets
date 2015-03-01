GameList = require('./components/GameList')
Header = require('./components/Header')

$(document).ready () ->

	React.render(React.createElement(Header), document.querySelector('header'))
	React.render(React.createElement(GameList), document.querySelector('#game-list'))

	$('button#create-game').click () ->
		window.location = '/create/'
