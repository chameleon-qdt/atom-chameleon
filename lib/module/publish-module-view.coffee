desc = require '../utils/text-description'
util = require '../utils/util'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'
ChameleonBox = require '../utils/chameleon-box-view'
Settings = require '../settings/settings'
fs = require 'fs-extra'
client = require '../utils/client'

class PublishModuleInfoView extends View

	@content: ->
		@div class : 'publishModule', =>
			@div outlet : 'first' , =>
				@h2 desc.publishModulePageOneTitle
				@div outlet : 'moduleList'
			@div outlet : 'second',class : 'hide', =>
				@h2 desc.publishModulePageTwoTitle
				@label id:'tips'
				@div outlet : 'moduleMessageList'
				@input type:"hidden",id:"projectIdentifier"
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
		length = 0
		_parentView = @parentView
		printName = (file) =>
			console.log file
			if file.isDirectory()
				path =PathM.join file.getPath(),"package.json"
				file2 = new File(path)
				file2.exists().then (resolve,reject) =>
					if resolve
						file2.read(false).then (content) =>
							length = length + 1
							contetnList = JSON.parse(content)
							_moduleList.append('<div class="col-md-3"><input value="'+file2.getPath()+'" type="checkbox"><label>'+contetnList['name']+'</label></div>')
		directory.exists().then (resolve, reject) =>
			if resolve
				list = directory.getEntriesSync()
				_moduleList.empty()
				printName file for file in list
				console.log length
				if length == 0
					_parentView.enable = false
					alert "没有任何模块"
					return
				@third.addClass('hide')
				@first.removeClass('hide')
			else
				alert '不存在路径['+appPath+']'
				@parentView.closeView()
		console.log 'init finish'
	nextStep: ->
		_parentView = @parentView
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
			# 输出模块选项
			printModuleMessage = (checkbox) ->
				if $(checkbox).is(':checked')
					moduleFolderCallBack = (exists) ->
						if exists
							moduleConfigCallBack = (exists) ->
								if exists
									contentList = JSON.parse(fs.readFileSync($(checkbox).attr('value')))
									obj =
										moduleName: contentList['name']
										uploadVersion: contentList['version']
										identifier: contentList['identifier']
										version: contentList['serviceVersion']
										modulePath: $(checkbox).attr('value')
									params =
										sendCookie: true
										success: (data) =>
											if true
												console.log "check version success"
												# data = JSON.parse(body)
												# console.log data["version"],obj.identifier,obj.uploadVersion
												if data['version'] != ""
													obj['version'] = data['version']
												else
													obj['version'] = "0.0.0"
												item = new ModuleMessageItem(obj)
												item.find('button').attr('disabled',true)
												# console.log item.find('button')
												_moduleMessageList.append(item)
												util.fileCompression(PathM.join $(checkbox).attr('value'),'..')
												callbackOper = ->
													item.find('button').attr("disabled",false)
												$(".#{obj.identifier}").fadeOut(3000,callbackOper)
										error : =>
											console.log "获取模板最新版本 的url 调不通"
									client.getModuleLastVersion(params,obj.identifier)
									# item = new ModuleMessageItem(obj)
									# item.find('button').attr('disabled',true)
									# _moduleMessageList.append(item)
									# util.fileCompression(PathM.join $(checkbox).attr('value'),'..')
									# callbackOper = ->
									# 	item.find('button').attr("disabled",false)
									# $(".#{obj.identifier}").fadeOut(3000,callbackOper)
							configFilePath = PathM.join $(checkbox).attr('value')
							fs.exists(configFilePath,moduleConfigCallBack)
					folderPath = PathM.join $(checkbox).attr('value'),'..'
					fs.exists(folderPath,moduleFolderCallBack)

			printModuleMessage checkbox for checkbox in checkboxList

			@second.removeClass('hide')
			@first.addClass('hide')
			@parentView.prevBtn.removeClass('hide')
			@parentView.nextBtn.text('完成')
		else
			@parentView.closeView()

	attached: ->
		@settings = Settings

		if !util.isLogin()
			@settings.activate()
			@parentView.enable = false
			alert '请先登录'
		else
			@attached2()

	attached2: ->
		$('#tips').fadeOut()
		test = $('.entry.selected span')
		_parentView = @parentView
		_moduleList = @moduleList
		if test.length == 0
			@first.addClass('hide')
			@third.removeClass('hide')
			if @second.hasClass('hide')
				return
			else
				@second.addClass('hide')
			return
		else
		  project_path = PathM.join $('.entry.selected span').attr('data-path')
			if @first.hasClass('hide')
				@first.removeClass('hide')
				@second.addClass('hide')
			#这是一个回调函数 的开始
			# console.log "hello"
			if fs.existsSync(project_path)
			#
			# callbackDirectory = (exists) ->
				if true
					projectStats = fs.statSync(project_path)
					#判断是否目录
					if projectStats.isDirectory()
						configFilePath = PathM.join project_path,"appConfig.json"
						#判断  appConfig.json 是否存在
						if fs.existsSync(configFilePath)
							configFileStats = fs.statSync(configFilePath)
							file = new File(configFilePath)
							file.read(false).then (content) =>
								contentList = JSON.parse(content)
								$('#projectIdentifier').attr('value',contentList['identifier'])
							project_path = PathM.join project_path,"modules"
							if !fs.existsSync(project_path)
								_parentView.enable = false
								alert "请选择变色龙项目（不存在modules文件）"
								return
							modulesStats = fs.statSync(project_path)
							if modulesStats.isFile()
								_parentView.enable = false
								alert "请选择变色龙项目（不存在modules文件）"
								return
						else
							_parentView.enable = false
							alert "请选择变色龙项目(不存在 appConfig.json)"
							return
					else
						_parentView.enable = false
						alert "请选择变色龙项目"
						return
				else
					_parentView.enable = false
					alert "文件不存在"
					return
				modulesCount = 0
				list = fs.readdirSync(project_path)
				fileLength = 0
				printName = (filePath) ->
					# console.log fileLength
					stats = fs.statSync(filePath)
					if stats.isDirectory()
						packageFilePath = PathM.join filePath,"package.json"
						if fs.existsSync(packageFilePath)
							packageFileStats = fs.statSync(packageFilePath)
							if packageFileStats.isFile()
								fileLength = fileLength + 1
								getMessage = (err, data) =>
									if err
										console.log "error"
									else
									  contentList = JSON.parse(data)
										_moduleList.append('<div class="col-md-3"><input value="'+packageFilePath+'" type="checkbox"><label>'+contentList['name']+'</label></div>')
										# console.log data
								options =
									encoding: "UTF-8"
								fs.readFile(packageFilePath,options,getMessage)
				_moduleList.empty()
				printName PathM.join project_path,fileName for fileName in list
				if fileLength == 0
					_parentView.enable = false
					alert "没有任何模块"
					return
			#回调函数 的结束
			# fs.exists(project_path,callbackDirectory)

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
					@label obj.uploadVersion,outlet:"uploadVersion"
				@div class : 'col-sm-6 col-md-6', =>
					@label '服务器版本:'
					@label obj.version,outlet:"version"

			@div class : 'col-sm-12 col-md-12', =>
				@div class : 'col-sm-2 col-md-2', =>
					@label '跟新日志:'
				@div class : 'col-sm-6 col-md-6', =>
					@subview 'updateLog', new TextEditorView(mini: true,placeholderText: 'update log...')
				@div class : 'col-sm-4 col-md-4', =>
					@button '上传',value:obj.modulePath,class:'btn upload_module_btn',click: 'postModuleMessage'
					@button '上传并应用',value:obj.modulePath,class:'btn'
			@div class : 'col-sm-12 col-md-12 ', =>
				@label "正在打包文件......",class:"#{obj.identifier}"

	fileChange: (param1,param2) ->
		console.log $(param2).val()
		console.log $(param2)
		@zipPath.setText($(param2).val())

	postModuleMessage:(btn,btn2) ->
		zipPath = PathM.join $(btn2).val(),"..",".."
		console.log zipPath
		zipName = PathM.basename(PathM.join $(btn2).val(),"..") + '.zip'
		console.log zipName
		_version = @version
		_uploadVersion = @uploadVersion
		uploadVersion = @uploadVersion.text().split('.')
		version = @version.text().split('.')
		if uploadVersion[0] < version[0]
			alert "上传版本不大于服务器版本"
			return
		else if uploadVersion[0] == version[0]
			if uploadVersion[1] < version[1]
				alert "上传版本不大于服务器版本"
				return
			else if uploadVersion[1] == version[1]
				if uploadVersion[2] <= version[2]
					alert "上传版本不大于服务器版本"
					return
			  # body...
		# console.log "success"
		fileParams =
			formData: {
				up_file: fs.createReadStream(PathM.join zipPath,zipName)
			}
			sendCookie: true
			success: (data) =>
				# data = JSON.parse(body)
				console.log "上传文件成功"
				configFilePathCallBack = (exists) ->
					if exists
						file = new File($(btn2).val())
						file.read(false).then (content) =>
							contentList = JSON.parse(content)
							console.log contentList['version'],contentList['identifier']
							params =
								form:{
									module_tag: contentList['identifier'],
									module_name: contentList['name'],
									module_desc: contentList['description'],
									version: contentList['version'],
									url_id: data['url_id'],
									update_log: '还没调上传文件的接口'
								}
								sendCookie: true
								success: (data) =>
									console.log data
									# data = JSON.parse(body)
									_version.text(_uploadVersion.text())
									alert "上传模块成功"
									console.log "upload success"
								error: =>
								  alert "error"
							client.postModuleMessage(params)
					else
						console.log "文件不存在#{$(btn2).val()}"
				fs.exists($(btn2).val(),configFilePathCallBack)
			error: =>
				alert "上传文件失败"
		client.uploadFile(fileParams,"module","yuzhe@163.com")

module.exports =
class PublishModuleView extends ChameleonBox

  options :
    title : desc.publishModule
    subview : new PublishModuleInfoView()
