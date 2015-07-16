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
		printName = (file) ->
			console.log file
			if file.isDirectory()
				path =PathM.join file.getPath(),"package.json"
				file2 = new File(path)
				file2.exists().then (resolve,reject) =>
					if resolve
						file2.read(false).then (content) =>
							contetnList = JSON.parse(content)
							_moduleList.append('<div class="col-md-3"><input value="'+file2.getPath()+'" type="checkbox"><label>'+contetnList['name']+'</label></div>')
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
										cb: (err,httpResponse,body) =>
											if !err and httpResponse.statusCode is 200
												data = JSON.parse(body)
												if data['version'] != ""
													obj['version'] = data['version']
												else
													obj['version'] = "0.0.0"
												item = new ModuleMessageItem(obj)
												item.find('button').attr('disabled',true)
												console.log item.find('button')
												_moduleMessageList.append(item)
												util.fileCompression(PathM.join $(checkbox).attr('value'),'..')
												callbackOper = ->
													# item.find('button').attr("disabled",false)
												$(".#{obj.identifier}").fadeOut(3000,callbackOper)
											else
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

			# if fs.existsSync(project_path)
			# 	projectStats = fs.statSync(project_path)
			# 	if projectStats.isDirectory()
			# 		configFilePath = PathM.join project_path,"appConfig.json"
			# 		#判断  appConfig.json 是否存在
			# 		if fs.existsSync(configFilePath)
			# 			configFileStats = fs.statSync(configFilePath)
			# 			file = new File(configFilePath)
			# 			file.read(false).then (content) =>
			# 				contentList = JSON.parse(content)
			# 				$('#projectIdentifier').attr('value',contentList['identifier'])
			# 			project_path = PathM.join project_path,"modules"
			# 		else
			# 			@parentView.closeView()
			# 			_showView.attr('value','hide')
			# 			alert "请选择变色龙项目"
			# 			return
			# 	else
			# 		@parentView.closeView()
			# 		_showView.attr('value','hide')
			# 		alert "请选择变色龙项目"
			# 		return
			# else
			# 	alert "文件不存在"
			# 	return
			# directory = new Directory(project_path,false)
			# printName = (file) ->
			# 	if file.isDirectory()
			# 		path = PathM.join file.getPath(),"package.json"
			# 		file2 = new File(path)
			# 		moduleFolderCallBack = (exists) ->
			# 			if exists
			# 				moduleConfigCallBack = (exists) ->
			# 					if exists
			# 						file2.read(false).then (content) =>
			# 							contentList = JSON.parse(content)
			# 							_moduleList.append('<div class="col-md-3"><input value="'+file2.getPath()+'" type="checkbox"><label>'+contentList['name']+'</label></div>')
			# 				fs.exists(path,moduleConfigCallBack)
			# 		fs.exists(file.getPath(), moduleFolderCallBack)
			# list = directory.getEntriesSync()
			# _moduleList.empty()
			# printName file for file in list

			#这是一个回调函数 的开始
			console.log "hello"
			callbackDirectory = (exists) =>
				if exists
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
								@parentView.enable = false
								alert "请选择变色龙项目（不存在modules文件）"
								return
							modulesStats = fs.statSync(project_path)
							if modulesStats.isFile()
								@parentView.enable = false
								alert "请选择变色龙项目（不存在modules文件）"
								return
						else
							@parentView.enable = false
							alert "请选择变色龙项目(不存在 appConfig.json)"
							return
					else
						console.log @
						@parentView.enable = false
						alert "请选择变色龙项目"
						return
				else
					@parentView.enable = false
					alert "文件不存在"
					return
				# directory = new Directory(project_path,false)
				# list = directory.getEntriesSync()
				#
				# printName = (file) ->
				# 	if file.isDirectory()
				# 		path = PathM.join file.getPath(),"package.json"
				# 		file2 = new File(path)
				# 		moduleFolderCallBack = (exists) ->
				# 			if exists
				# 			  moduleConfigCallBack = (exists) ->
				# 					if exists
				# 						file2.read(false).then (content) =>
				# 							contentList = JSON.parse(content)
				# 							_moduleList.append('<div class="col-md-3"><input value="'+file2.getPath()+'" type="checkbox"><label>'+contentList['name']+'</label></div>')
				# 				fs.exists(path,moduleConfigCallBack)
				# 		fs.exists(file.getPath(), moduleFolderCallBack)
				# _moduleList.empty()
				# printName file for file in list
				modulesCount = 0
				list = fs.readdirSync(project_path)
				fileLength = 0
				printName = (filePath) ->
					# console.log fileLength
					fileLength = fileLength + 1
					stats = fs.statSync(filePath)
					if stats.isDirectory()
						packageFilePath = PathM.join filePath,"package.json"
						if fs.existsSync(packageFilePath)
							packageFileStats = fs.statSync(packageFilePath)
							if packageFileStats.isFile()
								getMessage = (err, data) ->
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
			#回调函数 的结束
			fs.exists(project_path,callbackDirectory)

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
			  # body...
		# console.log "success"
		fileParams =
			formData: {
				up_file: fs.createReadStream(PathM.join zipPath,zipName)
			}
			cb: (err,httpResponse,body) =>
				if !err and httpResponse.statusCode is 200
					data = JSON.parse(body)
					alert body
					configFilePathCallBack = (exists) ->
						if exists
							file = new File($(btn2).val())
							file.read(false).then (content) =>
								contentList = JSON.parse(content)
								params =
									form:{
										module_tag: contentList['identifier'],
										module_name: contentList['name'],
										module_desc: contentList['description'],
										version: contentList['version'],
										url_id: data['url_id'],
										update_log: '还没调上传文件的接口',
										create_by: 'chenyuzhe'
									}
									sendCookie: true
									cb: (err,httpResponse,body) =>
										if !err and httpResponse.statusCode  is 200
											console.log body
											data = JSON.parse(body)
											_version.text(_uploadVersion.text())
											alert body
										else
											alert "error"
								client.postModuleMessage(params)
						else
							console.log "文件不存在#{$(btn2).val()}"
					fs.exists($(btn2).val(),configFilePathCallBack)
				else
					alert "上传文件失败"
		client.uploadFile(fileParams,"module","yuzhe@163.com")
		# configFilePathCallBack = (exists) ->
		# 	if exists
		# 		file = new File($(btn2).val())
		# 		file.read(false).then (content) =>
		# 			contentList = JSON.parse(content)
		# 			params =
		# 				form:{
		# 					module_tag: contentList['identifier'],
		# 					module_name: contentList['name'],
		# 					module_desc: contentList['description'],
		# 					version: contentList['version'],
		# 					url_id: 'test',
		# 					update_log: '还没调上传文件的接口',
		# 					create_by: 'chenyuzhe'
		# 				}
		# 				sendCookie: true
		# 				cb: (err,httpResponse,body) =>
		# 					if !err and httpResponse.statusCode  is 200
		# 						console.log body
		# 						data = JSON.parse(body)
		# 						alert 'result_code: ' + data['result_code'] + "   message: "+data['message']
		# 					else
		# 						console.log 'error'
		# 						console.log
		# 			client.postModuleMessage(params)
		# fs.exists($(btn2).val(),configFilePathCallBack)

module.exports =
class PublishModuleView extends ChameleonBox

  options :
    title : desc.publishModule
    subview : new PublishModuleInfoView()
