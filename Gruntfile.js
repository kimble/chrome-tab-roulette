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
        compress: {
            release: {
                options: {
                    archive: 'builds/chrome-tab-roulette-v<%= pkg.version %>.zip'
                },
                files: [
                    {
                        src: [ 'dist/**' ],
                        dest: '/'
                    }
                ]
            }
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
            dependencies: {
                expand: true,
                cwd: 'dependencies/javascript',
                src: ['*.js'],
                dest: 'dist/javascript/dependencies/'
            }
        },
        karma: {
            unit: {
                configFile: 'config/karma.conf.js',
                browsers: ['PhantomJS'],
                background: true
            },
            single: {
                configFile: 'config/karma.conf.js',
                browsers: ['PhantomJS'],
                singleRun: true
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
        yaml: {
            chromeManifest: {
                files: {
                    'dist/manifest.json': 'assets/chrome/manifest.yml'
                }
            }
        },
        watch: {
            coffee: {
                files: ['src/main/coffee/*.coffee'],
                tasks: 'build'
            },
            karma: {
                files: ['dist/javascript/compiled/**/*.js', 'src/test/javascript/**/*.js'],
                tasks: ['karma:unit:run']
            }
        }
    });

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-compress');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-notify');
    grunt.loadNpmTasks('grunt-yaml');
    grunt.loadNpmTasks('grunt-karma');


    grunt.registerTask('tdd', [ 'karma:unit', 'watch' ]);
    grunt.registerTask('build', [ 'clean:dist', 'yaml', 'coffee', 'copy', 'karma:single' ]);
    grunt.registerTask('build-release', [ 'build', 'compress:release' ]);

    // Default task.
    grunt.registerTask('default', [ 'build' ]);

};
