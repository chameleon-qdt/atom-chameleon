{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
Util = require '../utils/util'
pathM = require 'path'
desc = require '../utils/text-description'
config = require '../../config/config'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'
Builder = require '../QDT-Builder/builder'
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
    params = @formatOptions options
    Util.createModule params, (err) =>
      return console.error err if err?
      @addProjectModule info
      @openTreeView filePath
      alert desc.createModuleSuccess
      @chameleonBox.closeView()


  CreateSimpleModule: (options) ->
    console.log 'SimpleModule'
    params = @formatOptions options
    # console.log params
    Builder.activate(params);
    @chameleonBox.closeView()

  CreateTemplateModule: (options) ->
    console.log 'tmp'
    console.log options
    info = options.moduleInfo
    sourcePath = pathM.join desc.getFrameworkPath(),options.source
    targetPath = pathM.join info.modulePath,info.moduleId


    if options.source is desc.defaultModuleName and Util.isFileExist(sourcePath) is no
      @gitCloneDefaultModule options
      return

    copyCallback = (err) =>
      if err
        @modalPanel.item.children(".loading-mask").remove()
        return console.error err
      console.log 'success'
      Util.delete pathM.join(targetPath,desc.gitFolder), ->
        if err
          console.error err
        else
          console.log 'delete .git success'
      moduleConfigPath = pathM.join targetPath,desc.moduleConfigFileName
      if Util.isFileExist moduleConfigPath
        moduleConfig = Util.readJsonSync moduleConfigPath
        console.log moduleConfig
        moduleConfig = @editModuleConfig moduleConfig,info
      else
        moduleConfig = Util.formatModuleConfigToObj info
      Util.writeJson moduleConfigPath,moduleConfig,(err) ->
        console.log err
      @addProjectModule info
      @openTreeView targetPath
      alert desc.createModuleSuccess
      @chameleonBox.closeView()
    console.log sourcePath,targetPath
    Util.copy sourcePath,targetPath,copyCallback

  gitCloneDefaultModule: (options) ->
    success = (state, appPath) =>
      if state is 0
        modulePath = pathM.join desc.getFrameworkPath(),options.source
        Util.ensureModuleConfig modulePath, options.moduleInfo, (err) =>
          return console.error err if err?
          console.log "moduleConfig write success"
          @CreateTemplateModule options
      else
        alert "#{desc.createModuleError}:#{desc.gitCloneError}"
        @modalPanel.item.children(".loading-mask").remove()
    Util.getRepo(desc.getFrameworkPath(), config.repoUri, success) #没有，执行 git clone，成功后执行第二步

  formatOptions: (options) ->
    info = options.moduleInfo
    moduleConfig = Util.formatModuleConfigToObj info
    params =
      projectInfo: null
      builderConfig: [
        {
          name: "index.html",
          components: []
        }
      ]
      moduleConfig: moduleConfig
      moduleInfo:
        identifier: info.moduleId
        moduleName: info.moduleName
        modulePath: info.modulePath

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
      projectConfigPath = pathM.join moduleInfo.modulePath, '..', desc.projectConfigFileName
      appConfig = Util.readJsonSync projectConfigPath
      appConfig.mainModule = moduleInfo.moduleId if !appConfig.mainModule
      if !appConfig.modules
        appConfig.modules = {}
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
