React = require 'react'
$ = require 'jquery'
_ = require('lodash') # remove

Header = React.createClass

  getDefaultProps: ->
    animated: false

  render: ->
    <header>
      <h1 ref='title'>
        <span>SPA</span>
        <span>ceships&nbsp;</span>
        <span>R</span>
        <span>umble using WebSoc</span>
        <span>KETS!</span>
      </h1>
      <h1 ref='questionMark'>
        ?
      </h1>
    </header>

  componentDidMount: ->

    if not @props.animated
      return

    #

    @refs.questionMark.getDOMNode().addEventListener 'click', (event) =>

      $(@.refs.questionMark.getDOMNode()).fadeOut 300, () =>
        $(@).remove()

      #

      fragments = _.toArray document.querySelectorAll('span', @refs.title.getDOMNode())

      #

      position = 0
      fragments.map (fragment, index) ->

        position = if index is 0 then $(fragment).position().left else position + $(fragment).width()

        if index % 2
          $(fragment).animate {left: position + $(fragment).position().left + 'px'}, 300, 'swing'
        else
          $(fragment).css 'left', position
          $(fragment).animate {opacity: 0.3}, 300


module.exports = Header
