module.exports = (grunt) ->

	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-vows'

	BUILD = grunt.option('build') or 'debug'
	DEBUG = BUILD is 'debug'
	RELEASE = BUILD is 'release'

	serverScripts = ['src/server/*.coffee', 'src/*.coffee']
	clientScripts = ['src/client/*.coffee', 'src/client/components/*.cjsx', 'src/*.coffee']

	libs = [
		['react-addons', '0.12.2']
		['react-router', '0.11.6']
		['lodash', '3.4.0']
		['jquery', '2.1.3']
	]
	libNames = (name + '-' + version for [name, version] in libs)
	libPaths = ('./www/lib/' + lib + (if RELEASE then '.min' else '') + '.js' for lib in libNames)
	console.log 'libs: ', libs, libNames, libPaths

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
			options:
				transform: ['coffee-reactify']
				browserifyOptions:
					debug: DEBUG
					extensions: ['.coffee', '.cjsx']

			client:
				options:
					external: ['react', 'react-router', 'jquery', 'lodash']
				files:
					'build/www/client.js': 'src/client/components/Sparkets.cjsx'

			libs:
				options:
					require: ['react', 'react-router', 'lodash', 'jquery']
				src: []
				dest: 'build/www/libs.js'

		less:
			styles:
				files:
					'build/www/sparkets.css': 'www/sparkets.less'

		copy:
			html:
				expand: true
				src: 'www/index.html'
				dest: 'build/'
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
					'build/www/libs.js': 'build/www/libs.js'
					'build/www/client.js': 'build/www/client.js'

		clean:
			all: 'build'

		watch:
			server:
				files: serverScripts
				tasks: 'server'
			client:
				files: clientScripts
				tasks: 'browserify:client'
			styles:
				files: 'www/**/*.less'
				tasks: 'less'
			www:
				files: ['www/**/*', '!www/**/*.less']
				tasks: 'copy'


	grunt.registerTask 'default', ['clean', 'all', 'watch']

	grunt.registerTask 'server', ['coffee:server']
	grunt.registerTask 'client', ['browserify:libs', 'browserify:client']
	grunt.registerTask 'www', ['less', 'copy']

	grunt.registerTask 'all', ['server', 'client', 'www'].concat if RELEASE then ['uglify'] else []

	grunt.registerTask 'test', ['vows']
