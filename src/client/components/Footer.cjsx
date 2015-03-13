React = require 'react'

Footer = React.createClass

  render: ->
    <footer>

      <section id='how'>
        Made with <a href='http://dev.w3.org/html5/websockets/'>websockets</a> and <a href='http://nodejs.org/'>nodeJS</a> (<a href='http://github.com/fmdkdd/sparkets'>Source</a>)
      </section>

      <section id='who'>
        by <a href='http://www.github.com/fmdkdd'>fmdkdd</a> & <a href='http://www.github.com/merwaaan'>merwaaan</a>
      </section>

    </footer>

module.exports = Footer
