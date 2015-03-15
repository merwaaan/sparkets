React = require 'react'
$ = require 'jquery'

RangeMixin =

  propTypes:
    value: React.PropTypes.number.isRequired
    width: React.PropTypes.number
    height: React.PropTypes.number
    from: React.PropTypes.number
    to: React.PropTypes.number

  getDefaultProps: ->
    width: 200
    height: 30
    from: 0
    to: 1

  subrender: (before, after) ->
    <div className='range'>

      {before}

      <svg width={@props.width} height={@props.height}>

        <rect
          x=0
          y=0
          width={@props.width}
          height={@props.height}
          fill='grey'
          onClick={@pick}/>


        <circle
          cx={@props.width * @props.value}
          cy={@props.height / 2}
          r={5}
          fill='red' />

      </svg>

      {after}

    </div>

  pick: (event) ->

    click = event.pageX - $(event.target.parentNode).offset().left
    value = click / @props.width
    @props.onChange value


module.exports = RangeMixin
