desc = require '../utils/text-description'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'
ChameleonBox = require '../utils/chameleon-box-view'

class PublishModuleInfoView extends View

	@content: ->
		@div class : 'publishModule', =>
			@div outlet : 'first' , =>
				@h2 desc.publishModulePageOneTitle
				@div outlet : 'moduleList'
			@div outlet : 'second',class : 'hide', =>
				@h2 desc.publishModulePageTwoTitle
				@div outlet : 'moduleMessageList'
			@div outlet : 'third', class : 'hide', =>
				@div class: 'new-project', =>
					@div class:'form-horizontal', =>
				    @div class: 'form-group', =>
				    @h2 '选择项目'
			    @div class: 'form-group', =>
				    @label '路径', class: 'col-sm-3 control-label'
				    @div class: 'col-sm-9', =>
              @subview 'appPath', new TextEditorView(mini: true)
              @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'open'

	open : ->
		console.log "ssss"
		atom.pickFolder (paths) =>
			if paths?
				console.log paths[0]
				path = PathM.join paths[0]
				console.log  path
				@appPath.setText path

	prevStep: ->
		console.log 'click prev button'
		@first.removeClass('hide')
		@second.addClass('hide')
		@parentView.prevBtn.addClass('hide')
		@parentView.nextBtn.text('下一步')

	thirdClickNext: ->
		console.log @appPath.getText()
		@initFirst(@appPath.getText())


	initFirst:(appPath) ->
		console.log "init"
		appPath = PathM.join appPath,'modules'
		directory = new Directory(appPath)
		_moduleList = @moduleList
		printName = (file) ->
			console.log file
			if file.isDirectory()
				path =PathM.join file.getPath(),"package.json"
				file2 = new File(path)
				file2.exists().then (resolve,reject) =>
					if resolve
						file2.read(false).then (content) =>
							console.log 'in'
							contetnList = JSON.parse(content)
							console.log _moduleList
							console.log file2.getPath()
							console.log contetnList['name']
							_moduleList.append('<div class="col-md-3"><input value="'+file2.getPath()+'" type="checkbox"><label>'+contetnList['name']+'</label></div>')
							console.log 'ssss'
		directory.exists().then (resolve, reject) =>
			if resolve
				list = directory.getEntriesSync()
				_moduleList.empty()
				printName file for file in list
				@third.addClass('hide')
				@first.removeClass('hide')
			else
				alert '不存在路径['+appPath+']'
				@parentView.closeView()
		console.log 'init finish'
	nextStep: ->
		console.log 'click next button'
		if @third.hasClass('hide')
			console.log 'third is hide'
		else
			@thirdClickNext()
			return
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
					file.exists().then (resolve,reject) =>
						if resolve
							console.log file.getPath()
							file.read(false).then (content) =>
								console.log file.getPath()
								contentList = JSON.parse(content)
								obj =
									moduleName : contentList['name']
									uploadVersion : contentList['version']
									version : contentList['serviceVersion']
								item = new ModuleMessageItem(obj)
								_moduleMessageList.append(item)
								console.log item

			printModuleMessage checkbox for checkbox in checkboxList

			@second.removeClass('hide')
			@first.addClass('hide')
			@parentView.prevBtn.removeClass('hide')
			@parentView.nextBtn.text('完成')
		else
			@parentView.closeView()

	attached: ->
		# console.log 'module publish'
		console.log 'module'
		test = $('.entry.selected span')
		console.log $('.entry.selected span')
		if test.length == 0
			console.log 'is null'
			@first.addClass('hide')
			@third.removeClass('hide')
			if @second.hasClass('hide')
				return
			else
				@second.addClass('hide')
			return
		else
		  project_path = PathM.join $('.entry.selected span').attr('data-path'),'modules'
		  directory = new Directory(project_path,false)
			console.log project_path+''
			_moduleList = @moduleList
			printName = (file) ->
				console.log file.getBaseName()
				if file.isDirectory()
					console.log file.getPath()
					path = PathM.join file.getPath(),"package.json"
					file2 = new File(path)
					console.log path
					file2.exists().then (resolve,reject) =>
						if resolve
							file2.read(false).then (content) =>
								contentList = JSON.parse(content)
								_moduleList.append('<div class="col-md-3"><input value="'+file2.getPath()+'" type="checkbox"><label>'+contentList['name']+'</label></div>')
								console.log contentList['name']
			console.log 'read'
			directory.exists().then (resolve, reject) =>
				console.log 'resolve = '+resolve
				if resolve
					console.log directory.getPath()
					list = directory.getEntriesSync()
					_moduleList.empty()
					printName file for file in list
				else
					alert '不存在路径['+project_path+']'
					@parentView.closeView()


	getElement: ->
		@element

	serialize: ->

	# attached: ->

class ModuleMessageItem extends View
	@content: (obj) ->
		@div class: 'col-sm-12 col-md-12',=>
			@div class: 'col-sm-12 col-md-12', =>
				@label '模块名称: '
				@label obj.moduleName
			@div class : 'col-sm-12 col-md-12', =>
				@div class : 'col-sm-6 col-md-6', =>
					@label '上传版本: '
					@label obj.uploadVersion
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

module.exports =
class PublishModuleView extends ChameleonBox

  options :
    title : desc.publishModule
    subview : new PublishModuleInfoView()
