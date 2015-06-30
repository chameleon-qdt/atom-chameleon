{$, Emitter, Directory, File, BufferedProcess, Notification} = require 'atom'
pathM = require 'path'
Util = require '../utils/util'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateProjectView = require './create-project-view'
LoadingMask = require '../utils/loadingMask'

config = require '../../config/config'

module.exports = CreateProject =
  chameleonBox: null
  modalPanel: null
  repoDir: "#{atom.packages.getLoadedPackage('chameleon').path}/src/butterfly-slim"
  projectTempDir: "#{atom.packages.getLoadedPackage('chameleon').path}/src/ProjectTemp"
  repoURI: 'https://git.oschina.net/chameleon/butterfly-slim.git'

  activate: (state) ->
    opt =
      title : desc.createProject
      subview : new CreateProjectView()

    @chameleonBox = new ChameleonBox(opt)
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()

    @chameleonBox.onFinish (options) => @createProject(options)

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!',@
      @modalPanel.show()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  createProject: (options) ->
    console.log options
    switch options.newType
      when "empty" then @newEmptyProject options
      when "frame" then @newFrameProject options
      when "template" then @newTemplateProject options

  # 空白项目创建
  newEmptyProject: (options) ->
    info = options.projectInfo
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          alert '项目创建成功'
          atom.project.addPath(info.appPath)
          @closeView()

        Util.copy(@projectTempDir, info.appPath, copySuccess)

    Util.createDir(info.appPath, createSuccess)

  # 带框架项目创建
  newFrameProject: (options) ->
    info = options.projectInfo
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          Util.copy @repoDir, "#{info.appPath}/modules/butterfly-slim", (err) =>
            throw err if err
            alert '项目创建成功'
            atom.project.addPath(info.appPath)
            @closeView()

        Util.copy @projectTempDir, info.appPath, copySuccess

    Util.createDir info.appPath, createSuccess
    # atom.notifications.addSuccess("Success: This is a notification");
    # success = (state, appPath) ->
    #   # atom.project.setPaths([appPath])
    #   @modalPanel.item.children(".loading-mask").remove()
    #

    # Util.getRepo(@repoDir, config.repoUri, success.bind(this))
    # LoadingMask = new LoadingMask()
    # @modalPanel.item.append(LoadingMask)

  newTemplateProject: (options) ->
