RangeMixin = require './RangeMixin'
React = require 'react'

DurationSettings = React.createClass

  mixins: [RangeMixin]

  render: ->
    @subrender()


module.exports = DurationSettings
