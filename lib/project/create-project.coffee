{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateProjectView = require './create-project-view'
LoadingMask = require '../utils/loadingMask'

module.exports = CreateProject =
  chameleonBox: null
  modalPanel: null
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

  gitClone: (appPath, cb) ->
    command = 'git'
    args = ['clone', @repoURI, appPath]
    stdout = (output) -> console.log(output)
    exit = (code) -> cb(code, appPath)
    process = new BufferedProcess({command, args, stdout, exit})

  newEmptyProject: (options) ->
    info = options.projectInfo
    appConfig = new File(info.appPath+'/'+'appConfig.json')
    appConfig.create()
      .then (isSuccess) =>
        console.log isSuccess
        if isSuccess is yes
          appConfig.setEncoding('utf8')
          appConfig.write(JSON.stringify(info))
          alert '项目创建成功！'
          @closeView()
        else
          alert '项目创建失败...'

  newFrameProject: (options) ->
    success = (state, appPath) ->
      atom.project.setPaths([appPath])
      @modalPanel.item.children(".loading-mask").remove()
      @closeView()

    @gitClone(info.appPath, success.bind(this))
    LoadingMask = new LoadingMask()
    @modalPanel.item.append(LoadingMask)

  newTemplateProject: (options) ->
