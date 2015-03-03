Create = require './Create'
Index = require './Index'
Play = require './Play'

Sparkets = React.createClass

	getInitialState: ->
		screen: 'index'

	render: ->
		switch @state.screen
			when 'index' then <Index onSwitch={@switch} />
			when 'create' then <Create onSwitch={@switch} />
			when 'play' then <Play onSwitch={@switch} />

	switch: (screen) ->
		@setState {screen: screen}

module.exports = Sparkets
