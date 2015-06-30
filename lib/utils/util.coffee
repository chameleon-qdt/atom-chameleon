{BufferedProcess} = require 'atom'

fs = require 'fs.extra'

module.exports = Util =

  rumAtomCommand: (command) ->
     atom.views.getView(atom.workspace).dispatchEvent(new CustomEvent(command, bubbles: true, cancelable: true))

  getIndexHtmlCore: ->
    """
    <!DOCTYPE html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <title>Empty Template</title>
      </head>
      <body>
        <h1>Hello World!</h1>
      </body>
    </html>
    """

  formatModuleConfig:(options) ->
    """
    {
      "name": "#{options.moduleName}",
      "identifier": "#{options.moduleId}",
      "main":"#{options.mainEntry}",
      "version": "0.0.1",
      "description": "",
      "dependencies": {},
      "releaseNote": "module #{options.moduleName} init",
    }
    """

  formatAppConfig:(options) ->
    """
    {
      "name": "#{options.appName}",
      "identifier": "#{options.appId}",
      "mainModule":"#{if options.mainModule? then options.mainModule else '' }",
      "version": "0.0.1",
      "description": "",
      "dependencies": {},
      "releaseNote": "app init",
    }
    """

  getRepo: (appPath,repoUri, cb) ->
    command = 'git'
    args = ['clone', repoUri, appPath]
    stdout = (output) -> console.log(output)
    exit = (code) -> cb(code, appPath)
    process = new BufferedProcess({command, args, stdout, exit})

  copy: (sourcePath, destinationPath, cb) ->
    fs.copyRecursive(sourcePath, destinationPath, cb)

  createDir: (path, cb) ->
    fs.mkdirp(path, cb) 

  isFileExist: (path, cb) ->
    fs.exists path, cb