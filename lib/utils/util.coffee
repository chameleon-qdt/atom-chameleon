{BufferedProcess} = require 'atom'
JSZip = require 'jszip'
zlib = require 'zlib'
fs = require 'fs-extra'
pathM = require 'path'
_ = require 'underscore-plus'
dialog = require('remote').require 'dialog'
{File,Directory} = require 'atom'
request = require 'request'
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

  formatModuleConfigToObj: (options) ->
    name: options.moduleName
    identifier: options.moduleId
    # main: options.mainEntry
    version: '0.0.1'
    build: 1
    # description: ''
    dependencies: {}
    releaseNote: "module #{options.moduleName} init"
    hidden: false

  formatAppConfigToObj:(options) ->
      name: options.appName
      identifier: options.appId
      mainModule: ''
      modules: {}
      version: '0.0.1'
      build: 1
      description: ''
      dependencies: {}
      releaseNote: "app #{options.appName} init"


  # 将传递过来的 str 进行判断是否符合文件命名，如果不符合，将不符合的字符改为"-", 并进行去重
  checkProjectName: (str)->
    regEx5 = /^([A-Za-z]+\w*\.){2,}[A-Za-z]+\w*$/
    regEx6 = /^.{10,64}$/
    flag5 = regEx5.test str
    flag6 = regEx6.test str
    return flag5 and flag6

  getRepo: (appPath,repoUri, cb) ->
    options =
      cwd: appPath
      env: process.env
    command = 'git'
    args = ['clone', repoUri]
    stdout = (output) -> console.log(output)
    exit = (code) -> cb(code, appPath)
    bp = new BufferedProcess({command, args, options, stdout, exit})

  updateRepo: (fileDir, cb, error) ->
    options =
      cwd: fileDir
      env: process.env
    command = 'git'
    args = ['fetch']
    stdout = (output) =>
      console.log "update-stdout #{output}"
    stderr = (output) =>
      console.log "update-stderr #{output}"
    exit = (code) =>
      if code is 0
        @mergeRepo fileDir, cb
      else
        error()
    bp = new BufferedProcess({command, args, options, stdout, stderr, exit})

  mergeRepo: (fileDir, cb) ->
    options =
      cwd: fileDir
      env: process.env
    command = 'git'
    args = ['merge', 'origin/master']
    stdout = (output) =>
      console.log "merge-stdout #{output}"
    stderr = (output) =>
      console.log "merge-stderr #{output}"
    exit = (code) =>
      if code isnt 0
        alert '代码合并失败'
      else
        cb()
    bp = new BufferedProcess({command, args, options, stdout, stderr, exit})

  isLogin: () ->
    user = @store('chameleon').account_id
    if typeof user is 'undefined'
      alert('请先登录')
      @findCurrModalPanel()?.item.closeView?()
      @rumAtomCommand('chameleon:login')
      return false
    else
      return true

  findCurrModalPanel: ->
    currentModalPanel = _.find atom.workspace.getModalPanels(), (modalPanel) =>
      return modalPanel.visible is true
    currentModalPanel

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

  createFile: (file, data, cb) ->
    fs.outputFile file, data, 'binary', cb

  getFileData: (url, cb) ->
    params =
      url: url
      method: 'GET'
      encoding: 'binary'
    request params, cb

  isFileExist: (path, cb) ->
    if typeof cb is 'function'
      fs.exists path, cb
    else
      fs.existsSync path

  readDir: (path, cb) ->
    fs.readdir path, cb

  openDialog : (options,cb) ->
    dialog.showOpenDialog options, (destPath) ->
      cb destPath

  # openDirectory title: 'Select Path', (path) ->
  #   console.log path openDirectory
  openDirectory : (options,cb) ->

    options : _.extend({
      defaultPath: atom.project.path
      properties: ['openDirectory']
      }, options)

    @openDialog(options,cb)

  openFile : (options,cb) ->

    options = _.extend({
      defaultPath: atom.project.path
      properties: ['openFile']
      }, options)

    @openDialog(options,cb)


  store: (namespace, data) ->
    if data
      return localStorage.setItem(namespace, JSON.stringify(data))
    else
     aa = localStorage.getItem(namespace)
     return (aa && JSON.parse(aa)) || []

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
        # fileZipPath = pathM.join node,fileName
        # zip.file(fileZipPath,fs.readFileSync(filePath))
        zip.folder(node).file(fileName,fs.readFileSync(filePath))
      else
        folderZipPath = pathM.join node,pathM.basename(filePath)
        zip.folder(folderZipPath)
        fileList = fs.readdirSync(filePath)
        if fileList isnt null and fileList.length isnt 0
          compressionZip folderZipPath,pathM.join filePath,filePathItem for  filePathItem in fileList
    compressionZip ".",folderPath
    content = zip.generate({type:"nodebuffer"})
    fs.writeFileSync(zipPath,content)
    console.log "打包完了"

  UnCompressFile: (zipPath, success) ->
    unzipPath = pathM.join zipPath,".."
    cb = (err, data) =>
      if err
        throw err
      object = new JSZip(data)
      # console.log object.files
      readAndwrite = (zipObject) ->
        # console.log zipObject.name
        savePath = pathM.join unzipPath,zipObject.name
        if zipObject.dir
          # console.log zipObject.name + " is dir"
          if fs.existsSync(savePath)
            console.log "文件夹已存在,文件夹中的相同文件将被覆盖"
          else
            fs.mkdirSync(savePath)
        else
          # console.log zipObject.name + " is a file"
          fs.writeFileSync(savePath,zipObject._data.getContent())
      readAndwrite zipObject for fileName , zipObject of object.files
      if typeof success isnt "undefined"
        success()
      # console.log "!"
    fs.readFile(zipPath,cb)
  # 回调函数必须包含三个参数 cb(err,httpResponse,body)
  upload_file: (filePath, type, userAccount, cb) ->
    fileParams =
      formData:{
        up_file: fs.createReadStream(PathM.join zipPath,zipName)
      }
      cb: cb
    # client.uploadFile(fileParams,type,userAccount)

  removeFileDirectory:(filePath) ->
    if !fs.existsSync(filePath)
      console.log "UNEXISTS"
      return "UNEXISTS"
    stats = fs.statSync(filePath)
    if stats.isFile()
      printResult= (err) =>
        if err
          console.log err
        else
          console.log "success"
      fs.unlink(filePath,printResult)
    # else
    #   fs.rmdir(filePath)

  addModule: (appConfigPath, moduleIdentifer, version) ->
    if fs.existsSync(appConfigPath)
      stats = fs.statSync(appConfigPath)
      if stats.isFile()
        options =
          encoding: "UTF-8"
        cb = (err, data) ->
          if err
            throw err
          else
            contentList = JSON.parse(data)
            contentList["modules"][moduleIdentifer] = version
            if contentList['mainModule'] == ""
              contentList['mainModule'] = moduleIdentifer
            fs.writeJson appConfigPath,contentList,null
        fs.readFile(appConfigPath,options,cb)
      else
        console.log "not a file"
    else
      console.log "is not exists"
