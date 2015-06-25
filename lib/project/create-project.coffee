{$,Emitter,Directory,File} = require 'atom'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateProjectView = require './create-project-view'

module.exports = CreateProject =
  chameleonBox: null
  modalPanel: null

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

    info = options.projectInfo
    appConfig = new File(info.appPath+'/'+'package.json')
    console.log JSON.stringify(info)
    appConfig.create()
    .then (isSuccess,a,b,c) ->
      console.log isSuccess,a,b,c
      if isSuccess is yes
        appConfig.setEncoding('utf8')
        appConfig.write(JSON.stringify(info))
        alert '项目创建成功！'
      else
        alert '项目创建失败...'
    .then (a,b,c,d) ->
      console.log a,b,c,d
