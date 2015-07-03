desc = require '../utils/text-description'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'

module.exports =
class PublishModuleView extends View
	@content: ->
		@div class : 'publishModule', =>
			@div outlet : 'first' , =>
				@h2 desc.publishModulePageOneTitle
				@div outlet : 'moduleList'
			@div outlet : 'second',class : 'hide', =>
				@h2 desc.publishModulePageTwoTitle
				@div outlet : 'moduleMessageList'

	prevStep: ->
		console.log 'click prev button'
		@first.removeClass('hide')
		@second.addClass('hide')
		@parentView.prevBtn.addClass('hide')
		@parentView.nextBtn.text('下一步')

	nextStep: ->
		console.log 'click next button'
		if @parentView.prevBtn.hasClass('hide')
			if this.find('input[type=checkbox]').is(':checked')
				console.log 'has checked'
			else
				alert '你还没有选择模块。'
				return
			checkboxList = this.find('input[type=checkbox]')
			_moduleMessageList = @moduleMessageList
			_moduleMessageList.empty()
			printModuleMessage = (checkbox) ->
				if $(checkbox).is(':checked')
					console.log $(checkbox).attr('value')
					file = new File($(checkbox).attr('value'))
					file.read(false).then (content) =>
						contentList = JSON.parse(content)
						obj =
							moduleName : contentList['name']
							uploadVersion : contentList['version']
							version : contentList['serviceVersion']
						item = new ModuleMessageItem(obj)
						console.log item
						_moduleMessageList.append(item)

			printModuleMessage checkbox for checkbox in checkboxList

			@second.removeClass('hide')
			@first.addClass('hide')
			@parentView.prevBtn.removeClass('hide')
			@parentView.nextBtn.text('完成')
		else
			@parentView.closeView()

	initialize: ->
		# console.log 'module publish'
		project_path = PathM.join $('.entry.selected span').attr('data-path'),'modules'
		directory = new Directory(project_path,false)
		console.log directory.getPath()
		list = directory.getEntriesSync()
		_moduleList = @moduleList
		_moduleList.empty()
		printName = (file) ->
			# console.log file.getBaseName()
			if file.isDirectory()
				console.log file.getPath()
				path = PathM.join file.getPath(),"package.json"
				file = new File(path)
				file.read(false).then (content) =>
					contentList = JSON.parse(content)
					_moduleList.append('<div class="col-md-3"><input value="'+file.getPath()+'" type="checkbox"><label>'+contentList['name']+'</label></div>')
					console.log contentList['name']
			else
				console.log file.getBaseName()
		printName file for file in list

	getElement: ->
		@element

	serialize: ->

	attached: ->

class ModuleMessageItem extends View
	@content: (obj) ->
		@div class: 'col-sm-12 col-md-12',=>
			@div class: 'col-sm-12 col-md-12', =>
				@label '模块名称: '
				@label obj.moduleName
			@div class : 'col-sm-12 col-md-12', =>
				@div class : 'col-sm-6 col-md-6', =>
					@label '上传版本: '
					@label obj.uplaodVersion
				@div class : 'col-sm-6 col-md-6', =>
					@label '服务器版本:'
					@label obj.version

			@div class : 'col-sm-12 col-md-12', =>
				@div class : 'col-sm-2 col-md-2', =>
					@label '跟新日志:'
				@div class : 'col-sm-6 col-md-6', =>
					@subview 'moduleDescription', new TextEditorView(mini: true,placeholderText: 'update log...')
				@div class : 'col-sm-4 col-md-4', =>
					@button '上传'
					@button '上传并应用'


			# @label '模块名称 : '
			# @label obj.moduleName
			# @br
			# @label '上传版本 : '
			# @label obj.uploadVersion
