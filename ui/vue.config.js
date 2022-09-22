const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  filenameHashing: false,
  publicPath: '',
  chainWebpack: config => {
    config.optimization.splitChunks({
        ...config.optimization.get('splitChunks'),
        automaticNameDelimiter: '-'
    })
  }
})
