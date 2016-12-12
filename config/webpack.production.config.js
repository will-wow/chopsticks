'use strict';

var path = require('path');
var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var StatsPlugin = require('stats-webpack-plugin');

var SOURCE_DIR = path.join(__dirname, '../web/static/');
var DIST_DIR = path.join(__dirname, '../priv/static/');

module.exports = {
  // The entry file. All your app roots fromn here.
  entry: [
    path.join(SOURCE_DIR, 'index.tsx')
  ],
  // Where you want the output to go
  output: {
    path: DIST_DIR,
    filename: '[name]-[hash].min.js',
    publicPath: '/'
  },
  resolve: {
    // Add .ts
    extensions: ["", ".webpack.js", ".web.js", ".ts", ".tsx", ".js"]
  },
  plugins: [
    // handles creating an index.html file and injecting assets. necessary because assets
    // change name because the hash part changes. We want hash name changes to bust cache
    // on client browsers.
    new HtmlWebpackPlugin({
      template: path.join(SOURCE_DIR, 'index.tpl.html'),
      inject: 'body',
      filename: 'index.html'
    }),
    // webpack gives your modules and chunks ids to identify them. Webpack can vary the
    // distribution of the ids to get the smallest id length for often used ids with
    // this plugin
    new webpack.optimize.OccurenceOrderPlugin(),
    // extracts the css from the js files and puts them on a separate .css file. this is for
    // performance and is used in prod environments. Styles load faster on their own .css
    // file as they dont have to wait for the JS to load.
    new ExtractTextPlugin('[name]-[hash].min.css'),
    // handles uglifying js
    new webpack.optimize.UglifyJsPlugin({
      compressor: {
        warnings: false,
        screw_ie8: true
      }
    }),
    // creates a stats.json
    new StatsPlugin('webpack.stats.json', {
      source: false,
      modules: false
    }),
    // plugin for passing in data to the js, like what NODE_ENV we are in.
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    })
  ],

  // tslint options
  tslint: {
    emitErrors: false,
    failOnHint: true,
    configuration: require('../.tslint.json')
  },

  module: {
    // Runs before loaders
    preLoaders: [{
      test: /\.tsx?$/,
      exclude: /node_modules/,
      loader: 'tslint'
    }],
    // loaders handle the assets, like transforming sass to css or jsx to js.
    loaders: [{
      test: /\.tsx?$/,
      exclude: /node_modules/,
      loaders: ['babel', 'ts']
    }, {
      test: /\.json?$/,
      loader: 'json'
    }, {
      test: /\.scss$/,
      exclude: [/node_modules/], // sassLoader will include node_modules explicitly.
      // we extract the styles into their own .css file instead of having
      // them inside the js.
      loader: ExtractTextPlugin.extract('style', 'css!postcss!sass')
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
    }]
  },
  postcss: [
    require('autoprefixer')
  ],
  sassLoader: {
    includePaths: [path.resolve(__dirname, "../node_modules")]
  }
};
