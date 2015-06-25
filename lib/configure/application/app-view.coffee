{$,View,TextEditorView} = require 'atom-space-pen-views'
desc = require '../../utils/text-description'
{File,Directory} = require 'atom'
module.exports =
	class AppView extends View
		@content: ->
			@div class: 'container', =>
				@div class: "col-xs-12 text-center", =>
					@label class: 'col-md-3', "应用标识"
					@div class: 'col-md-9', =>
						@subview 'appId', new TextEditorView(mini: true,placeholderText: 'appId...')
				@div class: "col-xs-12 text-center", =>
					@label class: 'col-md-3', "应用名称"
					@div class: 'col-md-9', =>
						@subview 'appName', new TextEditorView(mini: true,placeholderText: 'appName...')
				@div class: "col-xs-12 text-center", =>
					@label class: 'col-md-3', "应用版本"
					@div class: 'col-md-9', =>
						@subview 'appVersion', new TextEditorView(mini: true,placeholderText: 'appVersion...')
				@div class: "col-xs-12 text-center", =>
					@label class: 'col-md-3', "启动模块"
					@div class: 'col-md-9', =>
						@subview 'appStartModule', new TextEditorView(mini: true,placeholderText: 'appStartModule...')
				@div class: "col-xs-12 text-center", =>
					@label class: 'col-md-3', "模块下载位置"
					@div class: 'col-md-9', =>
						@subview 'appDownloadUrl', new TextEditorView(mini: true,placeholderText: 'appDownloadUrl...')

		serialize: ->

		activate: ->
			@prevBtn?= @parentView.prevBtn
			@nextBtn?= @parentView.nextBtn

		saveInput: ->
			  # body...
			file = new File(desc.appConfigPath)
			file.create().then =>
				configureMessage = '{"appId":"' + @appId.getText() + '","appName":"'+ @appName.getText() + '","appVersion":"'+ @appVersion.getText() + '","appStartModule":"' + @appStartModule.getText() + '","appDownloadUrl":"' + @appDownloadUrl.getText() + '"}'
				console.log configureMessage
				file.write(configureMessage)


		clearInput: ->
			@appId.setText('')
			@appName.setText('')
			@appVersion.setText('')
			@appStartModule.setText('')
			@appDownloadUrl.setText('')

		getInitInput: ->
			file = new File(desc.appConfigPath)
			file.setEncoding('UTF-8')
			#读取文件中的内容
			file.read(false).then (contents) =>
				console.log JSON.parse(contents)
				contentList = JSON.parse(contents)
				@appId.setText(contentList['appId'])
				@appName.setText(contentList['appName'])
				@appVersion.setText(contentList['appVersion'])
				@appStartModule.setText(contentList['appStartModule'])
				@appDownloadUrl.setText(contentList['appDownloadUrl'])

		initialize: ->

		getElement: ->
			@element

		move: ->
			@element.parentElement.classList.add('down')

		destroy: ->
