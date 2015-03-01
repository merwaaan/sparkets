BonusSettings = require('./BonusSettings')
WorldSettings = require('./WorldSettings')
spriteManager = require('../spriteManager')
_ = require('lodash')

GameSettings = React.createClass

	getInitialState: ->
		name: 'Game name'
		bonus:
			mine: 0.5
			tracker: 0.5
			boost: 0.5
			shield: 0.5
			EMP: 0.5
			grenade: 0.5

	componentWillMount: ->

		@spriteManager = new spriteManager()

	render: ->

		bonuses = _.map @state.bonus, (quantity, name) =>
			<BonusSettings
				type={'bonus' + name.charAt(0).toUpperCase() + name.slice(1)}
				quantity={quantity}
				spriteManager={@spriteManager}
				onChangeQuantity={_.partial @changeQuantity, name}/>

		<div>

			<div id='world'>
				<WorldSettings />
			</div>

			<div id='bonus'>
				{bonuses}
			</div>

			<div id='misc'>
			</div>

		</div>

	componentDidMount: ->

		# Connect to server
		socket = io.connect()

		socket.on 'connect', () ->
			# Do something?

		socket.on 'game already exists', () ->
			$('#error').html('Name already exists')

		socket.on 'game created', (data) ->
			# Redirect to the client page.
			window.location.replace('../play/#' + data.id)

		socket.on 'game list', (data) ->
			idList = Object.keys(data)
			if idList.length > 0
				gameListRegexp = new RegExp('^(' + idList.join('|') + ')$')
			else
				gameListRegexp = null

	changeQuantity: (name, quantity) ->
		newState = _.cloneDeep @state
		newState.bonus[name] = quantity
		@setState newState


module.exports = GameSettings
