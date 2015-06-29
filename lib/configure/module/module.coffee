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
      hideNextBtn :　false
      hidePrevBtn :　true


    @chameleonBox = new ChameleonBox(opt)
		@chameleonBox.contentView.getInitInput()
		@chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
		@chameleonBox.move()
		@chameleonBox.prevBtn.addClass('hide')
		@chameleonBox.onCancelClick = => @clearOrCloseView()
		@chameleonBox.onCloseClick = => @closeView()
		@chameleonBox.onNextClick = => @chameleonBox.contentView.nextStep()
		@chameleonBox.onPrevClick = => @chameleonBox.contentView.prevStep()


	closeView: ->
		if @modalPanel.isVisible()
			@modalPanel.hide()

	clearOrCloseView: ->
		# console.log @chameleonBox.contentView.second
		if @chameleonBox.contentView.second.hasClass('hide')
			if @modalPanel.isVisible()
				@modalPanel.hide()
			  # body...
		else
			@chameleonBox.contentView.moduleName.setText("")
			@chameleonBox.contentView.moduleVersion.setText("")
			@chameleonBox.contentView.moduleDescription.setText("")
			@chameleonBox.contentView.moduleInput.setText("")

	deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      # console.log 'CreateProject was opened!'
      @modalPanel.show()
