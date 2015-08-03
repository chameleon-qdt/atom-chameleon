pathM = require 'path'
Util = require '../utils/util'
desc = require '../utils/text-description'
_ = require 'underscore-plus'
CreateProjectView = require './create-project-view'
$ = CreateProjectView.$
loadingMask = require '../utils/loadingMask'
client = require '../utils/client'
config = require '../../config/config'

module.exports = CreateProject =
  chameleonBox: null
  modalPanel: null
  repoDir: pathM.join desc.chameleonHome,'src','frameworks','butterfly-slim'
  frameworksDir: pathM.join desc.chameleonHome,'src','frameworks'
  projectTempDir: pathM.join desc.chameleonHome,'src','ProjectTemp'
  templateDir: pathM.join desc.chameleonHome,'src','templates'
  repoURI: 'https://git.oschina.net/chameleon/butterfly-slim.git'
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
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!',@
      @modalPanel.show()

  closeView: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()

  createProject: (options) ->
    console.log options
    switch options.newType
      when "empty" then @newEmptyProject options
      when "frame" then @newFrameProject options
      when "template" then @newTemplateProject options
      when "syncProject" then @syncProject options

  # 空白项目创建
  newEmptyProject: (options) ->
    info = options.projectInfo
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          appConfigPath = pathM.join info.appPath,desc.ProjectConfigFileName
          writeCB = (err) =>
            throw err if err
            atom.workspace.open appConfigPath
            aft = =>
              Util.rumAtomCommand('tree-view:reveal-active-file')
            _.debounce(aft,300)
          Util.writeJson appConfigPath, Util.formatAppConfigToObj(info), writeCB
          @modalPanel.item.children(".loading-mask").remove()
          # alert '项目创建成功'
          atom.project.addPath(info.appPath)
          Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
          @closeView()


        Util.copy @projectTempDir, info.appPath, copySuccess

    Util.createDir info.appPath, createSuccess
    LoadingMask = new @LoadingMask()
    @modalPanel.item.append(LoadingMask)

  # 带框架项目创建
  newFrameProject: (options) ->
    info = options.projectInfo
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          targetPath = pathM.join info.appPath,'modules','butterfly-slim'
          Util.copy @repoDir, targetPath, (err) => # 复制成功后，将框架复制到项目的 modules 下
            throw err if err
            alert '项目创建成功'
            gfp = pathM.join targetPath,'.git'
            delSuccess = (err) ->
              throw err if err
              console.log 'deleted!'
            Util.delete gfp,delSuccess

            appConfigPath = pathM.join info.appPath,desc.ProjectConfigFileName
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
            @closeView()


        Util.copy @projectTempDir, info.appPath, copySuccess # 创建项目根目录成功后 将空白项目的项目内容复制到根目录

    # 首先，判断本地是否有框架
    Util.isFileExist pathM.join(@frameworksDir, 'butterfly-slim'), (exists) =>
      if exists
        Util.createDir info.appPath, createSuccess #有，执行第二步：创建项目根目录
      else
        success = (state, appPath) =>
          if state is 0
            Util.createDir info.appPath, createSuccess
          else
            alert '项目创建失败：git clone失败，请检查网络连接'
            @modalPanel.item.children(".loading-mask").remove()

        Util.getRepo(@frameworksDir, config.repoUri, success) #没有，执行 git clone，成功后执行第二步


    LoadingMask = new @LoadingMask()
    @modalPanel.item.append(LoadingMask)

    # atom.notifications.addSuccess("Success: This is a notification");

  newTemplateProject: (options) ->
    info = options.projectInfo
    createSuccess = (err) =>
      if err
        console.error err
      else
        copySuccess = (err) =>
          throw err if err
          targetPath = pathM.join info.appPath,'modules', options.tmpType
          Util.copy pathM.join(@templateDir, options.tmpType), targetPath, (err) => # 复制成功后，将框架复制到项目的 modules 下
            throw err if err
            alert '项目创建成功'
            gfp = pathM.join targetPath,'.git'
            delSuccess = (err) ->
              throw err if err
              console.log 'deleted!'
            Util.delete gfp,delSuccess

            appConfigPath = pathM.join info.appPath, desc.ProjectConfigFileName
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
            @closeView()


        Util.copy @projectTempDir, info.appPath, copySuccess # 创建项目根目录成功后 将空白项目的项目内容复制到根目录

    # 首先，判断本地是否有框架
    Util.isFileExist pathM.join(@templateDir, options.tmpType), (exists) =>
      if exists
        Util.createDir info.appPath, createSuccess #有，执行第二步：创建项目根目录
      else
        success = (state, appPath) =>
          if state is 0
            Util.createDir info.appPath, createSuccess
          else
            alert '项目创建失败：git clone失败，请检查网络连接'
            @modalPanel.item.children(".loading-mask").remove()

        Util.getRepo(@templateDir, config.repoUri, success) #没有，执行 git clone，成功后执行第二步


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
                fileDir = pathM.join filePath, "modules", "#{item.name}.zip"
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
                            # alert '同步项目成功'
                            atom.project.addPath filePath
                            atom.workspace.open pathM.join(filePath, 'appConfig.json')
                            Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
                            @modalPanel.item.children(".loading-mask").remove()
                            @closeView()
                  Util.createFile pathM.join(filePath, "modules", "#{item.name}.zip"), data, abc
                Util.getFileData item.url, cb
            else
              Util.createDir pathM.join(filePath, "modules"), (err)=>
                if err
                  console.error error
                else  
                  # alert '同步项目成功'
                  atom.project.addPath filePath
                  atom.workspace.open pathM.join(filePath, 'appConfig.json')
                  Util.rumAtomCommand 'tree-view:toggle' if $('.tree-view-resizer').length is 0
                  @modalPanel.item.children(".loading-mask").remove()
                  @closeView()
