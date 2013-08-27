module.exports = function(config) {
  config.set({
    frameworks: ['jasmine'],

    files: [
      '../src/test/javascript/*.test.js'
    ]
  });
};
