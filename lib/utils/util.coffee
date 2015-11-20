{BufferedProcess, File, Directory, Emitter} = require 'atom'
JSZip = require 'jszip'
zlib = require 'zlib'
fs = require 'fs-extra'
pathM = require 'path'
_ = require 'underscore-plus'
dialog = require('remote').require 'dialog'
request = require 'request'
portscanner = require 'portscanner'
http = require 'http'
desc = require './text-description'
nodeStatic = require 'node-static'



module.exports = Util =
  emitter: new Emitter()
  # windowEmitter: new Emmitter()
  handlerList: {}
  fsx: fs

  rumAtomCommand: (command) ->
     atom.views.getView(atom.workspace).dispatchEvent(new CustomEvent(command, bubbles: true, cancelable: true))

  getIndexHtmlCore: (info) ->
    info ?=
      name: 'Module'
    info.name ?= 'Module'
    """
    <!DOCTYPE html>
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black">
        <title>#{info.name}</title>
      </head>
      <body>
        <h1>Hello #{info.name}!</h1>
      </body>
    </html>
    """

  formatModuleConfigToObj: (options) ->
    name: options.moduleName
    identifier: options.moduleId
    # main: options.mainEntry
    version: desc.minVersion
    build: 1
    # description: ''
    dependencies: {}
    plugins: {}
    releaseNote: "module #{options.moduleName} init"
    hidden: false

  formatAppConfigToObj:(options) ->
      name: options.appName
      identifier: options.appId
      mainModule: ''
      modules: {}
      version: desc.minVersion
      build: 1
      description: ''
      dependencies: {}
      releaseNote: "app #{options.appName} init"

  appConfigToModuleConfig: (info) ->
    moduleIdMinLen = 6;
    moduleIdMaxLen = 32;
    testName = info.appId.split('.').slice(-1)[0]
    if testName.length < moduleIdMinLen
      testName = "#{testName}_module"
    else if testName.length > moduleIdMaxLen
      testName = testName.slice(0,32)
    opt =
      moduleName: info.appName
      moduleId: testName
    @formatModuleConfigToObj opt


  createModule: (params,cb) ->
    pages = params.builderConfig
    moduleConfig = params.moduleConfig
    moduleInfo = params.moduleInfo
    modulePath = pathM.join moduleInfo.modulePath,moduleInfo.identifier
    moduleConfigPath = pathM.join modulePath,desc.moduleConfigFileName
    @createDir modulePath, (err) =>
      return cb err if err?
      @writeJson moduleConfigPath, moduleConfig, (err) =>
        return cb err if err?
        console.log 'writeJson Success!'
        if pages.length is 0
          htmlFilePath = pathM.join modulePath,desc.mainEntryFileName
          htmlString = Util.getIndexHtmlCore moduleConfig
          @writeFile htmlFilePath, htmlString, (err) =>
            cb err
        else
          # 生成builder配置
          builderConfigPath = pathM.join modulePath,desc.builderConfigFileName
          builderConfig = _.map pages,(page) ->
            result =
              name: page.name
              components: page.components
            return result
          @writeJson builderConfigPath, builderConfig, (err) =>
            return cb err if err?
            console.log 'writeBuilderJson Success!'
          # 生成页面
          len = pages.length
          currIndex = 0
          getPageInfo = (index) =>
            page = pages[index]
            result =
              html: page.html
              path: pathM.join modulePath,page.name
            return result
          info = getPageInfo currIndex
          writeHtmlFileCB = (err) =>
            return cb err if err?
            if currIndex < len-1
              info = getPageInfo ++currIndex
              @writeFile info.path, info.html, writeHtmlFileCB
            else
              cb()
          @writeFile info.path, info.html, writeHtmlFileCB


  # 将传递过来的 str 进行判断是否符合文件命名，如果不符合，将不符合的字符改为"-", 并进行去重
  checkProjectName: (str)->
    regEx5 = /^([A-Za-z]+\.){2,}[A-Za-z]+\w*$/
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

  startServer: () ->
    a = 0
    file = new nodeStatic.Server pathM.join desc.chameleonHome, 'QDT_Builder'
    @server = http.createServer (req, res) =>
      req.on 'end', () =>
        file.serve req, res
      .resume()
    portscanner.findAPortNotInUse 3000, 3020, '127.0.0.1', (error, port) =>
      a = port
      @server.listen(port);
      @eventEmitter().emit 'server_on', 'http://localhost:' + port
    return @server

  stopServer: (server, cb) ->
    # server.close( ()=>
    #   console.info "http stopped!"
    #   server = null
    #   if typeof cb == "function" then cb()
    # )
    console.log @server
    @server.close()


  isLogin: () ->
    user = @store('chameleon').account_id
    if typeof user is 'undefined'
      if confirm('请先登录')
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

  writeJson: (filePath, obj, cb) ->
    fs.writeJson filePath, obj, cb

  readJson: (filePath,cb) ->
    fs.readJson filePath, cb

  readJsonSync: (filePath) ->
    fs.readJsonSync filePath, throws: false

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
    flag = "root"
    # 递归函数 当遇到文件或者文件夹里面没有文件时结束
    compressionZip= (node,filePath,isroot) =>
      # console.log filePath
      # windows 和 linux 文件路径兼容处理
      stats = fs.statSync(filePath)
      # 1、将 windows 文件路径的 \ 转为 linux 文件路径的 /
      str1=node.replace(/\\/g,"/")
      # console.log str1
      # 2、切割路径
      strs=str1.split("/")
      # console.log strs
      tmp = zip
      if strs[0] is "."
        isroot = true
      # isroot = false
      # 3、以 tmp 保存当前 最外层文件夹
      getLast = (filePath) =>
        tmp = tmp.folder(filePath)
      if strs isnt null and strs.length isnt 0
        getLast fileItem for fileItem in strs
      # 4、保存文件夹或者文件
      if stats.isFile()
        console.log filePath
        fileName = pathM.basename(filePath)
        # fileZipPath = pathM.join node,fileName
        # zip.file(fileZipPath,fs.readFileSync(filePath))
        if isroot
          zip.file(fileName,fs.readFileSync(filePath))
          # console.log "==============>>  strs is null or 0"
        else
          tmp.file(fileName,fs.readFileSync(filePath))
        # console.log pathM.basename(fileName)
      else
        if flag is "root"
          flag = "children"
          folderZipPath = node
        else
          folderZipPath = pathM.join node,pathM.basename(filePath)
          if isroot
            zip.folder(pathM.basename(filePath))
          else
            tmp.folder(pathM.basename(filePath))
        fileList = fs.readdirSync(filePath)
        if fileList isnt null and fileList.length isnt 0
          compressionZip folderZipPath,pathM.join(filePath,filePathItem),false for  filePathItem in fileList
    compressionZip ".",folderPath,true
    # 5、保存 zip
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

  getThatPane: (uri) ->
    panes = atom.workspace.getPanes()[0].items
    thatPane = _.find panes, (pane) =>
      if pane.uri and pane.uri is uri
        return pane
    return thatPane

  getPanes: () ->
    return atom.workspace.getPanes()[0]

  eventEmitter: () ->
    @emitter

  addEventtoList: (origin, handler) ->
    @handlerList[origin] = handler

  windowEventInit: () ->
    # window.addEventListener 'message', (e)=>
    #   console.log @handlerList
    #   @handlerList[e.origin](e)
