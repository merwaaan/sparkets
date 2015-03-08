BonusSettings = require('./BonusSettings')
WorldSettings = require('./WorldSettings')
spriteManager = require('../spriteManager')

React = require 'react/addons'
_ = require 'lodash'

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

		bonuses = (<BonusSettings
			type={'bonus' + name.charAt(0).toUpperCase() + name.slice(1)}
			quantity={quantity}
			spriteManager={@spriteManager}
			onChangeQuantity={_.partial @changeQuantity, name}/> for name, quantity of @state.bonus)

		<div className='game-settings'>

			<div id='world'>
				<WorldSettings />
			</div>

			<div id='bonus'>
				{bonuses}
			</div>

			<div id='misc'>
			</div>

		</div>

	changeQuantity: (name, quantity) ->
		newState = _.cloneDeep @state
		newState.bonus[name] = quantity
		@setState newState


module.exports = GameSettings
