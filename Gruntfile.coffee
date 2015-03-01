module.exports = (grunt) ->

	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-contrib-less')
	grunt.loadNpmTasks('grunt-contrib-uglify')
	grunt.loadNpmTasks('grunt-contrib-clean')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-vows')

	serverScripts = ['src/server/*.coffee', 'src/*.coffee']
	clientScripts = ['src/client/**/*.coffee', 'src/*.coffee']

	###

	The gist of it:

		- the server scripts go in their own server/ folder

		- the client scripts are browserified and placed in
		  the www/client folder

		- LESS files are precompiled and placed under www/styles

	###

	grunt.initConfig

		coffee:
			server:
				expand: true
				flatten: true
				src: serverScripts
				dest: 'server/'
				ext: '.js'

		browserify:
			client:
				options:
					transform: ['coffee-reactify']
					browserifyOptions:
						debug: true
						extensions: ['.coffee', '.cjsx']
				files:
					'www/client/index.js': 'src/client/index.coffee'
					'www/client/create.js': 'src/client/create.coffee'
					'www/client/client.js': 'src/client/client.coffee'

		less:
			styles:
				expand: true
				src: 'www/styles/*.less'
				ext: '.css'

		vows:
			all:
				options:
					verbose: true
				src: 'test/*.coffee'

		uglify:
			client:
				files:
					'www/client.min.js': 'build/client.js'

		clean:
			all: ['server', 'www/client', 'www/styles/*.css']

		watch:
			server:
				files: serverScripts
				tasks: 'server'
			client:
				files: clientScripts
				tasks: 'client'
			styles:
				files: 'www/styles/*.less'
				tasks: 'less'

	grunt.registerTask('default', ['clean', 'both', 'watch'])

	grunt.registerTask('server', ['coffee:server'])
	grunt.registerTask('client', ['browserify:client', 'less'])
	grunt.registerTask('both', ['server', 'client'])
	grunt.registerTask('release', ['both', 'uglify'])

	grunt.registerTask('test', ['vows:all'])
