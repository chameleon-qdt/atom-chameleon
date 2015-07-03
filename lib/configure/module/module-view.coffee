{Directory,File} = require 'atom'
desc = require './../../utils/text-description'
{$, View} = require 'atom-space-pen-views'
{TextEditorView} = require 'atom-space-pen-views'
PathM = require 'path'
fs = require 'fs-extra'

module.exports =
	class ModuleView extends View
		@content: ->
			@div class: 'configure-module container', =>
				@div class: 'row',outlet: 'main', =>
					@div class:'col-xs-12', =>
						@label '选择要配置的模块'
					@div outlet : 'moduleList'
				@div class: 'row hide',outlet: "second", =>
					@div class: "col-xs-12", =>
						@label class: 'col-sm-3 col-md-3', "模块名称"
						@div class: 'col-sm-9 col-md-9', =>
				      @subview 'moduleName', new TextEditorView(mini: true,placeholderText: 'moduleName...')
					@div class: "col-xs-12 ", =>
						@label class: 'col-sm-3 col-md-3', "模块版本"
						@div class: 'col-sm-9 col-md-9', =>
				      @subview 'moduleVersion', new TextEditorView(mini: true,placeholderText: 'moduleVersion...')
					@div class: "col-xs-12 ", =>
						@label class: 'col-sm-3 col-md-3', "模块描述"
						@div class: 'col-sm-9 col-md-9', =>
				      @subview 'moduleDescription', new TextEditorView(mini: true,placeholderText: 'moduleDescription...')
					@div class: "col-xs-12 ", =>
						@label class: 'col-sm-3 col-md-3', "模块入口"
						@div class: 'col-sm-9 col-md-9', =>
				      @subview 'moduleInput', new TextEditorView(mini: true,placeholderText: 'moduleInput...')


		serialize: ->

		attached: ->
			@prevBtn?= @parentView.prevBtn
			@nextBtn?= @parentView.nextBtn
			@cancelBtn?= @parentView.cancelBtn

		nextStep: ->
			if @second.hasClass('hide')
				console.log 'second has hide'
				flag = @getInitInput()
				if flag
					console.log 'true'
				else
					return
				@main.addClass('hide')
				@second.removeClass('hide')
				@nextBtn.text('保存')
				@prevBtn.removeClass('hide')
				@cancelBtn.text('还原')
			else
				real_path = $('input[type=checkbox]:checked').attr('value')
				file = new File(real_path)
				file.read(false).then (contents) =>
					contentList = JSON.parse(contents)
					contentList['name'] = @moduleName.getText()
					contentList['version'] = @moduleVersion.getText()
					contentList['description'] = @moduleDescription.getText()
					contentList['main'] = @moduleInput.getText()
					console.log contentList
					fs.writeJson real_path,contentList,null
				alert '保存成功！'
				@parentView.closeView()

		prevStep: ->
			@main.removeClass('hide')
			@second.addClass('hide')
			@nextBtn.text('下一步')
			@prevBtn.addClass('hide')
			@cancelBtn.text('取消')

		getInitInput: ->
			if this.find('input[type=checkbox]').is(':checked')
				real_path = $('input[type=checkbox]:checked').attr('value')
			else
				alert('请选择模块')
				return false
			console.log real_path
			file = new File(real_path)
			file.setEncoding('UTF-8')
			#读取文件中的内容
			file.read(false).then (contents) =>
				console.log JSON.parse(contents)
				contentList = JSON.parse(contents)
				@moduleName.setText(contentList['name'])
				@moduleVersion.setText(contentList['version'])
				@moduleDescription.setText(contentList['description'])
				@moduleInput.setText(contentList['main'])
				# contentList = contents.split(',')
				# console.log contentList
				# @moduleName.setText(contentList[0].split(':')[1])
				# @moduleVersion.setText(contentList[1].split(':')[1])
				# @moduleDescription.setText(contentList[2].split(':')[1])
				# @muduleInput.setText(contentList[3].split(':')[1])

		initialize: ->
			project_path = PathM.join $('.entry.selected span').attr('data-path'),'modules'
			directory = new Directory(project_path,false)
			# console.log directory.getPath()
			list = directory.getEntriesSync()
			_moduleList = @moduleList
			_moduleList.empty()
			printName = (file) ->
				# console.log file.getBaseName()
				if file.isDirectory()
					# console.log file.getPath()
					path = PathM.join file.getPath(),"package.json"
					file = new File(path)
					file.read(false).then (content) =>
						contentList = JSON.parse(content)
						_moduleList.append('<div class="col-md-3"><input value="'+file.getPath()+'" type="checkbox"><label>'+contentList['name']+'</label></div>')
						console.log contentList['name']
				else
					console.log file.getBaseName()
			printName file for file in list

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
