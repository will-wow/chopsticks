'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');

var SOURCE_DIR = path.join(__dirname, '../web/static/');
var DIST_DIR = path.join(__dirname, '../priv/static/');

module.exports = {
  devtool: 'eval-source-map',
  entry: [
    'webpack-dev-server/client?http://localhost:4001',
    'webpack/hot/only-dev-server',
    'react-hot-loader/patch',
    path.join(SOURCE_DIR, 'index.tsx')
  ],
  output: {
    path: DIST_DIR,
    filename: '[name].js',
    publicPath: '/'
  },
  resolve: {
    // Add .ts
    extensions: ["", ".webpack.js", ".web.js", ".ts", ".tsx", ".js"]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(SOURCE_DIR, 'index.tpl.html'),
      inject: 'body',
      filename: 'index.html'
    }),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('development')
    })
  ],
  // tslint options
  tslint: {
    emitErrors: false,
    failOnHint: false,
    configuration: require('../.tslint.json')
  },
  module: {
    preLoaders: [{
      test: /\.tsx?$/,
      exclude: /node_modules/,
      loader: 'tslint'
    }],
    loaders: [
      // All files with a '.ts' or '.tsx' extension will be handled by 'ts-loader'.
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        loaders: ['babel', 'ts']
      }, {
        test: /\.json?$/,
        loader: 'json'
      }, {
        test: /\.scss$/,
        exclude: [/node_modules/], // sassLoader will include node_modules explicitly.
        loader: 'style!css!sass?modules&localIdentName=[name]---[local]---[hash:base64:5]'
      }, {
        test: /\.woff(2)?(\?[a-z0-9#=&.]+)?$/,
        loader: 'url?limit=10000&mimetype=application/font-woff'
      }, {
        test: /\.(png|jpg)(\?[a-z0-9#=&.]+)?$/,
        loader: 'url?limit=10000&name=img-[hash:6].[ext]'
      }, {
        test: /favicon\.ico$/,
        loader: 'url?limit=1&name=[name].[ext]'
      }, {
        test: /\.(ttf|eot|svg)(\?[a-z0-9#=&.]+)?$/,
        loader: 'file'
      }
    ]
  },
  sassLoader: {
    includePaths: [path.resolve(__dirname, "../node_modules")]
  }
};