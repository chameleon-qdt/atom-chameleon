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
        config = pathM.join filePath,desc.projectConfigFileName
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
        object['errorMessage'] = "上传版本低于或者等于服务器版本"
      else if parseInt(uploadVersion[1]) == parseInt(version[1])
        if parseInt(uploadVersion[2]) <= parseInt(version[2])
          error = true
    if error
      object['error'] = true
      object['errorMessage'] = "上传版本低于或者等于服务器版本"
    else
      object['error'] = false
    return object

  dateFormat:(formatStr,dateObject) ->
    str = formatStr
    week = ["日","一","二","三","四","五","六"]
    str=str.replace(/yyyy|YYYY/,dateObject.getFullYear())
    str=str.replace(/yy|YY/,if (dateObject.getYear() % 100) > 9 then (dateObject.getYear() % 100).toString() else '0' + (dateObject.getYear() % 100))
    str=str.replace(/MM/,if dateObject.getMonth()>9 then dateObject.getMonth().toString() else '0' + dateObject.getMonth())
    str=str.replace(/M/g,dateObject.getMonth())
    str=str.replace(/w|W/g,week[dateObject.getDay()])
    str=str.replace(/dd|DD/,if dateObject.getDate()>9 then dateObject.getDate().toString() else '0' + dateObject.getDate())
    str=str.replace(/d|D/g,dateObject.getDate())
    str=str.replace(/hh|HH/,if dateObject.getHours()>9 then dateObject.getHours().toString() else '0' + dateObject.getHours())
    str=str.replace(/h|H/g,dateObject.getHours())
    str=str.replace(/mm/,if dateObject.getMinutes()>9 then dateObject.getMinutes().toString() else '0' + dateObject.getMinutes())
    str=str.replace(/m/g,dateObject.getMinutes())
    str=str.replace(/ss|SS/,if dateObject.getSeconds()>9 then dateObject.getSeconds().toString() else '0' + dateObject.getSeconds())
    str=str.replace(/s|S/g,dateObject.getSeconds())
    console.log str
    str

  convertJsonToUrlParams:(dataJson) ->
    if typeof(dataJson) is "object"
      paramArray = []
      convert = (key,value) =>
        str = "#{key}=#{value}"
        paramArray.push(str)
      convert key,value for key,value of dataJson
      paramArray.join("&")
    else
      false
