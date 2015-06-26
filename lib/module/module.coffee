{$, Emitter, Directory, File, GitRepository, BufferedProcess} = require 'atom'
desc = require '../utils/text-description'
ChameleonBox = require '../utils/chameleon-box-view'
CreateModuleView = require './create-module-view'

module.exports = ModuleManager =
  createModuleView: null
  modalPanel: null

  activate: (state) ->
    opt =
      title : desc.createModule
      subview : new CreateModuleView()

    @chameleonBox = new ChameleonBox(opt)
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()

    @chameleonBox.onFinish (options) => @createProject(options)

  deactivate: ->
    @modalPanel.destroy()
    @CreateModuleView.destroy()

  serialize: ->
    createModuleViewState: @createModuleView.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateModuleView was opened!',@
      @modalPanel.show()

  CreateModule: (options)->
