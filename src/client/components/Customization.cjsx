Client = require '../client'
Message = require '../../message'
utils = require '../../utils'

PubSub = require 'pubsub-js'
React = require 'react'
$ = require 'jquery'


Customization = React.createClass

  propTypes:
    client: React.PropTypes.instanceOf(Client).isRequired

  getInitialState: ->
    color: [0, 0, 0]
    name: 'Unnamed'

  render: ->

    circleStyle =
      fill: 'white'

    pathStyle =
      strokeWidth: 3
      stroke: utils.color @state.color
      strokeLinejoin: 'round'
      fill: 'white'

    <section className='customization'>

      <div ref='colorWheelBox'
        className='colorwheel-box'
        onMouseDown={@onWheelDown}>

        <svg>
          <g transform='translate(100,100) scale(2)'>
            <circle
              cx='0'
              cy='0'
              r='20%'
              style={circleStyle} />
            <path
              className='ship-preview'
              d='M -7 10 L 0 -10 L 7 10 L 0 6 Z'
              style={pathStyle} >
            </path>
          </g>
        </svg>

        <img ref='colorWheel'
          className='colorwheel'
          src='/img/colorWheel.png' />

        <img
          ref='colorCursor'
          className='cursor'
          src='/img/colorCursor.png' />

      </div>

      <form className='name-form'>

        <input ref='nameInput'
          className='name'
          type='text'
          value={@state.name}
          onChange={@changeName} />

        <input
          type='submit'
          value='Save'
          onClick={@savePreferences} />

      </form>

    </section>

  componentDidMount: ->
    @restoreLocalPreferences()

  onWheelDown: (event) ->

    wheel = @refs.colorWheel.getDOMNode()

    event.preventDefault()
    @pickColor(event)

    # Hold mouse down to choose color
    colorWheelListener = wheel.addEventListener 'mousemove', (event) =>
      event.preventDefault()
      @pickColor(event)

    # Remove listeners on release
    document.addEventListener 'mouseup', (event) =>
      wheel.removeEventListener 'mousemove', colorWheelListener

  # Compute a color from the colorwheel after a mouse event
  pickColor: (event) ->

    maxRadius = 100
    minRadius = 50
    maxLum = 80
    minLum = 30

    wheelBox = $(@refs.colorWheelBox.getDOMNode())
    center =
      x: wheelBox.offset().left + wheelBox.width()/2
      y: wheelBox.offset().top + wheelBox.height()/2

    dx = center.x - event.pageX
    dy = center.y - event.pageY

    h = Math.atan2(dx, dy)
    h += 2*Math.PI if h < 0
    hDeg = Math.round(h * 180/Math.PI)

    d = utils.distance(0, 0, dx, dy)

    # Clamp distance to colorwheel disc
    d = Math.max(minRadius, Math.min(d, maxRadius))

    l = Math.round(minLum + (maxRadius-d)/(maxRadius-minRadius)*(maxLum-minLum))

    # Put the cursor where the event occured
    x = center.x - Math.sin(h) * d
    y = center.y - Math.cos(h) * d

    cursor = $ @refs.colorCursor.getDOMNode()
    cursor.css 'display', 'block'
    cursor.offset
      left: x - cursor.width() / 2
      top: y - cursor.height() / 2

    @setState {color: [hDeg, 60, l]}

  changeName: (event) ->
    @setState {name: event.target.value}


  # Save user preferences and send to the server
  savePreferences: (event) ->
    event.preventDefault()
    @saveLocalPreferences()
    @sendPreferences()

  # Send user preferences to the server
  sendPreferences: () ->

    color = @state.color
    name = @state.name if @state.name.length > 0

    PubSub.publish 'send',
      type: Message.PREFERENCES_CHANGED
      content:
        color: color
        name: name

  # Store user preferences in the browser local storage
  saveLocalPreferences: ->

    localStorage['sparkets.color'] = @state.color if @state.color?
    localStorage['sparkets.name'] = @state.name if @state.name.length > 0

    console.info 'Preferences saved.'

  # Restore user preferences from the browser local storage
  restoreLocalPreferences: ->

    state = {}

    if localStorage['sparkets.color']?
      state.color = localStorage['sparkets.color'].split(',')

    if localStorage['sparkets.name']
      state.name = localStorage['sparkets.name']
      @refs.nameInput.value = state.name

    @setState state

    console.info 'Preferences restored.'


module.exports = Customization
