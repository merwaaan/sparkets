GaugeMixin = require './GaugeMixin'
React = require 'react'

BonusSettings = React.createClass

  mixins : [GaugeMixin]

  render: ->

    before = <canvas ref='canvas'
      width={@props.size/4}
      height={@props.size/4}>
    </canvas>

    @subrender(before)

  componentDidMount: ->

    sprite = @props.spriteManager.get @props.type, @props.size/4, @props.size/4, 'black'
    ctx = @refs.canvas.getDOMNode().getContext '2d'
    ctx.drawImage sprite, 0, 0


module.exports = BonusSettings
