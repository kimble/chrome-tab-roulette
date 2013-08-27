/*global module:false*/
module.exports = function (grunt) {

    // Project configuration.
    grunt.initConfig({

        // Metadata.
        pkg: grunt.file.readJSON('package.json'),
        banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
            '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
            '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
            '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
            ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',

        // Task configuration.
        clean: {
            dist: ['dist/']
        },
        copy: {
            images: {
                expand: true,
                cwd: 'assets/images',
                src: ['*.png', '*.jpg'],
                dest: 'dist/assets/images'
            },
            styles: {
                expand: true,
                cwd: 'assets/css',
                src: ['*.css'],
                dest: 'dist/assets/css'
            },
            html: {
                expand: true,
                cwd: 'assets/html',
                src: ['*.html'],
                dest: 'dist/assets/html'
            },
            chrome: {
                src: 'assets/chrome/manifest.json',
                dest: 'dist/manifest.json'
            },
            dependencies: {
                src: 'dependencies/**/*.js',
                dest: 'dist/javascript/dependencies/'
            }
        },
        karma: {
            unit: {
                //configFile: 'karma.conf.js',
                runnerPort: 9999,
                browsers: ['PhantomJS'],
                background: true
            }
        },
        coffee: {
            compile: {
                expand: true,
                flatten: true,
                cwd: 'src/main/coffee/',
                src: ['*.coffee'],
                dest: 'dist/javascript/compiled',
                ext: '.js'
            }
        },
        watch: {
            coffee: {
                files: ['src/main/coffee/*.coffee'],
                tasks: 'build'
            }
        }
    });

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-karma');


    grunt.registerTask('build', [ 'clean:dist', 'coffee', 'copy' ]);

    // Default task.
    grunt.registerTask('default', [ 'build' ]);

};
