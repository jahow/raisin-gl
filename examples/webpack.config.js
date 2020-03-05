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
        loader: 'buble-loader',
        options: {
          objectAssign: 'Object.assign'
        }
      },
      include: [
        path.join(__dirname, '..', 'src'),
        __dirname
      ]
    },
      {
        test: /\.glsl$/,
        use: [{ loader: "raw-loader" }],
        include: [
          path.join(__dirname, '..', 'src'),
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