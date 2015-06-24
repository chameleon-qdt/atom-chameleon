{Directory,File} = require 'atom'
desc = require './../../utils/text-description'
{$, View} = require 'atom-space-pen-views'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
	class ModuleView extends View
		@content: ->
			@div class: 'configure-module container', =>
				@div class: 'row',outlet: 'main', =>
					@div class:'col-xs-12', =>
						@label '选择要配置的模块'
					@div class: "col-xs-6 text-center", =>
						@input type: 'checkbox'
						@label '模块一'
				@div class: 'row hide',outlet: "second", =>
					@div class: "col-xs-12 text-center", =>
						@label class: 'col-md-3', "模块名称"
						@div class: 'col-md-9', =>
				      @subview 'moduleName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
					@div class: "col-xs-12 text-center", =>
						@label class: 'col-md-3', "模块版本"
						@div class: 'col-md-9', =>
				      @subview 'moduleVersion', new TextEditorView(mini: true,placeholderText: 'moduleVersion...')
					@div class: "col-xs-12 text-center", =>
						@label class: 'col-md-3', "模块描述"
						@div class: 'col-md-9', =>
				      @subview 'moduleDescription', new TextEditorView(mini: true,placeholderText: 'moduleDescription...')
					@div class: "col-xs-12 text-center", =>
						@label class: 'col-md-3', "模块入口"
						@div class: 'col-md-9', =>
				      @subview 'moduleInput', new TextEditorView(mini: true,placeholderText: 'moduleInput...')


		serialize: ->

		attached: ->
			@prevBtn?= @parentView.prevBtn
			@nextBtn?= @parentView.nextBtn
			@cancelBtn?= @parentView.cancelBtn

		nextStep: ->
			if @second.hasClass('hide')
				console.log 'second has hide'
				@main.addClass('hide')
				@second.removeClass('hide')
				@nextBtn.text('保存')
				@prevBtn.removeClass('hide')
				@cancelBtn.text('还原')
			else
				console.log 'save file'
				file = new File(desc.moduleConfigPath)
				file.create()
				configureMessage = '{"moduleName":"' + @moduleName.getText() + '","moduleVersion":"'+ @moduleVersion.getText() + '","moduleDescription":"'+ @moduleDescription.getText() + '","moduleInput":"' + @moduleInput.getText() + '"}'
				# console.log configureMessage
				file.write(configureMessage)

		prevStep: ->
			@main.removeClass('hide')
			@second.addClass('hide')
			@nextBtn.text('下一步')
			@prevBtn.addClass('hide')
			@cancelBtn.text('取消')

		getInitInput: ->
			file = new File(desc.moduleConfigPath)
			file.setEncoding('UTF-8')
			#读取文件中的内容
			file.read(false).then (contents) =>
				console.log JSON.parse(contents)
				contentList = JSON.parse(contents)
				@moduleName.setText(contentList['moduleName'])
				@moduleVersion.setText(contentList['moduleVersion'])
				@moduleDescription.setText(contentList['moduleDescription'])
				@moduleInput.setText(contentList['moduleInput'])
				# contentList = contents.split(',')
				# console.log contentList
				# @moduleName.setText(contentList[0].split(':')[1])
				# @moduleVersion.setText(contentList[1].split(':')[1])
				# @moduleDescription.setText(contentList[2].split(':')[1])
				# @muduleInput.setText(contentList[3].split(':')[1])

		initialize: ->

	  # Tear down any state and detach
	  # destroy: ->
	  #   if @modalPanel?
	  #     @modalPanel.destroy()
	  #   @element.remove()
	  #
	  getElement: ->
	    @element

		move: ->
			@element.parentElement.classList.add('down')
		destroy: ->

		onCloseClick: ->

		onCancelClick: ->
		  console.log 'onCancelClick'
