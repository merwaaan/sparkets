module.exports = function(grunt) {

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
        files: {'build/server.js': serverScripts}
      },
      client: {
        files: {'build/client.js': clientScripts}
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
        tasks: ['coffee:server']
      },
      client: {
        files: clientScripts,
        tasks: ['coffee:client']
      }
    }

  });

  grunt.registerTask('default', ['clean', 'both', 'watch']);

  grunt.registerTask('server', ['coffee:server']);
  grunt.registerTask('client', ['coffee:client']);
  grunt.registerTask('both', ['server', 'client']);

  grunt.registerTask('test', ['vows:all']);

  grunt.registerTask('release', ['both', 'uglify'])

};
