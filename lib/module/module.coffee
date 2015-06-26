{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'

module.exports = ModuleManager =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    opt =
      title : desc.createModule
      subview : new CreateModuleView()

    @chameleonBox = new ChameleonBox(opt)
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()

    @chameleonBox.onFinish (options) => @CreateModule(options)

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateModuleView was opened!'
      @modalPanel.show()

  CreateModule: (options)->
    console.log options
    info = options.moduleInfo
    filePath = "#{atom.project.getPaths()[0]}/#{info.moduleId}"
    configFilePath = "#{filePath}/moduleConfig.json"
    configFile = new File(configFilePath)
    configFileContent = @formatConfig(info)
    entryFile = new File("#{filePath}/#{info.mainEntry}")
    htmlString = @getIndexHtmlCore()
    console.log JSON.stringify(info),configFileContent

    # console.log options.newType
    # if options.newType is 'empty'
    configFile.create()
      .then (isSuccess) ->
        console.log isSuccess
        if isSuccess is yes
          configFile.setEncoding('utf8')
          console.log 'CreateModule Success'
          configFile.writeSync(configFileContent)
          entryFile.create()
        else
          console.log 'CreateModule error'
      .then (isSuccess) =>
        if isSuccess is yes
          entryFile.writeSync(htmlString)
          @chameleonBox.closeView()
      # .finally =>
        # console.log 'CreateModule Success',@

  formatConfig:(options) ->
    str ="""
          {
            "name": "#{options.moduleName}",
            "identifier": "#{options.moduleId}",
            "name":"#{options.mainEntry}",
            "version": "0.0.1",
            "description": "",
            "dependencies": "{}",
            "releaseNote": "frist create",
          }
          """

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
