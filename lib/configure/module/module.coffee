{$,Emitter} = require 'atom-space-pen-views'
ModuleView = require './module-view'
ChameleonBox = require '../../utils/chameleon-box-view'

module.exports = ConfigureModule =
	moduleView: null
	modalPanel: null

	activate:(state) ->
		opt =
      title : '模块配置'
      subview : new ModuleView()
      hideNextBtn :　true
      hidePrevBtn :　true

    @chameleonBox = new ChameleonBox(opt)
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()
    @chameleonBox.onCancelClick = => @closeView()
    @chameleonBox.onCloseClick = => @closeView()

	closeView: ->
		if @modalPanel.isVisible()
			@modalPanel.hide()

	deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!'
      @modalPanel.show()
