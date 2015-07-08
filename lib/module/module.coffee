{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
Util = require '../utils/util'
pathM = require 'path'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'
fs = require 'fs-extra'

module.exports = ModuleManager =
  chameleonBox: null
  modalPanel: null

  activate: (state) ->
    Util.fileCompression("xxx")
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
    configFileContent = Util.formatModuleConfigToStr(info)
    entryFilePath = pathM.join filePath,info.mainEntry
    entryFile = new File(entryFilePath)
    htmlString = Util.getIndexHtmlCore()
    isProject = options.isChameleonProject
    configFile.create()
      .then (isSuccess) =>
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
          # console.log 'begin'
          if info.isChameleonProject
            # console.log info.moduleId
            projectConfigPath = pathM.join info.modulePath,'..','appConfig.json'
            # console.log projectConfigPath
            appConfig = new File(projectConfigPath)
            appConfig.exists().then (resolve,reject) =>
              if resolve
                appConfig.read(false).then (content) =>
                  contentList = JSON.parse(content)
                  contentList['modules'][info.moduleId] = "0.0.1"
                  if contentList['mainModule'] == ""
                    contentList['mainModule'] = info.moduleId
                  fs.writeJson projectConfigPath,contentList,null
          # console.log 'end'
          @addProjectModule info
          atom.project.addPath(filePath)
          Util.rumAtomCommand 'tree-view:toggle' if ChameleonBox.$('.tree-view-resizer').length is 0
          @chameleonBox.closeView()
      # .finally =>
        # console.log 'CreateModule Success',@

  addProjectModule: (moduleInfo) ->

    if moduleInfo.modulePath.lastIndexOf 'modules' isnt -1
      console.log moduleInfo.modulePath
