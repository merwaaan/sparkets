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
    'ws',
    'pubsub-js',
    'react',
    'react-router',
    'lodash',
    'jquery'
  ]

  ###

  The gist of it:

    - Everything is compiled/copied under build/

    - the server scripts go in build/server

    - everything else (client, images, html, css) goes under
      build/www/

    - the client is divided into two bundles: the game and the
      dependencies

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
          external: libs
        files:
          'build/www/client.js': 'src/client/components/Sparkets.cjsx'

      libs:
        options:
          require: libs
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
