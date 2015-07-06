ChameleonBox = require './../utils/chameleon-box-view'
PublishModelView = require './publish-module-view'
desc = require './../utils/text-description'
{$} = require 'atom-space-pen-views'
module.exports = PublishModule =
	chameleonBox : null
	modalPanel : null

	activate: (state) ->
		# opt =
		# 	title: desc.publishModule
		# 	subview : new PublishModelView()


		@chameleonBox = new PublishModelView()
		@chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
		@chameleonBox.move()
		@chameleonBox.cancelBtn.hide()
		@chameleonBox.prevBtn.addClass('hide')

		@chameleonBox.onCloseClick = => @closeView()
		@chameleonBox.onCancelClick = => @closeView()
		@chameleonBox.onPrevClick = => @chameleonBox.contentView.prevStep()
		@chameleonBox.onNextClick = => @chameleonBox.contentView.nextStep()

	deactivate: ->
		@modalPanel.destroy()
		@chameleonBox.destroy()

	serialize: ->
		chameleonBoxState: @chameleonBox.serialize()
	openView: ->
    unless @modalPanel.isVisible()
      console.log 'PublishModuleView was opened!'
      @modalPanel.show()
	closeView: ->
		if @modalPanel.isVisible()
			@modalPanel.hide()
