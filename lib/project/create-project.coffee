pathM = require 'path'
Util = require '../utils/util'
desc = require '../utils/text-description'
_ = require 'underscore-plus'
CreateProjectView = require './create-project-view'
Builder = require '../QDT-Builder/builder'

$ = CreateProjectView.$
loadingMask = require '../utils/loadingMask'
client = require '../utils/client'
config = require '../../config/config'
fs = require 'fs-extra'

module.exports = CreateProject =
  chameleonBox: null
  modalPanel: null
  repoDir: pathM.join desc.getFrameworkPath(),desc.defaultModuleName
  frameworksDir: desc.getFrameworkPath()
  projectTempDir: desc.getProjectTempPath()
  templateDir: desc.getTemplatePath()
  LoadingMask: loadingMask

  activate: (state) ->

    @chameleonBox = new CreateProjectView()
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, visible: false)
    @chameleonBox.move()

    @chameleonBox.onFinish (options) => @createProject(options)

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    @chameleonBox.openView()
    # unless @modalPanel.isVisible()
    #   console.log 'CreateProject was opened!',@
    #   @modalPanel.show()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  createProject: (options) ->
    # console.log options
    switch options.newType
      when "empty" then @newEmptyProject options
      when "frame" then @newFrameProject options
      when "template" then @newTemplateProject options
      when "syncProject" then @syncProject options
      when "quick" then @openBuilder options

  openBuilder: (options) ->
    info = options.projectInfo
    moduleConfig = Util.appConfigToModuleConfig info
    params =
      projectInfo: info
      builderConfig: [
        {
          name: "index.html",
          components: []
        }
      ]
      moduleConfig: moduleConfig
      moduleInfo:
        identifier: moduleConfig.identifier
        moduleName: moduleConfig.name
        modulePath: pathM.join info.appPath, desc.moduleLocatFileName
    Builder.activate(params)
    @chameleonBox.closeView()


  # 空白应用创建
  newEmptyProject: (options) ->
    LoadingMask = new @LoadingMask()
    info = options.projectInfo
    console.log "应用信息",info
    createSuccess = (err) =>
      if err
        console.error err
        @modalPanel.item.children(".loading-mask").remove()
        alert "应用创建失败#{':权限不足' if err.code is 'EACCES'}"
      else
        copySuccess = (err) =>
          throw err if err
          appConfigPath = pathM.join info.appPath,desc.projectConfigFileName
          appConfig = Util.formatAppConfigToObj(info)
          writeCB = (err) =>
            throw err if err
            atom.workspace.open appConfigPath
            aft = =>
              Util.rumAtomCommand('tree-view:reveal-active-file')
            _.debounce(aft,300)

          moduleConfig = Util.appConfigToModuleConfig info
          moduleFolderPath = pathM.join info.appPath, desc.moduleLocatFileName
          modulePath = pathM.join moduleFolderPath, moduleConfig.identifier
          indexFilePath = pathM.join modulePath, desc.mainEntryFileName
          moduleConfigPath = pathM.join modulePath, desc.moduleConfigFileName

          moduleCB = (err) ->
            return console.error err if err?
          createCallBack = (err) =>
            return console.error err if err?
            Util.writeFile indexFilePath, Util.getIndexHtmlCore(moduleConfig),moduleCB
            Util.writeJson moduleConfigPath, moduleConfig,moduleCB
          Util.createDir modulePath, createCallBack

          appConfig.mainModule = moduleConfig.identifier
          appConfig.modules[moduleConfig.identifier] = moduleConfig.version

          Util.writeJson appConfigPath, appConfig, writeCB
          @modalPanel.item.children(".loading-mask").remove()
          alert desc.createAppSuccess
          atom.project.addPath(info.appPath)
          Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
          @chameleonBox.closeView()


        Util.copy @projectTempDir, info.appPath, copySuccess

    Util.createDir info.appPath, createSuccess
    @modalPanel.item.append(LoadingMask)

  # 带框架应用创建
  newFrameProject: (options) ->
    console.log options
    info = options.projectInfo
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          targetPath = pathM.join info.appPath,'modules',desc.defaultModuleName
          frameworksPath = pathM.join @frameworksDir,desc.defaultModuleName
          Util.copy frameworksPath, targetPath, (err) => # 复制成功后，将框架复制到应用的 modules 下
            throw err if err
            alert '应用创建成功'
            packageJson = pathM.join targetPath,desc.moduleConfigFileName
            appConfigPath = pathM.join info.appPath,desc.projectConfigFileName
            gfp = pathM.join targetPath,'.git'
            delSuccess = (err) ->
              throw err if err
              console.log 'deleted!'
              if fs.existsSync(packageJson)
                stats = fs.statSync(packageJson)
                if stats.isFile()
                  contentJson = JSON.parse(fs.readFileSync(packageJson))
                  if fs.existsSync(appConfigPath)
                    stats = fs.statSync(appConfigPath)
                    if stats.isFile()
                      contentList = JSON.parse(fs.readFileSync(appConfigPath))
                      contentList['modules'][contentJson['name']] = contentJson['version']
                      if contentList['mainModule'] == ""
                        contentList['mainModule'] = contentJson['name']
                      fs.writeJson appConfigPath,contentList,null
            Util.delete gfp,delSuccess

            # appConfigPath = pathM.join info.appPath,desc.projectConfigFileName
            writeCB = (err) =>
              throw err if err
              atom.workspace.open appConfigPath
              aft = =>
                Util.rumAtomCommand('tree-view:reveal-active-file')
                console.log "aft"
              _.debounce(aft,300)
            Util.writeJson appConfigPath, Util.formatAppConfigToObj(info), writeCB

            @modalPanel.item.children(".loading-mask").remove()
            atom.project.addPath(info.appPath)
            Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
            @chameleonBox.closeView()
        Util.copy @projectTempDir, info.appPath, copySuccess # 创建应用根目录成功后 将空白应用的应用内容复制到根目录

    # Util.createDir info.appPath, createSuccess
    # 首先，判断本地是否有框架
    Util.isFileExist pathM.join(@frameworksDir, desc.defaultModuleName), (exists) =>
      if exists
        Util.createDir info.appPath, createSuccess #有，执行第二步：创建应用根目录
      else
        success = (state, appPath) =>
          if state is 0
            Util.createDir info.appPath, createSuccess
          else
            alert '应用创建失败：git clone失败，请检查网络连接'
            @modalPanel.item.children(".loading-mask").remove()

        Util.getRepo(@frameworksDir, config.repoUri, success) #没有，执行 git clone，成功后执行第二步


    LoadingMask = new @LoadingMask()
    @modalPanel.item.append(LoadingMask)

    # atom.notifications.addSuccess("Success: This is a notification");

  # 新建业务模板应用
  newTemplateProject: (options) ->
    info = options.projectInfo
    fileName = if options.tmpType is 'news' then 'butter_newstemp' else ''
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          targetPath = pathM.join info.appPath,'modules', fileName
          Util.copy pathM.join(@templateDir, fileName), targetPath, (err) => # 复制成功后，将框架复制到应用的 modules 下
            throw err if err
            packageJson = pathM.join targetPath,desc.moduleConfigFileName
            gfp = pathM.join targetPath,'.git'
            delSuccess = (err) =>
              throw err if err
              console.log 'deleted!'
              if fs.existsSync(packageJson)
                stats = fs.statSync(packageJson)
                if stats.isFile()
                  contentJson = JSON.parse(fs.readFileSync(packageJson))
                  if fs.existsSync(appConfigPath)
                    stats = fs.statSync(appConfigPath)
                    if stats.isFile()
                      contentList = JSON.parse(fs.readFileSync(appConfigPath))
                      contentList['modules'][contentJson['name']] = contentJson['version']
                      if contentList['mainModule'] == ""
                        contentList['mainModule'] = contentJson['name']
                      fs.writeJson appConfigPath,contentList,null
              alert desc.createAppSuccess
              @chameleonBox.closeView()
            Util.delete gfp,delSuccess

            appConfigPath = pathM.join info.appPath, desc.projectConfigFileName
            writeCB = (err) =>
              throw err if err
              atom.workspace.open appConfigPath
              aft = =>
                Util.rumAtomCommand('tree-view:reveal-active-file')
              _.debounce(aft,300)
            Util.writeJson appConfigPath, Util.formatAppConfigToObj(info), writeCB

            @modalPanel.item.children(".loading-mask").remove()
            atom.project.addPath(info.appPath)
            Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0


        Util.copy @projectTempDir, info.appPath, copySuccess # 创建应用根目录成功后 将空白应用的应用内容复制到根目录

    # 首先，判断本地是否有框架
    console.log pathM.join(@templateDir, fileName)
    Util.isFileExist pathM.join(@templateDir, fileName), (exists) =>
      if exists
        Util.createDir info.appPath, createSuccess #有，执行第二步：创建应用根目录
      else
        success = (state, appPath) =>
          if state is 0
            Util.createDir info.appPath, createSuccess
          else
            alert "#{desc.createAppError}: #{desc.gitCloneError}"
            @modalPanel.item.children(".loading-mask").remove()

        Util.getRepo(@templateDir, config.tempList[0].url, success) #没有，执行 git clone，成功后执行第二步


    LoadingMask = new @LoadingMask()
    @modalPanel.item.append(LoadingMask)

  syncProject: (options) ->
    console.log options.projectInfo
    console.log options.projectDetail
    LoadingMask = new @LoadingMask()
    @modalPanel.item.append(LoadingMask)

    filePath = options.projectInfo.appPath
    urlList = []
    for name, url of options.projectDetail.moduleUrlMap
      urlList.push({name: name, url: url})

    copyDetail = _.omit options.projectDetail, 'moduleUrlMap'
    Util.createDir filePath, (err)=>
      if err
        console.error err
      else
        Util.writeJson pathM.join(filePath, "appConfig.json"), copyDetail , (err)=>
          if err
            console.error err
          else
            if urlList.length > 0
              urlList.forEach (item) =>
                console.log item
                fileDir = pathM.join filePath, "modules", item.name, "#{item.name}.zip"
                cb = (err, httpresponse, data) =>
                  console.log httpresponse
                  abc = (datac) =>
                    console.log datac
                    Util.UnCompressFile fileDir, (err)=>
                      if err
                        console.error err
                      else
                        Util.delete fileDir, (err)=>
                          if err
                            console.error err
                          else
                            # alert '同步应用成功'
                            atom.project.addPath filePath
                            atom.workspace.open pathM.join(filePath, 'appConfig.json')
                            Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
                            @modalPanel.item.children(".loading-mask").remove()
                            @chameleonBox.closeView()
                  Util.createFile pathM.join(filePath, "modules", item.name, "#{item.name}.zip"), data, abc
                Util.getFileData item.url, cb
            else
              Util.createDir pathM.join(filePath, "modules"), (err)=>
                if err
                  console.error error
                else
                  # alert '同步应用成功'
                  atom.project.addPath filePath
                  atom.workspace.open pathM.join(filePath, 'appConfig.json')
                  Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
                  @modalPanel.item.children(".loading-mask").remove()
                  @chameleonBox.closeView()
