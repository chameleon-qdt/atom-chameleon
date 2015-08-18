desc = require '../utils/text-description'
util = require '../utils/util'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'
UtilExtend = require './../utils/util-extend'
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
			printModuleMessage = (checkbox) =>
				if $(checkbox).is(':checked')
					moduleFolderCallBack = (exists) =>
						if exists
							moduleConfigCallBack = (exists) =>
								if exists
									console.log $(checkbox).attr('value')
									contentList = JSON.parse(fs.readFileSync($(checkbox).attr('value')))
									obj =
										moduleName: contentList['name']
										uploadVersion: contentList['version']
										identifier: contentList['identifier']
										version: contentList['serviceVersion']
										modulePath: $(checkbox).attr('value')
									console.log contentList['identifier']
									if contentList['identifier'] is "undefined" || contentList['identifier'] is ""
										console.log contentList['identifier']
										alert "模块#{contentList['name']}的identifer不存在！"
										@prevStep()
										return
									if contentList['version'] is "undefined" || contentList['version'] is ""
										alert "模块#{contentList['name']}的version不存在！"
										@prevStep()
										return
									params =
										sendCookie: true
										success: (data) =>
											if true
												console.log "check version success"
												console.log data
												#获取版本 和 上传次数 ， 并判断和初始化  obj['build'] obj['version']
												if data['build']? and data['build'] != ""
													obj["build"] = parseInt(data['build'])
												else
													obj["build"] = 0

												if data['version']? and data['version'] != ""
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
			console.log "#{test.length}"
			@first.addClass('hide')
			@third.removeClass('hide')
			if @second.hasClass('hide')
				return
			else
				@second.addClass('hide')
				# @third.addClass('hide')
			return
		else
		  project_path = PathM.join $('.entry.selected span').attr('data-path')
			if @first.hasClass('hide')
				@first.removeClass('hide')
				@third.addClass('hide')
				@second.addClass('hide')
			#这是一个回调函数 的开始
			# console.log "hello"
			projectPaths = atom.project.getPaths()
			isRootNodeIsBSLProject = false
			rootPath = null
			checkContains = (path) =>
				directory = new Directory(path)
				if directory.contains(project_path)
					if UtilExtend.checkIsBSLProject(path)
						isRootNodeIsBSLProject = true
						rootPath = path
			checkContains path for path in projectPaths
			console.log isRootNodeIsBSLProject
			returnMessage = null
			returnStatus = false
			if fs.existsSync(project_path)
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
							# _parentView.enable = false
							returnMessage = "请选择变色龙项目（不存在modules文件）"
							returnStatus = true
						modulesStats = fs.statSync(project_path)
						if modulesStats.isFile()
							# _parentView.enable = false
							returnMessage = "请选择变色龙项目（不存在modules文件）"
							returnStatus = true
					else
						# _parentView.enable = false
						returnMessage = "请选择变色龙项目(不存在 appConfig.json)"
						returnStatus = true
				else
					# _parentView.enable = false
					returnMessage = "请选择变色龙项目"
					returnStatus = true
			else
				_parentView.enable = false
				alert "文件不存在"
				return
			if returnStatus
				if isRootNodeIsBSLProject
					project_path = rootPath
					project_path = PathM.join project_path,"modules"
					if !fs.existsSync(project_path)
						_parentView.enable = false
						alert returnMessage
						return
					modulesStats = fs.statSync(project_path)
					if modulesStats.isFile()
						_parentView.enable = false
						alert returnMessage
						return
				else
					_parentView.enable = false
					alert returnMessage
					return
			modulesCount = 0
			list = fs.readdirSync(project_path)
			fileLength = 0
			printName = (filePath) ->
				console.log fileLength
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
					@label obj.version,outlet:"version",value:obj.build
			@div class : 'col-sm-12 col-md-12', =>
				@div class : 'col-sm-2 col-md-2', =>
					@label '更新日志:'
				@div class : 'col-sm-6 col-md-6', =>
					@subview 'updateLog', new TextEditorView(mini: true,placeholderText: 'update log...')
				@div class : 'col-sm-4 col-md-4 publishModulecheckbox', =>
					@button '上传',value:obj.modulePath,outlet:"uploadBtn",class:'btn upload_module_btn',click: 'postModuleMessage'
					@button '应用到',value:obj.identifier,class:'btn',click: 'showAppList'
					# @button '上传并应用',value:obj.modulePath,class:'btn'
			@div class : 'col-sm-12 col-md-12 ', =>
				@label "正在打包文件......",class:"#{obj.identifier}"
			@div class : 'col-sm-12 col-md-12',outlet:"appListView"


	fileChange: (param1,param2) ->
		console.log $(param2).val()
		console.log $(param2)
		@zipPath.setText($(param2).val())

	showAppList:(btn,btn2) ->
		# console.log $(btn2).val()
		params =
			sendCookie: true
			success: (data) =>
				# console.log "success"
				console.log data
				options = ""
				printAppList = (object) =>
					if object is null
						return
					options = options + "<input type='checkbox' value='#{object.id}' >#{object.name}"
				printAppList object for object in data
				options = options + "<button name='uploadMApp' class='btn'>确认</button>"
				console.log @.find("button[name=uploadMApp]")
				@appListView.append(options)
				@.find("button[name=uploadMApp]").on 'click',(e) => @actModuleToApp(e)
			error:() =>
				console.log "error"
		client.getAppListByModule(params,$(btn2).val())

	#  upload_module_use_to_application
	actModuleToApp:(e) ->
		# alert "ssss"
		checkboxList = this.find('input[type=checkbox]')
		app_ids = []
		getAppId = (checkbox) =>
			if $(checkbox).is(':checked')
				app_ids.push($(checkbox).val())
		# console.log checkboxList
		getAppId checkbox for checkbox in checkboxList
		zipPath = PathM.join @uploadBtn.val(),"..",".."
		# console.log zipPath
		zipName = PathM.basename(PathM.join @uploadBtn.val(),"..") + '.zip'
		# console.log zipName

		_version = @version
		_uploadVersion = @uploadVersion
		uploadVersion = @uploadVersion.text()
		version = @version.text()
		#校验版本信息
		result = UtilExtend.checkUploadModuleVersion(uploadVersion,version)
		if result["error"]
			alert result["errorMessage"]
			return

		fileParams =
			formData: {
				up_file: fs.createReadStream(PathM.join zipPath,zipName)
			}
			sendCookie: true
			success: (data) =>
				console.log "上传文件成功"
				data2={}
				# console.log app_ids
				configFilePathCallBack = (exists) =>
					if exists
						file = new File(@uploadBtn.val())
						file.read(false).then (content) =>
							contentList = JSON.parse(content)
							# 当  配置信息中不存在build字段时，新建字段 初始化为 1
							#否则  +1
							contentList['build'] = parseInt(_version.attr('value'))
							contentList['build'] = contentList['build'] + 1
							params =
								form:{
									module_tag: contentList['identifier'],
									module_name: contentList['name'],
									module_desc: contentList['description'],
									version: contentList['version'],
									url_id: data['url_id'],
									logo_url_id: data2['url_id'],
									update_log: @updateLog.getText(),
									build:contentList['build'].toString(),
									app_ids:JSON.stringify(app_ids)
								}
								sendCookie: true
								success: (data) =>
									console.log data
									# data = JSON.parse(body)
									_version.text(_uploadVersion.text())
									fs.writeJson @uploadBtn.val(),contentList,null
									alert "上传模块成功"
									console.log "upload success"
								error: =>
									alert "error"
							client.uploadModuleAndAct(params)
							util.removeFileDirectory(PathM.join zipPath,zipName)
					else
						util.removeFileDirectory(PathM.join zipPath,zipName)
						console.log "文件不存在#{$(btn2).val()}"
				iconPath = PathM.join @uploadBtn.val(),"..","icon.png"
				#当存在 icon 时 上传Icon后再上传模块信息
				#否则直接上床模块信息
				if !fs.existsSync(iconPath)
					fs.exists(@uploadBtn.val(),configFilePathCallBack)
				else
					fileParams2 =
						formData: {
							up_file: fs.createReadStream(iconPath)
						}
						sendCookie: true
						success: (data) =>
							#给 data2 初始化
							data2 = data
							# console.log data2
							fs.exists(@uploadBtn.val(),configFilePathCallBack)
						error: =>
							# console.log iconPath
							console.log "上传icon失败"
							alert "上传icon失败"
					client.uploadFile(fileParams2,"module","")
			error: =>
				alert "上传文件失败"
		client.uploadFile(fileParams,"module","")

	#	upload_module
	postModuleMessage:(btn,btn2) ->
		zipPath = PathM.join $(btn2).val(),"..",".."
		console.log zipPath
		zipName = PathM.basename(PathM.join $(btn2).val(),"..") + '.zip'
		console.log zipName
		_version = @version
		_uploadVersion = @uploadVersion
		uploadVersion = @uploadVersion.text()
		version = @version.text()
		result = UtilExtend.checkUploadModuleVersion(uploadVersion,version)
		if result["error"]
			alert result["errorMessage"]
			return
		fileParams =
			formData: {
				up_file: fs.createReadStream(PathM.join zipPath,zipName)
			}
			sendCookie: true
			success: (data) =>
				console.log "上传文件成功"
				data2={}
				configFilePathCallBack = (exists) =>
					if exists
						file = new File($(btn2).val())
						file.read(false).then (content) =>
							contentList = JSON.parse(content)
							# 当  配置信息中不存在build字段时，新建字段 初始化为 1
							#否则  +1
							contentList['build'] = parseInt(_version.attr('value'))
							contentList['build'] = contentList['build'] + 1
							console.log contentList['build']
							params =
								form:{
									module_tag: contentList['identifier'],
									module_name: contentList['name'],
									module_desc: contentList['description'],
									version: contentList['version'],
									url_id: data['url_id'],
									logo_url_id: data2['url_id'],
									update_log: @updateLog.getText(),
									build:contentList['build'].toString()
								}
								sendCookie: true
								success: (data) =>
									console.log data
									# data = JSON.parse(body)
									_version.text(_uploadVersion.text())
									fs.writeJson $(btn2).val(),contentList,null
									alert "上传模块成功"
									console.log "upload success"
								error: =>
									alert "error"
							client.postModuleMessage(params)
							util.removeFileDirectory(PathM.join zipPath,zipName)
					else
						util.removeFileDirectory(PathM.join zipPath,zipName)
						console.log "文件不存在#{$(btn2).val()}"
				iconPath = PathM.join $(btn2).val(),"..","icon.png"
				#当存在 icon 时 上传Icon后再上传模块信息
				#否则直接上床模块信息
				if !fs.existsSync(iconPath)
					fs.exists($(btn2).val(),configFilePathCallBack)
				else
					fileParams2 =
						formData: {
							up_file: fs.createReadStream(iconPath)
						}
						sendCookie: true
						success: (data) =>
							#给 data2 初始化
							data2 = data
							# console.log data2
							fs.exists($(btn2).val(),configFilePathCallBack)
						error: =>
							# console.log iconPath
							console.log "上传icon失败"
							alert "上传icon失败"
					client.uploadFile(fileParams2,"module","")
			error: =>
				alert "上传文件失败"
		client.uploadFile(fileParams,"module","")

module.exports =
class PublishModuleView extends ChameleonBox

  options :
    title : desc.publishModule
    subview : new PublishModuleInfoView()
