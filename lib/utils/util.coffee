{BufferedProcess} = require 'atom'
JSZip = require 'jszip'
fs = require 'fs-extra'
zlib = require 'zlib'
pathM = require 'path'
{File,Directory} = require 'atom'
module.exports = Util =

  rumAtomCommand: (command) ->
     atom.views.getView(atom.workspace).dispatchEvent(new CustomEvent(command, bubbles: true, cancelable: true))

  getIndexHtmlCore: ->
    """
    <!DOCTYPE html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <title>Empty Template</title>
      </head>
      <body>
        <h1>Hello World!</h1>
      </body>
    </html>
    """

  formatModuleConfigToStr:(options) ->
    """
    {
      "name": "#{options.moduleName}",
      "identifier": "#{options.moduleId}",
      "main":"#{options.mainEntry}",
      "version": "0.0.1",
      "description": "",
      "dependencies": {},
      "releaseNote": "module #{options.moduleName} init"
    }
    """

  formatAppConfigToStr:(options) ->
    """
    {
      "name": "#{options.appName}",
      "identifier": "#{options.appId}",
      "mainModule":"#{if options.mainModule? then options.mainModule else '' }",
      "version": "0.0.1",
      "description": "",
      "dependencies": {},
      "releaseNote": "app init"
    }
    """

  formatModuleConfigToObj: (options) ->
    name: options.moduleName
    identifier: options.moduleId
    main: options.mainEntry
    version: '0.0.1'
    description: ''
    dependencies: {}
    releaseNote: "module #{options.moduleName} init"

  formatAppConfigToObj:(options) ->
      name: options.appName
      identifier: options.appId
      mainModule: ''
      modules: {}
      version: '0.0.1'
      description: ''
      dependencies: {}
      releaseNote: "app #{options.appName} init"


  # 将传递过来的 str 进行判断是否符合文件命名，如果不符合，将不符合的字符改为"-", 并进行去重
  checkProjectName: (str)->
    regEx = /[\`\~\!\@\#\$\%\^\&\*\(\)\+\=\|\{\}\'\:\;\,\·\\\[\]\<\>\/\?\~\！\@\#\￥\%\…\…\&\*\（\）\—\—\+\|\{\}\【\】\‘\；\：\”\“\’\。\，\、\？]/g
    strcheck = str.replace(/[^\x00-\xff]/g,"-")
    strcheck = strcheck.replace(regEx,"-")
    strcheck = strcheck.replace(/-+/g, '-')
    # # 特殊处理
    # strcheck = '...' if strcheck is '.' or strcheck is '..'
    return strcheck

  getRepo: (appPath,repoUri, cb) ->
    options =
      cwd: appPath
      env: process.env
    command = 'git'
    args = ['clone', repoUri]
    stdout = (output) -> console.log(output)
    exit = (code) -> cb(code, appPath)
    bp = new BufferedProcess({command, args, options, stdout, exit})

  updateRepo: (fileDir, cb) ->
    options =
      cwd: fileDir
      env: process.env
    command = 'git'
    args = ['fetch']
    stdout = (output) =>
      alert(output)
    stderr = (output) =>
      alert(output)
    exit = (code) =>
      if code is 0
        @mergeRepo fileDir, cb
    bp = new BufferedProcess({command, args, options, stdout, stderr, exit})

  mergeRepo: (fileDir, cb) ->
    options =
      cwd: fileDir
      env: process.env
    command = 'git'
    args = ['merge']
    stdout = (output) =>
      cb(output)
    stderr = (output) =>
      cb(output)
    exit = (code) =>
      if code isnt 0
        alert '代码合并失败'
    bp = new BufferedProcess({command, args, options, stdout, stderr, exit})

  isLogin: () ->
    user = @store('chameleon').account
    if typeof user is 'undefined'
      return false
    else
      return true

  writeFile: (file, textContent, cb) ->
    fs.writeFile file, textContent, cb

  writeJson: (file, obj, cb) ->
    fs.writeJson file, obj, cb

  readJson: (file,cb) ->
    fs.readJson file, cb

  readJsonSync: (file) ->
    fs.readJsonSync file, throws: false

  copy: (sourcePath, destinationPath, cb) ->
    fs.copy(sourcePath, destinationPath, cb)

  createDir: (path, cb) ->
    fs.mkdirp(path, cb)

  delete: (path,callback) ->
    fs.remove path, callback

  isFileExist: (path, cb) ->
    if typeof cb is 'function'
      fs.exists path, cb
    else
      fs.existsSync path

  readDir: (path, cb) ->
    fs.readdir path, cb

  store: (namespace, data) ->
    if data
      return localStorage.setItem(namespace, JSON.stringify(data))
    else
     store = localStorage.getItem(namespace)
     return (store && JSON.parse(store)) || []

  removeStore: (namespace) ->
    localStorage.removeItem(namespace)

  fileCompression: (folderPath) ->
    zip = new JSZip()
    zipPath = pathM.join folderPath,'..',pathM.basename(folderPath)+'.zip'
    compressionZip= (node,filePath) ->
      # console.log filePath
      stats = fs.statSync(filePath)
      if stats.isFile()
        fileName = pathM.basename(filePath)
        fileZipPath = pathM.join node,fileName
        zip.file(fileZipPath,fs.readFileSync(filePath))
      else
        folderZipPath = pathM.join node,pathM.basename(filePath)
        zip.folder(folderZipPath)
        fileList = fs.readdirSync(filePath)
        if fileList isnt null and fileList.length isnt 0
          compressionZip folderZipPath,pathM.join filePath,filePathItem for  filePathItem in fileList
    compressionZip ".",folderPath
    content = zip.generate({type:"nodebuffer"})
    writeCallBack = (err) ->
      if err
        throw err
      else
        console.log "compressionZip success"
    fs.writeFile(zipPath,content,null)
