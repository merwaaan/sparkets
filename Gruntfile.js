module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-vows');

  var serverScripts = ['src/server/*.coffee', 'src/*.coffee'];
  var clientScripts = ['src/client/*.coffee', 'src/*.coffee'];

  grunt.initConfig({

    coffee: {
      options: {
        join: true
      },
      server: {
        expand: true,
        flatten: true,
        src: serverScripts,
        dest: 'build/server/',
        ext: '.js'
      }
    },

    browserify: {
      client: {
        options: {
          transform: ['coffeeify'],
          browserifyOptions: {
            debug: true,
            extensions: ['.coffee']
          }
        },
        files : {
          'build/client/client.js': clientScripts.concat('!src/client/index.coffee', '!src/client/create.coffee'),
          'build/client/index.js': 'src/client/index.coffee',
          'build/client/create.js': 'src/client/create.coffee'
        }
      }
    },

    vows: {
      all: {
        options: {
          verbose: true
        },
        src: ['test/*.coffee']
      }
    },

    uglify: {
      client: {
        files: {
          'build/client.min.js': 'build/client.js'
        }
      }
    },

    clean: {
      all: ['build']
    },

    watch: {
      server: {
        files: serverScripts,
        tasks: ['server']
      },
      client: {
        files: clientScripts,
        tasks: ['client']
      }
    }

  });

  grunt.registerTask('default', ['clean', 'both', 'watch']);

  grunt.registerTask('server', ['coffee:server']);
  grunt.registerTask('client', ['browserify:client']);
  grunt.registerTask('both', ['server', 'client']);
  grunt.registerTask('release', ['both', 'uglify'])

  grunt.registerTask('test', ['vows:all']);

};
