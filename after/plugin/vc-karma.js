module.exports = function karmaConfig(config) {
  const watch = process.argv.includes('--watch');
  const node_modules = process.argv[1].replace('.bin/ng', '')

  config.set({
    autoWatch: watch,
    basePath: '',
    frameworks: ['mocha', '@angular-devkit/build-angular'],
    plugins: [
      require(node_modules + 'karma-coverage'),
      require(node_modules + 'karma-mocha'),
      require(node_modules + 'karma-chrome-launcher'),
      require(node_modules + '@angular-devkit/build-angular/plugins/karma'),
    ],
    client: {
      clearContext: true,
      mocha: {
        timeout: 10_000,
      }
    },
    port: 9876,
    hostname: 'localhost',
    colors: false,
    logLevel: config.LOG_INFO,
    browsers: ['ChromeHeadlessDebug'] ,
    customLaunchers: {
      ChromeHeadlessDebug: {
        base: "ChromeHeadless",
        flags: [
          "--no-sandbox",
          "--remote-debugging-port=9222",
        ],
        debug: true,
      },
    },
    singleRun: !watch,
    concurrency: Infinity,
    browserDisconnectTimeout: 30_000,
    browserDisconnectTolerance: 1,
    browserNoActivityTimeout: 30_000,
    restartOnFileChange: watch,
  });
}

