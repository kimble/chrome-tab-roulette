module.exports = function(config) {
  config.set({
    frameworks: ['jasmine'],

    files: [
        '../dist/javascript/compiled/lib.js',
        '../src/test/javascript/*.test.js'
    ]
  });
};
