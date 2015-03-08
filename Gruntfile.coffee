module.exports = (grunt) ->

	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-vows'

	serverScripts = ['src/server/*.coffee', 'src/*.coffee']
	clientScripts = ['src/client/*.coffee', 'src/client/components/*.cjsx', 'src/*.coffee']

	###

	The gist of it:

		- Everything is compiled/copied under build/

		- the server scripts go in build/server

		- everything else goes in build/www/

	###

	grunt.initConfig

		coffee:
			server:
				expand: true
				cwd: 'src/'
				src: ['server/*.coffee', '*.coffee']
				dest: 'build/server/'
				ext: '.js'

		browserify:
			client:
				options:
					transform: ['coffee-reactify']
					external: [
						'lodash'
					]
					browserifyOptions:
						debug: true
						extensions: ['.coffee', '.cjsx']
				files:
					'build/www/client.js': 'src/client/components/Sparkets.cjsx'

		less:
			styles:
				files:
					'build/www/sparkets.css': 'www/sparkets.less'

		copy:
			html:
				expand: true
				src: 'www/*.html'
				dest: 'build/'
			lib:
				expand: true
				src: 'www/lib/*'
				dest: 'build' # different version depending on build type?
			assets:
				expand: true
				src: 'www/img/*'
				dest: 'build/'

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
			all: 'build'

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
			www:
				files: ['www/**/*', '!www/**/*.less']
				tasks: 'copy'


	grunt.registerTask 'default', ['clean', 'all', 'watch']

	grunt.registerTask 'all', ['server', 'client', 'www']
	grunt.registerTask 'server', ['coffee:server']
	grunt.registerTask 'client', ['browserify:client']
	grunt.registerTask 'www', ['less', 'copy']

	grunt.registerTask 'release', ['all', 'uglify']

	grunt.registerTask 'test', ['vows:all']
