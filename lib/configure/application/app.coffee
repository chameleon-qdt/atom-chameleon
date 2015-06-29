{$} = require 'atom-space-pen-views'
AppView = require './app-view'
ChameleonBox = require './../../utils/chameleon-box-view'

module.exports = ConfigureApp =
	appView: null
	modalPanel: null

	activate:(state) ->
		opt =
			title: '应用配置'
			subview: new AppView()
			hideNextBtn: false
			hidePrevBtn: false

		@chameleonBox = new ChameleonBox(opt)
		@chameleonBox.prevBtn.text('还原')
		@chameleonBox.nextBtn.text('保存')
		@chameleonBox.contentView.getInitInput()
		@chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
		@chameleonBox.move()
		@chameleonBox.onCancelClick = =>@closeView()
		@chameleonBox.onCloseClick = => @closeView()
		@chameleonBox.prevBtn.text('清空')
		@chameleonBox.nextBtn.text('保存')
		@chameleonBox.onNextClick = => @saveInput()
		@chameleonBox.onPrevClick = => @clearInput()

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
      # console.log 'CreateProject was opened!'
      @modalPanel.show()

	saveInput: ->
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
