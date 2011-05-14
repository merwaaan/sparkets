class EMP
	constructor: (emp) ->
		console.info emp
		@serverUpdate(emp)

	serverUpdate: (emp) ->
		for field, val of emp
			this[field] = val

	update: () ->
		@clientDelete = @serverDelete

	draw: (ctxt, offset = {x:0, y:0}) ->
		x = @pos.x + offset.x - view.x
		y = @pos.y + offset.y - view.y

		ctxt.save()

		ctxt.lineWidth = 3
		ctxt.strokeStyle = color @color
		ctxt.beginPath()
		ctxt.arc(x, y, @force, 0, 2*Math.PI, false)
		ctxt.stroke()

		ctxt.restore()