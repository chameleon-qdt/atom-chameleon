{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
Util = require '../utils/util'
pathM = require 'path'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'

module.exports = ModuleManager =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    @chameleonBox = new CreateModuleView()

    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()

    @chameleonBox.onFinish (options) => @CreateModule(options)
    @chameleonBox

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
    filePath = pathM.join info.modulePath,info.moduleId
    configFilePath = pathM.join filePath,desc.moduleConfigFileName
    configFile = new File(configFilePath)
    configFileContent = Util.formatModuleConfig(info)
    entryFilePath = pathM.join filePath,info.mainEntry
    entryFile = new File(entryFilePath)
    htmlString = Util.getIndexHtmlCore()
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
