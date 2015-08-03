{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
Settings = require '../settings/settings'
# UtilExtend = require './../utils/util-extend'

class UploadProjectInfoView extends View
	@content: ->
		@div class: "upload_project_view", =>
			@div outlet: "select_upload_project", class:'form-horizontal form_width', =>
					@div class: 'form-group', =>
						@label '选择构建的应用：', class: 'col-sm-3 control-label'
						@div class: 'col-sm-9 ', =>
							@select class: 'form-control', outlet: 'selectUploadProject'
					@div class: 'form-group', =>
						@label '应用名', class: 'col-sm-3 control-label'
						@div class: 'col-sm-9 ', =>
							@label outlet: "name"
					@div class: 'form-group', =>
						@label '应用标识', class: 'col-sm-3 control-label'
						@div class: 'col-sm-9 ', =>
							@label outlet: "identifier"
					@div class: 'form-group', =>
						@label '应用关联模块', class: 'col-sm-3 control-label'
						@div class: 'col-sm-9 ', =>
							@label outlet: "moduleList"
					# @div class: "image", =>
					# 	@img src: "http://qr.liantu.com/api.php?text=http://baidu.com"

	attached: ->
		@settings = Settings
		if !Util.isLogin()
			@settings.activate()
			@parentView.enable = false
			alert '请先登录'
			return
		@parentView.nextBtn.attr('disabled',false)
		projectPaths = atom.project.getPaths()
		projectNum = projectPaths.length
		@selectUploadProject.empty()
		@selectUploadProject.on 'change',(e) => @onSelectChange(e)
		if projectNum isnt 0
			@setSelectItem path for path in projectPaths
		optionStr = "<option value='other'>其他</option>"
		@selectUploadProject.append optionStr
		if @selectUploadProject.val() isnt 'other'
			@showProjectMessage(@selectUploadProject.val())

	setSelectItem:(path) ->
		filePath = pathM.join path,desc.ProjectConfigFileName
		obj = Util.readJsonSync filePath
		if obj
			projectName = pathM.basename path
			optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
			@selectUploadProject.append optionStr

	initialize: ->
		# @selectUploadProject.on 'change',(e) => @onSelectChange(e)

	onSelectChange: (e) ->
		el = e.currentTarget
		if el.value is 'other'
			@open()
		else
		  @showProjectMessage(@selectUploadProject.val())

	open: ->
		atom.pickFolder (paths) =>
			if paths?
				path = pathM.join paths[0]
				# console.log  path
				filePath = pathM.join path,desc.ProjectConfigFileName
				# console.log filePath
				obj = Util.readJsonSync filePath
				if obj
					projectName = pathM.basename path
					optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
					@selectUploadProject.prepend optionStr
				else
					alert "请选择变色龙项目"
				@selectUploadProject.get(0).selectedIndex = 0
				@showProjectMessage(@selectUploadProject.val())

	showProjectMessage:(configPath) ->
		path = pathM.join configPath,desc.ProjectConfigFileName
		if fs.existsSync(path)
			stats = fs.statSync(path)
			if stats.isFile()
				contentList = JSON.parse(fs.readFileSync(path))
				@name.html(contentList['name'])
				@identifier.html(contentList['identifier'])
				@moduleList.html(JSON.stringify(contentList['modules']))

	checkModuleNeedUpload: (modulePath, modules, index) ->
		if modules.length == 0
			# console.log "length = 0"
			return
		else
			moduleIdentifer = modules[index]['identifier']
			moduleVersion = modules[index]['version']
			moduleRealPath = pathM.join modulePath, moduleIdentifer
			params =
				sendCookie: true
				success: (data) =>
					# console.log "check version success"
					if data['version'] != ""
						uploadVersion = moduleVersion.split('.')
						version = data['version'].split('.')
						# 判断是否需要上传模块
						if uploadVersion[0] < version[0]
							console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
							if modules.length == index+1
								@sendBuildMessage()
							else
								@checkModuleNeedUpload(modulePath, modules, index+1)
							return
						else if uploadVersion[0] == version[0]
							if uploadVersion[1] < version[1]
								console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
								if modules.length == index+1
									@sendBuildMessage()
								else
									@checkModuleNeedUpload(modulePath, modules, index+1)
								return
							else if uploadVersion[1] == version[1]
								if uploadVersion[2] <= version[2]
									console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
									if modules.length == index+1
										@sendBuildMessage()
									else
										@checkModuleNeedUpload(modulePath, modules, index+1)
									return
					if fs.existsSync(moduleRealPath)
						Util.fileCompression(moduleRealPath)
						zipPath = moduleRealPath+'.zip'
						if fs.existsSync(zipPath)
							# console.log zipPath
							fileParams =
								formData: {
									up_file: fs.createReadStream(zipPath)
								}
								sendCookie: true
								success: (data) =>
									if fs.existsSync(pathM.join moduleRealPath,'package.json')
										packagePath = pathM.join moduleRealPath,'package.json'
										options =
											encoding: 'utf-8'
										contentList = JSON.parse(fs.readFileSync(packagePath,options))
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
												if modules.length == index+1
													@sendBuildMessage()
												else
													@checkModuleNeedUpload(modulePath, modules, index+1)
											error: =>
											  alert "上传#{modulePath}失败"
										client.postModuleMessage(params)
									else
										console.log "文件不存在#{pathM.join modulePath,'package.json'}"
								error: =>
									alert "上传文件失败"
							client.uploadFile(fileParams,"module","")
						else
							alert "打包#{moduleRealPath}失败"
					else
						alert "不存在#{moduleRealPath}"
					# else
					# 	console.log "需要上传#{moduleIdentifer}模块,服务器版本为空，本地版本为#{moduleVersion}"
				error : =>
					console.log "获取模板最新版本 的url 调不通"
			client.getModuleLastVersion(params,moduleIdentifer)
		# console.log

	sendBuildMessage: ->
		path = pathM.join @selectUploadProject.val(),desc.ProjectConfigFileName
		if fs.existsSync(path)
			stats = fs.statSync(path)
			if stats.isFile()
				options =
					encoding: "UTF-8"
				strContent = fs.readFileSync(path,options)
				jsonContent = JSON.parse(strContent)
				jsonBody =
					name: jsonContent["name"]
					identifier: jsonContent["identifier"]
					mainModule: jsonContent["mainModule"]
					modules: jsonContent["modules"]
					version: jsonContent["version"]
					describe: jsonContent["description"]
					releaseNote: jsonContent["releaseNote"]
				strBody = JSON.stringify(jsonBody)
				# console.log strBody
				params =
					body: strBody
					sendCookie: true
					success: (data) =>
						alert "创建应用成功"
						@parentView.closeView()
						return
					error: =>
						console.error  "sendBuildMessage error"
						# @parentView.closeView()
				client.uploadApp(params)

	nextBtnClick: ->
		# 检查是否需要上传信息
		path = pathM.join @selectUploadProject.val(),desc.ProjectConfigFileName
		if fs.existsSync(path)
			stats = fs.statSync(path)
			if stats.isFile()
				options =
					encoding: "UTF-8"
				strContent = fs.readFileSync(path,options)
				jsonContent = JSON.parse(strContent)
				modules = jsonContent['modules']
				projectPath = pathM.join this.find('select').val(), 'modules'
				moduleList = []
				getModuleMessage = (identifier,version) =>
					module =
						identifier: identifier
						version: version
					moduleList.push module
				# UtilExtend.checkModuleNeedUpload identifier, version, projectPath for identifier, version of modules
				getModuleMessage identifier,version for identifier, version of modules
				@checkModuleNeedUpload projectPath, moduleList, 0
				# path = pathM.join @selectUploadProject.val(),desc.ProjectConfigFileName
				# if fs.existsSync(path)
				# 	stats = fs.statSync(path)
				# 	if stats.isFile()
				# 		options =
				# 			encoding: "UTF-8"
				# 		strContent = fs.readFileSync(path,options)
				# 		jsonContent = JSON.parse(strContent)
				# 		jsonBody =
				# 			name: jsonContent["name"]
				# 			identifier: jsonContent["identifier"]
				# 			mainModule: jsonContent["mainModule"]
				# 			modules: jsonContent["modules"]
				# 			version: jsonContent["version"]
				# 			describe: jsonContent["description"]
				# 			releaseNote: jsonContent["releaseNote"]
				# 		strBody = JSON.stringify(jsonBody)
				# 		params =
				# 			body: strBody
				# 			sendCookie: true
				# 			success: (data) =>
				# 				alert "创建应用成功"
				# 				@parentView.closeView()
				# 				return
				# 			error: =>
				# 				console.log "error"
				# 				# @parentView.closeView()
				# 		client.uploadApp(params)


module.exports =
	class UploadProjectView extends ChameleonBox
		options :
			title: desc.uploadProjectTitle
			subview: new UploadProjectInfoView()
