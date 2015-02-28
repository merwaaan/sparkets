module.exports = (grunt) ->

	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-contrib-less')
	grunt.loadNpmTasks('grunt-contrib-uglify')
	grunt.loadNpmTasks('grunt-contrib-clean')
	grunt.loadNpmTasks('grunt-contrib-watch')
	grunt.loadNpmTasks('grunt-vows')

	serverScripts = ['src/server/*.coffee', 'src/*.coffee']
	clientScripts = ['src/client/*.coffee', 'src/client/components/*.cjsx', 'src/*.coffee']

	grunt.initConfig

		coffee:
			options:
				join: true
			server:
				expand: true
				flatten: true
				src: serverScripts
				dest: 'build/server/'
				ext: '.js'

		browserify:
			client:
				options:
					transform: ['coffee-reactify']
					browserifyOptions:
						debug: true
						extensions: ['.coffee', '.cjsx']
				files:
					'build/client/index.js': 'src/client/index.coffee'
					'build/client/create.js': 'src/client/create.coffee'
					'build/client/client.js': 'src/client/client.coffee'

		less:
			dev:
				files:
					'www/index.css': 'styles/index.less'
					'www/create.css': 'styles/create.less'
					'www/play.css': 'styles/play.less'

		vows:
			all:
				options:
					verbose: true
				src: ['test/*.coffee']

		uglify:
			client:
				files:
					'build/client.min.js': 'build/client.js'

		clean:
			all: ['build']

		watch:
			server:
				files: serverScripts
				tasks: 'server'
			client:
				files: clientScripts
				tasks: 'client'
			styles:
				files: 'styles/*.less'
				tasks: 'less'

	grunt.registerTask('default', ['clean', 'both', 'watch'])

	grunt.registerTask('server', ['coffee:server'])
	grunt.registerTask('client', ['browserify:client', 'less'])
	grunt.registerTask('both', ['server', 'client'])
	grunt.registerTask('release', ['both', 'uglify'])

	grunt.registerTask('test', ['vows:all'])
