{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
Settings = require '../settings/settings'

class BuildProjectInfoView extends View
	@content: ->
		@div class: 'build_project_vew', =>
			@div outlet: 'main', =>
				@div class: 'col-xs-12', =>
					@h2 "请选择需要构建的应用平台："
				@div class: 'col-xs-6', =>
					@div class: 'col-xs-12', =>
						@img src: 'atom://chameleon-qdt-atom/images/iphone.png'
					@div class: 'col-xs-12 label_pad', =>
						@input type: 'checkbox', value: 'iOS'
						@label "iOS"
				@div class: 'col-xs-6', =>
					@div class: 'col-xs-12', =>
						@img src: 'atom://chameleon-qdt-atom/images/android.png'
					@div class: 'col-xs-12 label_pad', =>
						@input type: 'checkbox', value: 'Android'
						@label "Android"
			@div outlet: 'selectApp', class:'form-horizontal form_width',=>
				@div class: 'form-group', =>
					@label '选择构建的应用：', class: 'col-sm-3 control-label'
					@div class: 'col-sm-9 ', =>
						@select class: 'form-control', outlet: 'selectProject'
			@div outlet: 'buildMessage',  =>
				@div class: 'form-horizontal', =>
					@div class: 'form-group', =>
						@label "应用信息：", class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@button 'iOS', class: 'btn formBtn', value: 'iOS', outlet: 'iosBtn'
							@button 'Android',class: 'btn formBtn', value: 'Android', outlet: 'androidBtn'
					@div class: 'form-group', =>
						@label '应用标识：' , class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@label outlet:'identifier'
					@div class: 'form-group', =>
						@label "构建平台：", class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@label outlet:'platform'
				@div class: 'form-horizontal', outlet: 'iosForm', =>
					# @div class: 'form-group', =>
					# 	@label '应用logo：' , class: 'col-sm-3 control-label'
					# 	@div class: 'col-sm-9', =>
          #     @subview 'iOSLogo', new TextEditorView(mini: true)
          #     @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openIOS'
					@div class: 'form-group', =>
						@label '应用名称：' , class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@subview 'iosName', new TextEditorView(mini: true)
					@div class: 'form-group', =>
						@label '所选插件：' , class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@label outlet: 'iOSPlugins'
				@div class: 'form-horizontal', outlet: 'androidForm', =>
					# @div class: 'form-group', =>
					# 	@label '应用logo：' , class: 'col-sm-3 control-label'
					# 	@div class: 'col-sm-9', =>
					# 		@subview 'androidLogo', new TextEditorView(mini: true)
					# 		@span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openAndroid'
					@div class: 'form-group', =>
						@label '应用名称：' , class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@subview 'androidName', new TextEditorView(mini: true)
					@div class: 'form-group', =>
						@label '所选插件：' , class: 'col-sm-3 control-label'
						@div class: 'col-sm-9', =>
							@label outlet: 'androidPlugins'
			@div outlet: 'buildingTips', =>
				@div class: 'block', =>
					@div class: "col-sm-12", =>
						@span "xxxssdsasdass" ,outlet: "buildTips"
					@div class: "col-sm-12 text-center", =>
						@progress class: 'inline-block'

	attached: ->
		@settings = Settings
		if !util.isLogin()
			@settings.activate()
			@parentView.enable = false
			alert '请先登录'
		@main.addClass('hide')
		@buildMessage.addClass('hide')
		@selectApp.removeClass('hide')
		@buildingTips.addClass('hide')
		@parentView.nextBtn.attr('disabled',false)
		projectPaths = atom.project.getPaths()
		projectNum = projectPaths.length
		@selectProject.empty()
		if projectNum isnt 0
			@setSelectItem path for path in projectPaths
		optionStr = "<option value='other'>其他</option>"
		@selectProject.append optionStr

	# openIOS : ->
	# 	atom.pickFolder (paths) =>
	# 		if paths?
	# 			console.log paths[0]
	# 			path = PathM.join paths[0]
	# 			console.log  path
	# 			@iOSLogo.setText path
	#
	# openAndroid : ->
	# 	atom.pickFolder (paths) =>
	# 		if paths?
	# 			console.log paths[0]
	# 			path = PathM.join paths[0]
	# 			console.log  path
	# 			@androidLogo.setText path

	setSelectItem:(path) ->
		filePath = pathM.join path,desc.ProjectConfigFileName
		obj = Util.readJsonSync filePath
		if obj
			projectName = pathM.basename path
			optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
			@selectProject.append optionStr

	initialize: ->
		@selectProject.on 'change',(e) => @onSelectChange(e)
		@.find('.formBtn').on 'click', (e) => @formBtnClick(e)
		console.log @.find('input[type=checkbox]')

		# @.find('input[type=checkbox]').on 'click',(e,item) => @onClickCheckbox(e,item)
	formBtnClick: (e) ->
		el = e.currentTarget
		if el.value is 'iOS'
			@platform.html('iOS')
			@iosForm.show()
			@androidForm.hide()
		else
			@platform.html('Android')
			@iosForm.hide()
			@androidForm.show()

	onSelectChange: (e) ->
		el = e.currentTarget
		if el.value is 'other'
			@open()

	open: ->
		atom.pickFolder (paths) =>
			if paths?
				path = pathM.join paths[0]
				console.log  path
				filePath = pathM.join path,desc.ProjectConfigFileName
				console.log filePath
				obj = Util.readJsonSync filePath
				if obj
					projectName = pathM.basename path
					optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
					@selectProject.prepend optionStr
				else
					alert "请选择变色龙项目"
				@selectProject.get(0).selectedIndex = 0

	nextBtnClick: ->
		if @selectApp.is(':visible')
			@selectApp.addClass('hide')
			@main.removeClass('hide')
			@parentView.prevBtn.show()
		else if @main.is(':visible')
			checkboxList = this.find('input[type=checkbox]:checked')
			console.log checkboxList
			if checkboxList.length isnt 0
				console.log 'Build'
				hasIos = false
				configPath = pathM.join this.find('select').val(),desc.ProjectConfigFileName
				options =
					encoding: "UTF-8"
				strContent = fs.readFileSync(configPath,options)
				# fs.closeSync(configPath)
				jsonContent = JSON.parse(strContent)
				@identifier.attr('value',jsonContent['identifier'])
				@identifier.html(jsonContent['identifier'])
				# 获取插件信息
				params =
					sendCookie: true
					success: (data) =>
						console.log data
					error: =>
						console.log "console.error"
				client.getAppPlugins(params, jsonContent['identifier'], 'IOS')
				showBuildMessage = (checkbox) =>
					console.log $(checkbox).attr('value')
					if $(checkbox).attr('value') is 'iOS'
						hasIos = true
				showBuildMessage checkbox for checkbox in checkboxList
				@main.addClass('hide')
				@buildMessage.removeClass('hide')
				console.log @androidBtn
				if hasIos
					@androidForm.hide()
					@iosForm.show()
					@platform.html('iOS')
					@iosBtn.attr( 'disabled', false)
					@androidBtn.attr( 'disabled', false)
					if checkboxList.length is 1
						@androidBtn.attr( 'disabled', true)
				else
					@platform.html('android')
					@androidBtn.attr( 'disabled', false)
					@iosBtn.attr( 'disabled', true)
					@iosForm.hide()
					@androidForm.show()
			else
				alert "请选择构建平台"
				return
		else if @buildMessage.is(':visible')
			# console.log @iosBtn
			# 判断 input 框是否有存在空的
			if !@iosBtn.attr('disabled')
				# console.log @iOSLogo
				# if @iOSLogo.getText() is ""
				# 	alert "iOS 的应用 logo 不能为空"
				# 	return
				if @iosName.getText() is ""
					alert 'iOS 的应用 名字 不能为空'
					return
			if !@androidBtn.attr('disabled')
				# console.log @androidLogo
				# if @androidLogo.getText() is ""
				# 	alert "android 的应用 logo 不能为空"
				# 	return
				if @androidName.getText() is ""
					alert 'android 的应用 名字 不能为空'
					return
				console.log fs.readFileSync(@androidLogo.val())
			@buildingTips.removeClass('hide')
			@buildMessage.addClass('hide')
			@parentView.nextBtn.text('完成')
			@parentView.nextBtn.attr('disabled',true)
			# 开始构建
			# 1、检查本地模块信息在服务器是否已经存在
			# 	如果存在则不需上传模块；
			# 	如果不存在则需要上床模块。
			# 2、上传完模块后需要上传应用信息
			configPath = pathM.join this.find('select').val(),desc.ProjectConfigFileName
			options =
				encoding: "UTF-8"
			strContent = fs.readFileSync(configPath,options)
			jsonContent = JSON.parse(strContent)
			modules = jsonContent['modules']
			@buildTips.html("正在检测模块信息......")
			@checkModuleNeedUpload identifier, version for identifier, version of modules
			@buildTips.html("正在上传应用信息......")
			console.log "finish check module upload"
			# 上传应用信息
			@parentView.nextBtn.attr('disabled',false)

	checkModuleNeedUpload: ( moduleIdentifer, moduleVersion) ->
		console.log moduleIdentifer, moduleVersion
		params =
			sendCookie: true
			success: (data) =>
				console.log "check version success"
				if data['version'] != ""
					uploadVersion = moduleVersion.split('.')
					version = data['version'].split('.')
					# 判断是否需要上传模块
					if uploadVersion[0] < version[0]
						console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
						return
					else if uploadVersion[0] == version[0]
						if uploadVersion[1] < version[1]
							console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
							return
						else if uploadVersion[1] == version[1]
							if uploadVersion[2] <= version[2]
								console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
								return
					# 上传模块
					# 1、压缩模块
					# 2、上传
					modulePath = pathM.join this.find('select').val(), 'modules', moduleIdentifer
					if fs.existsSync(modulePath)
						Util.fileCompression(modulePath)
						zipPath = modulePath+'.zip'
						if fs.existsSync(zipPath)
							console.log zipPath
							fileParams =
								formData: {
									up_file: fs.createReadStream(zipPath)
								}
								sendCookie: true
								success: (data) =>
									# data = JSON.parse(body)
									console.log "上传文件成功"
									if fs.existsSync(pathM.join modulePath,'package.json')
										packagePath = pathM.join modulePath,'package.json'
										options =
											encoding: 'utf-8'
										contentList = JSON.parse(fs.readFileSync(packagePath,options))
										console.log contentList['version'],contentList['identifier']
										params =
											form:{
												module_tag: contentList['identifier'],
												module_name: contentList['name'],
												module_desc: contentList['description'],
												version: contentList['version'],
												url_id: data['url_id'],
												update_log: "构建应用时发现本地版本高于服务器版本，所以上传 #{contentList['identifier']} 模块"
											}
											sendCookie: true
											success: (data) =>
												# console.log data
												# alert "上传模块成功"
												console.log "upload success"
											error: =>
											  alert "error"
										client.postModuleMessage(params)
									else
										console.log "文件不存在#{pathM.join modulePath,'package.json'}"
								error: =>
									alert "上传文件失败"
							client.uploadFile(fileParams,"module","yuzhe@163.com")
						else
							alert "打包#{modulePath}失败"
					else
						alert "不存在#{modulePath}"
				else
					console.log "需要上传#{moduleIdentifer}模块,服务器版本为空，本地版本为#{moduleVersion}"
			error : =>
				console.log "获取模板最新版本 的url 调不通"
		client.getModuleLastVersion(params,moduleIdentifer)

	prevBtnClick: ->
		if @main.is(':visible')
			@main.addClass('hide')
			@selectApp.removeClass('hide')
			@parentView.prevBtn.hide()
		else if @buildMessage.is(':visible')
			@buildMessage.addClass('hide')
			@main.removeClass('hide')

module.exports =
	class BuildProjectView extends ChameleonBox
		options :
			title: desc.buildProjectMainTitle
			subview: new BuildProjectInfoView()
