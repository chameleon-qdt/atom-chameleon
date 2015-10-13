{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
Util = require '../utils/util'
pathM = require 'path'
desc = require '../utils/text-description'
config = require '../../config/config'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'
LoadingMask = require '../utils/loadingMask'
# fs = require 'fs-extra'

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
    loadingMask = new LoadingMask()
    switch options.createType
      when 'empty' then @CreateEmptyModule options
      when 'simple' then @CreateSimpleModule options
      when 'template' then @CreateTemplateModule options
    @modalPanel.item.append(loadingMask)


  CreateEmptyModule: (options) ->
    console.log options
    info = options.moduleInfo
    filePath = pathM.join info.modulePath,info.moduleId
    configFilePath = pathM.join filePath,desc.moduleConfigFileName
    configFile = new File(configFilePath)
    configFileContent = Util.formatModuleConfigToObj(info)
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
          cb = (err) =>
            console.log err
          Util.writeJson(configFilePath,configFileContent,cb)
          entryFile.create()
        else
          console.log 'CreateModule error'
      .then (isSuccess) =>
        if isSuccess is yes
          entryFile.writeSync(htmlString)
          @addProjectModule info
          @openTreeView filePath
          alert "新建模块成功！"
          @chameleonBox.closeView()
      # .finally =>
        # console.log 'CreateModule Success',@

  CreateSimpleModule: (options) ->
    console.log 'SimpleModule'
    console.log options
    @chameleonBox.closeView()


  CreateTemplateModule: (options) ->
    console.log 'tmp'
    console.log options
    info = options.moduleInfo
    sourcePath = pathM.join desc.getFrameworkPath(),options.source
    targetPath = pathM.join info.modulePath,info.moduleId


    if options.source is desc.defaultModule and Util.isFileExist(sourcePath) is no
      @gitCloneDefaultModule options
      return

    copyCallback = (err) =>
      if err
        @modalPanel.item.children(".loading-mask").remove()
        return console.error err
      console.log 'success'
      moduleConfigPath = pathM.join targetPath,desc.moduleConfigFileName
      moduleConfig = Util.readJsonSync moduleConfigPath
      console.log moduleConfig
      moduleConfig = @editModuleConfig moduleConfig,info
      Util.writeJson moduleConfigPath,moduleConfig,(err) ->
        console.log err
      @addProjectModule info
      @openTreeView targetPath
      alert "新建模块成功！"
    console.log sourcePath,targetPath
    Util.copy sourcePath,targetPath,copyCallback
    @chameleonBox.closeView()

  gitCloneDefaultModule: (options) ->
    success = (state, appPath) =>
      if state is 0
        @CreateTemplateModule options
      else
        alert '应用创建失败：git clone失败，请检查网络连接'
        @modalPanel.item.children(".loading-mask").remove()
    Util.getRepo(desc.getFrameworkPath(), config.repoUri, success) #没有，执行 git clone，成功后执行第二步


  editModuleConfig: (config,info) ->
    config.template = config.identifier
    config.name = info.moduleName
    config.identifier = info.moduleId
    config.version = desc.minVersion
    config.build = 1
    config.hidden ?= false
    config.dependencies ?= {}
    return config

  addProjectModule: (moduleInfo) ->
    console.log moduleInfo
    if moduleInfo.isChameleonProject is yes
      projectConfigPath = pathM.join moduleInfo.modulePath, '..', desc.ProjectConfigFileName
      appConfig = Util.readJsonSync projectConfigPath
      appConfig.mainModule = moduleInfo.moduleId if appConfig.mainModule is ''
      appConfig.modules[moduleInfo.moduleId] = desc.minVersion
      Util.writeJson projectConfigPath,appConfig,(err) ->
        console.log err

  openTreeView: (filePath) ->
    isInProject = false
    atom.project.getDirectories().forEach (dir) =>
      # console.log dir,filePath
      flag = dir.contains filePath
      # console.log flag
      if flag
        isInProject = flag

    console.log isInProject
    if isInProject is no
      atom.project.addPath(filePath)
      Util.rumAtomCommand 'tree-view:toggle' if ChameleonBox.$('.tree-view-resizer').length is 0
