Footer = React.createClass

	render: ->
		<footer>

			<section id="how">
				<h3>How</h3>
				<ul>
					<li><a href="http://www.whatwg.org/specs/web-apps/current-work/multipage/">HTML5</a>
					<a href="http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html">canvas</a>
					and <a href="http://dev.w3.org/html5/websockets/">WebSocket</a></li>
					<li><a href="http://nodejs.org/">Node.js</a>
					with <a href="http://socket.io">Socket.IO</a></li>
					<li><a href="http://github.com/fmdkdd/sparkets">Source</a> hosted on <a href="http://github.com/">Github</a></li>
				</ul>
			</section>

			<section id="who">
				<h3>Who</h3>
				<ul>
					<li><a href="http://www.github.com/fmdkdd">fmdkdd</a></li>
					<li><a href="http://www.github.com/merwaaan">merwaaan</a></li>
				</ul>
			</section>

		</footer>

module.exports = Footer
