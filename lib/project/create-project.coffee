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
      console.log 'CreateProject was opened!'
      @modalPanel.show()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  createProject: (options) ->
    console.log options

    info = options.projectInfo
    nDir = new Directory(info.appPath)
    filePath = nDir.getPath()+'/'
    indexHtml = new File(filePath+'index.html')
    packageJson = new File(filePath+'package.json')

    p.then (success) ->
      if success is yes
        indexHtml.create()
        packageJson.create();
        alert '创建成功'
      else
        alert '创建失败'
