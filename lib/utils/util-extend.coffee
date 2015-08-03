{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'

module.exports = UtilExtend =
	# 检查模块是否需要上传
	checkModuleNeedUpload: ( moduleIdentifer, moduleVersion, modulePath) ->
		console.log moduleIdentifer, moduleVersion
		modulePath = pathM.join modulePath, moduleIdentifer
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
				# console.log "modulePath"
				# modulePath = pathM.join this.find('select').val(), 'modules', moduleIdentifer
				if fs.existsSync(modulePath)
					Util.fileCompression(modulePath)
					zipPath = modulePath+'.zip'
					if fs.existsSync(zipPath)
						# console.log zipPath
						fileParams =
							async:false
							formData: {
								up_file: fs.createReadStream(zipPath)
							}
							sendCookie: true
							success: (data) =>
								# data = JSON.parse(body)
								# console.log "上传文件成功"
								if fs.existsSync(pathM.join modulePath,'package.json')
									packagePath = pathM.join modulePath,'package.json'
									options =
										encoding: 'utf-8'
									contentList = JSON.parse(fs.readFileSync(packagePath,options))
									# console.log contentList['version'],contentList['identifier']
									params =
										async:false
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
						client.uploadFile(fileParams,"module","")
					else
						alert "打包#{modulePath}失败"
				else
					alert "不存在#{modulePath}"
				# else
				# 	console.log "需要上传#{moduleIdentifer}模块,服务器版本为空，本地版本为#{moduleVersion}"
			error : =>
				console.log "获取模板最新版本 的url 调不通"
		client.getModuleLastVersion(params,moduleIdentifer)
