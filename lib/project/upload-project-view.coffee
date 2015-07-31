{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
Settings = require '../settings/settings'
UtilExtend = require './../utils/util-extend'

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
		@selectUploadProject.on 'change',(e) => @onSelectChange(e)

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
				console.log  path
				filePath = pathM.join path,desc.ProjectConfigFileName
				console.log filePath
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
				UtilExtend.checkModuleNeedUpload identifier, version, projectPath for identifier, version of modules
				jsonBody =
					name: jsonContent["name"]
					identifier: jsonContent["identifier"]
					mainModule: jsonContent["mainModule"]
					modules: jsonContent["modules"]
					version: jsonContent["version"]
					describe: jsonContent["description"]
					releaseNote: jsonContent["releaseNote"]
				strBody = JSON.stringify(jsonBody)
				params =
					body: strBody
					sendCookie: true
					success: (data) =>
						alert "创建应用成功"
						@parentView.closeView()
						return
					error: =>
						console.log "error"
						# @parentView.closeView()
				client.uploadApp(params)

module.exports =
	class UploadProjectView extends ChameleonBox
		options :
			title: desc.uploadProjectTitle
			subview: new UploadProjectInfoView()
