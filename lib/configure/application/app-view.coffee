{$,View,TextEditorView} = require 'atom-space-pen-views'
desc = require '../../utils/text-description'
{File,Directory} = require 'atom'
PathM = require 'path'
fs = require 'fs-extra'
ChameleonBox = require './../../utils/chameleon-box-view'

# module.exports =
class AppView extends View
	@content: ->
		@div class: 'container', =>
			@div class: "col-xs-12", =>
				@label class: 'col-sm-3 col-md-3', "应用标识"
				@div class: 'col-sm-9 col-md-9', =>
					@subview 'appId', new TextEditorView(mini: true,placeholderText: 'appId...')
			@div class: "col-xs-12 ", =>
				@label class: 'col-sm-3 col-md-3', "应用名称"
				@div class: 'col-sm-9 col-md-9', =>
					@subview 'appName', new TextEditorView(mini: true,placeholderText: 'appName...')
			@div class: "col-xs-12 ", =>
				@label class: 'col-sm-3 col-md-3', "应用版本"
				@div class: 'col-sm-9 col-md-9', =>
					@subview 'appVersion', new TextEditorView(mini: true,placeholderText: 'appVersion...')
			@div class: "col-xs-12 ", =>
				@label class: 'col-sm-3 col-md-3', "启动模块"
				@div class: 'col-sm-9 col-md-9', =>
					@subview 'appStartModule', new TextEditorView(mini: true,placeholderText: 'mainModule...')

	serialize: ->

	attached: ->
		# 首先检查 是否有应用的配置文件
		@getInitInput()
		@parentView.setNextBtn('finish',desc.save)
		@parentView.setPrevBtn('normal',desc.recovery)
		@parentView.prevBtn.addClass('other')

	saveInput: ->
		project_path = PathM.join $('.entry.selected span').attr('data-path'),'appConfig.json'
		file = new File(project_path)
		file.read(false).then (contents) =>
			contentList = JSON.parse(contents)
			contentList['identifier'] = @appId.getText()
			contentList['name'] = @appName.getText()
			contentList['version'] = @appVersion.getText()
			contentList['mainModule'] = @appStartModule.getText()
			# contentList['downloadUrl'] = @appDownloadUrl.getText()
			fs.writeJson project_path,contentList,null

	clearInput: ->
		@appId.setText('')
		@appName.setText('')
		@appVersion.setText('')
		@appStartModule.setText('')

	getInitInput: ->
		project_path = PathM.join $('.entry.selected span').attr('data-path'),'appConfig.json'
		console.log project_path
		file = new File(project_path)
		file.exists().then (resolve, reject) =>
			if resolve
				console.log 'open file'
				file.read(false).then (contents) =>
					console.log JSON.parse(contents)
					contentList = JSON.parse(contents)
					@appId.setText(contentList['identifier'])
					@appName.setText(contentList['name'])
					@appVersion.setText(contentList['version'])
					@appStartModule.setText(contentList['mainModule'])

	initialize: ->

	getElement: ->
		@element

	move: ->
		@element.parentElement.classList.add('down')

	destroy: ->

	nextStep:(box) ->
		console.log box
		box.nextStep()

	prevStep: (box) ->
		console.log box

module.exports =
class appConfigView extends ChameleonBox

  options :
    title : desc.projectConfig
    subview : new AppView()
