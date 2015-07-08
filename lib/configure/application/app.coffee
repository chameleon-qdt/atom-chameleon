{$} = require 'atom-space-pen-views'
AppConfigView = require './app-view'
ChameleonBox = require './../../utils/chameleon-box-view'

module.exports = ConfigureApp =
	appView: null
	modalPanel: null

	activate:(state) ->

		@chameleonBox = new AppConfigView()
		# @chameleonBox.contentView.getInitInput()
		@chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
		@chameleonBox.move()
		# @chameleonBox.onPrevClick = => @clearInput()
		@chameleonBox.onFinish (options) => @saveConfig(options)

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
      @modalPanel.show()

	saveConfig: (options) ->
		@chameleonBox.contentView.saveInput()
		alert "应用信息保存成功！"
		@closeView()

	clearInput: ->
		_chanmeleonBox = @chameleonBox
		options =
			message : "是否清空应用配置输入框信息？"
			detailedMessage : "注意！"
			buttons :
				'是' : ->
					_chanmeleonBox.contentView.clearInput()
				'否' : ->
		atom.confirm(options)
