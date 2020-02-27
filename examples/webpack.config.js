const path = require('path');

module.exports = {
  context: __dirname,
  target: 'web',
  entry: './index.js',
  stats: 'minimal',
  module: {
    rules: [{
      test: /\.js$/,
      use: {
        loader: 'buble-loader'
      },
      include: [
        path.join(__dirname, '..', 'src'),
        path.join(__dirname)
      ]
    }]
  },
  devtool: 'source-map',
  output: {
    filename: '[name].js',
    path: path.join(__dirname, '..', 'dist', 'examples')
  },
  devServer: {
    contentBase: __dirname,
  }
};