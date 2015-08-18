pathM = require 'path'
desc = require './../utils/text-description'
fs = require 'fs-extra'
module.exports = UtilExtend =
	#检测是否为变色龙项目
	checkIsBSLProject:(filePath) ->
		if fs.existsSync(filePath)
			stats = fs.statSync(filePath)
			if stats.isFile()
				return false
			else
				config = pathM.join filePath,'appConfig.json'
				if fs.existsSync(config)
					statsConfig = fs.statSync(config)
					if statsConfig.isFile()
						return true
					else
						return false
				else
					return false
		else
			return false

	checkUploadModuleVersion:(uploadVersionString,serviceVersionString) ->
		uploadVersion = uploadVersionString.split('.')
		version = serviceVersionString.split('.')
		object = {}
		error = false
		if parseInt(uploadVersion[0]) < parseInt(version[0])
			error = true
		else if parseInt(uploadVersion[0]) == parseInt(version[0])
			if parseInt(uploadVersion[1]) < parseInt(version[1])
				error = true
				object['errorMessage'] = "上传版本不大于服务器版本"
			else if parseInt(uploadVersion[1]) == parseInt(version[1])
				if parseInt(uploadVersion[2]) <= parseInt(version[2])
					error = true
		if error
			object['error'] = true
			object['errorMessage'] = "上传版本不大于服务器版本"
		else
			object['error'] = false
		return object
