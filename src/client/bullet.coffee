class Bullet
	constructor: (bullet) ->
		@color = bullet.color
		@points = bullet.points

	update: (point) ->
		@points.push(point)

	draw: (ctxt, alpha, offset = {x: 0, y: 0}) ->
		p = @points
		ox = -view.x + offset.x
		oy = -view.y + offset.y

		x = p[0][0] + ox
		y = p[0][1] + oy
		ctxt.strokeStyle = color @color, alpha
		ctxt.beginPath()
		ctxt.moveTo x, y

		for i in [1...p.length]
			x = p[i][0] + ox
			y = p[i][1] + oy

			# Check for a bullet warping.
			if -50  < p[i-1][0] - p[i][0] < 50 and
					-50 < p[i-1][1] - p[i][1] < 50
				ctxt.lineTo x, y
			else
				# Start the new path on the other side of the map.
				ctxt.stroke()
				ctxt.beginPath()
				ctxt.moveTo x, y

		ctxt.stroke()
