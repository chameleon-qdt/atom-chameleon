desc = require '../utils/text-description'
util = require '../utils/util'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'
UtilExtend = require './../utils/util-extend'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'

class PublishModuleInfoView extends View

  @content:() ->
    @div class : "upload-module", =>
      @div outlet : 'first' , =>
        @h2 desc.publishModulePageOneTitle, class: 'box-subtitle'
        @div outlet : 'moduleList',class: 'box-form'
        # @input type:'text',value:"#{flag}",outlet:'flag'
      @div outlet : 'second',class : 'hide', style: 'overflow-x: scroll', =>
        @label desc.publishModulePageTwoTitle
        @div class: 'modules-container', outlet : 'moduleMessageList', =>


        @input type:"hidden",id:"projectIdentifier"
      @div outlet : 'third', class : 'hide', =>
        @div class: 'new-project', =>
          @div class: 'box-form', =>
            @div class: 'form-row clearfix col-sm-12 padding-none', =>
              @div class:'col-sm-3', =>
                @label '请选择应用路径', class: 'row-title pull-left'
                @div class:'hide', =>
                  @subview 'appPath', new TextEditorView(mini: true)
              @div class:'col-sm-9 textEditStyle',=>
                @label outlet:'show_path',class:'padding-left'
                @span outlet:'openFolder', class: 'inline-block status-added icon icon-file-directory openFolder'

  open :(e) ->
    console.log "ssss"
    atom.pickFolder (paths) =>
      if paths?
        console.log paths[0]
        path = PathM.join paths[0]
        console.log  path
        @appPath.setText path
        @show_path.html(path)

  prevStep: ->
    @first.removeClass('hide')
    @second.addClass('hide')
    @parentView.prevBtn.addClass('hide')
    @parentView.nextBtn.text('下一步')

  thirdClickNext: ->
    console.log @appPath.getText()
    @initFirst(@appPath.getText())


  initFirst:(appPath) ->
    console.log "init"
    appPath = PathM.join appPath,'modules'
    # directory = new Directory(appPath)
    _moduleList = @moduleList
    length = 0
    _parentView = @parentView
    printName = (filePath) =>
      # console.log filePath
      if filePath is ".gitHolder" || filePath is ".." || filePath is '.'
        return
      if fs.existsSync(filePath)
        stats = fs.statSync(filePath)
        # console.log "exists"
        if stats.isDirectory()
          # console.log "isDirectory"
          path =PathM.join filePath,"package.json"
          # console.log path
          if fs.existsSync(path)
            # console.log "path exists"
            stats = fs.statSync(path)
            if stats.isFile()
              # console.log "is file"
              contetnList = JSON.parse(fs.readFileSync(path))
              # console.log contetnList
              # console.log contetnList['identifier'],contetnList['name']
              if contetnList['identifier']? and contetnList['name']?
                length = length + 1
                # console.log "length ++ "
                _moduleList.append('<div class="col-sm-4"><div class="checkboxFive"><input id="'+path+'" value="'+path+'" type="checkbox" class="hide"><label for="'+path+'"></label></div><label for="'+path+'"class="label-empty">'+contetnList['name']+'</label></div>')
    if fs.existsSync(appPath)
      stats = fs.statSync(appPath)
      if stats.isDirectory()
        list = fs.readdirSync(appPath)
        _moduleList.empty()
        printName PathM.join appPath,file for file in list
        # console.log length
        if length == 0
          _parentView.enable = false
          alert "没有任何模块"
          return
        @third.addClass('hide')
        @first.removeClass('hide')
    else
      alert '不存在路径['+appPath+']'
      @parentView.closeView()
    # console.log 'init finish'
  nextStep: ->
    _parentView = @parentView
    # console.log 'click next button'
    if @third.hasClass('hide')
      console.log 'third is hide'
    else
      @thirdClickNext()
      return
    if @parentView.prevBtn.hasClass('hide')
      if this.find('input[type=checkbox]').is(':checked')
        console.log '选择了模块'
      else
        alert '你还没有选择模块。'
        return
      checkboxList = this.find('input[type=checkbox]')
      _moduleMessageList = @moduleMessageList
      _moduleMessageList.empty()
      # 输出模块选项
      moduleList = []
      modulePathJson = {}
      printModuleMessage = (checkbox) =>
        # if $(checkbox).is(':checked')
        #   moduleFolderCallBack = (exists) =>
        #     if exists
        #       moduleConfigCallBack = (exists) =>
        #         if exists
        #           console.log $(checkbox).attr('value')
        #           contentList = JSON.parse(fs.readFileSync($(checkbox).attr('value')))
        #           obj =
        #             moduleName: contentList['name']
        #             uploadVersion: contentList['version']
        #             identifier: contentList['identifier']
        #             version: contentList['serviceVersion']
        #             modulePath: $(checkbox).attr('value')
        #           console.log contentList['identifier']
        #           if contentList['identifier'] is "undefined" || contentList['identifier'] is ""
        #             console.log contentList['identifier']
        #             alert "模块#{contentList['name']}的identifer不存在！"
        #             @prevStep()
        #             return
        #           if contentList['version'] is "undefined" || contentList['version'] is ""
        #             alert "模块#{contentList['name']}的version不存在！"
        #             @prevStep()
        #             return
        #           params =
        #             sendCookie: true
        #             success: (data) =>
        #               if true
        #                 # console.log "check version success"
        #                 console.log  "获取最新版本和上传次数"+ data
        #                 #获取版本 和 上传次数 ， 并判断和初始化  obj['build'] obj['version']
        #                 if data['build']? and data['build'] != ""
        #                   obj["build"] = parseInt(data['build'])
        #                 else
        #                   obj["build"] = 0
        #
        #                 if data['version']? and data['version'] != ""
        #                   obj['version'] = data['version']
        #                 else
        #                   obj['version'] = "0.0.0"
        #                 item = new ModuleMessageItem(obj)
        #                 # item.find('button').attr('disabled',true)
        #                 # console.log item.find('button')
        #                 _moduleMessageList.append(item)
        #                 # util.fileCompression(PathM.join $(checkbox).attr('value'),'..')
        #                 # callbackOper = ->
        #                 #   item.find('button').attr("disabled",false)
        #                 # $(".#{obj.identifier}").fadeOut(3000,callbackOper)
        #             error : =>
        #               console.log "获取模板最新版本 的url 调不通"
        #           client.getModuleLastVersion(params,obj.identifier)
        #       configFilePath = PathM.join $(checkbox).attr('value')
        #       fs.exists(configFilePath,moduleConfigCallBack)
        #
        #   folderPath = PathM.join $(checkbox).attr('value'),'..'
        #   fs.exists(folderPath,moduleFolderCallBack)
        if $(checkbox).is(':checked')
          identifer =PathM.basename PathM.join $(checkbox).attr('value'),".."
          moduleList.push(identifer)
          modulePathJson[identifer] = $(checkbox).attr('value')
          _moduleMessageList.css({'width': moduleList.length * 240})
      printModuleMessage checkbox for checkbox in checkboxList
      params =
        formData:{
          identifier:JSON.stringify(moduleList)
        }
        sendCookie: true
        success: (data) =>
          console.log data
          errorMessage = "不存在路径"
          errorCode = 0
          html = ""
          showModuleMessage = (object) =>
            configPath = modulePathJson[object.identifier]
            if !fs.existsSync(configPath)
              errorCode = 1
            else
              stats = fs.statSync(configPath)
              if stats.isFile()
                contentList = JSON.parse(fs.readFileSync(configPath))
                # modulePath = PathM.join configPath,".."
                obj =
                  moduleName: contentList['name']
                  uploadVersion: contentList['version']
                  identifier: contentList['identifier']
                  version: contentList['serviceVersion']
                  modulePath: configPath
                # 获取版本 和 上传次数 ， 并判断和初始化  obj['build'] obj['version']
                if object['build']? and object['build'] != ""
                  obj["build"] = parseInt(object['build'])
                else
                  obj["build"] = 0
                if object['version']? and object['version'] != ""
                  obj['version'] = object['version']
                else
                  obj['version'] = "0.0.0"
                item = new ModuleMessageItem(obj)
                _moduleMessageList.append(item)
          showModuleMessage object for object in data

        error : =>
          console.log "获取模板最新版本 的url 调不通"
      client.getModuleLastVersion(params)
      console.log moduleList
      console.log modulePathJson
      @second.removeClass('hide')
      @first.addClass('hide')
      @parentView.prevBtn.removeClass('hide')
      @parentView.nextBtn.text('完成')
    else
      @parentView.closeView()

  attached: ->
    @appPath.setText("")
    @attached2()

  attached2: ->
    $('#tips').fadeOut()
    test = $('.entry.selected span')
    _parentView = @parentView
    _moduleList = @moduleList
    # console.log @flag.val()
    # console.log @parentView.flag
    if @parentView.flag is "select_path"
      # console.log "#{test.length}"
      @first.addClass('hide')
      @third.removeClass('hide')
      if @second.hasClass('hide')
        return
      else
        @second.addClass('hide')
        # @third.addClass('hide')
      return
    else
      project_path = $('.entry.selected span').attr('data-path')
      if @first.hasClass('hide')
        @first.removeClass('hide')
        @third.addClass('hide')
        @second.addClass('hide')
      #这是一个回调函数 的开始
      # console.log "hello"
      projectPaths = atom.project.getPaths()
      isRootNodeIsBSLProject = false
      rootPath = null
      checkContains = (path) =>
        directory = new Directory(path)
        if directory.contains(project_path)
          if UtilExtend.checkIsBSLProject(path)
            isRootNodeIsBSLProject = true
            rootPath = path
      checkContains path for path in projectPaths
      console.log isRootNodeIsBSLProject
      returnMessage = null
      returnStatus = false
      if fs.existsSync(project_path)
        projectStats = fs.statSync(project_path)
        #判断是否目录
        if projectStats.isDirectory()
          configFilePath = PathM.join project_path,"appConfig.json"
          #判断  appConfig.json 是否存在
          if fs.existsSync(configFilePath)
            configFileStats = fs.statSync(configFilePath)
            file = new File(configFilePath)
            file.read(false).then (content) =>
              contentList = JSON.parse(content)
              $('#projectIdentifier').attr('value',contentList['identifier'])
            project_path = PathM.join project_path,"modules"
            if !fs.existsSync(project_path)
              # _parentView.enable = false
              returnMessage = "请选择变色龙应用（不存在modules文件）"
              returnStatus = true
            modulesStats = fs.statSync(project_path)
            if modulesStats.isFile()
              # _parentView.enable = false
              returnMessage = "请选择变色龙应用（不存在modules文件）"
              returnStatus = true
          else
            # _parentView.enable = false
            returnMessage = "请选择变色龙应用(不存在 appConfig.json)"
            returnStatus = true
        else
          # _parentView.enable = false
          returnMessage = "请选择变色龙应用"
          returnStatus = true
      else
        _parentView.enable = false
        alert "文件不存在"
        return
      if returnStatus
        if isRootNodeIsBSLProject
          project_path = rootPath
          project_path = PathM.join project_path,"modules"
          if !fs.existsSync(project_path)
            _parentView.enable = false
            alert returnMessage
            return
          modulesStats = fs.statSync(project_path)
          if modulesStats.isFile()
            _parentView.enable = false
            alert returnMessage
            return
        else
          _parentView.enable = false
          alert returnMessage
          return
      modulesCount = 0
      list = fs.readdirSync(project_path)
      fileLength = 0
      printName = (filePath) ->
        console.log fileLength
        stats = fs.statSync(filePath)
        if stats.isDirectory()
          basename = PathM.basename filePath
          packageFilePath = PathM.join filePath,"package.json"
          if fs.existsSync(packageFilePath)
            # alert "#{packageFilePath}"
            packageFileStats = fs.statSync(packageFilePath)
            if packageFileStats.isFile()
              fileLength = fileLength + 1
              getMessage = (err, data) =>
                if err
                  console.log "error"
                else
                  contentList = JSON.parse(data)
                  _moduleList.append('<div class="col-sm-4"><div class="checkboxFive"><input id="module-upload'+basename+'" value="'+packageFilePath+'" type="checkbox" class="hide" /><label for="module-upload'+basename+'"></label></div><label for="module-upload'+basename+'" class="label-empty">'+contentList['name']+'</label></div>')
                  # console.log data
              options =
                encoding: "UTF-8"
              fs.readFile(packageFilePath,options,getMessage)
      _moduleList.empty()
      printName PathM.join project_path,fileName for fileName in list
      if fileLength == 0
        _parentView.enable = false
        alert "没有任何模块"
        return

  getElement: ->
    @element

  serialize: ->

  initialize: ->
    @openFolder.on 'click',(e) => @open(e)

  # attached: ->

class ModuleMessageItem extends View

  @content: (obj) ->
    @div class: 'module_item', =>
      @div class: 'upload-view-padding', =>
        @label '模块名称：'
        @label obj.moduleName
      @div class : 'upload-view-padding', =>
        @label '上传版本：'
        @label obj.uploadVersion,outlet:"uploadVersion"
      @div class : 'upload-view-padding', =>
        @label '服务器版本：'
        @label obj.version,outlet:"version",value:obj.build
      @div class : 'upload-view-padding', =>
        @label '更新日志：'
      @div class : 'upload-view-padding', =>
        @subview 'updateLog', new TextEditorView(mini: true,placeholderText: 'update log...')
      @div class : 'publishModulecheckbox upload-view-padding btngroup', =>
        @button '上传',value:obj.modulePath,outlet:"uploadBtn",class:'btn',click: 'postModuleMessage'
        @button '应用到',value:obj.identifier,class:'btn',click: 'showAppList'
          # @button '上传并应用',value:obj.modulePath,class:'btn'
      # @div class : 'col-sm-12 upload-view-padding',=>
      #   @label "正在打包文件......",class:"#{obj.identifier}"
      @div class : 'hide app-list-view',outlet:"appListView"

  # initialize: ->
  #   # @.find(".editor-contents--private").addClass("TextEditorView-heigth")
  #   console.log "initialize"

  fileChange: (param1,param2) ->
    console.log $(param2).val()
    console.log $(param2)
    @zipPath.setText($(param2).val())

  showAppList:(btn,btn2) ->
    # console.log $(btn2).val()
    @appListView.removeClass('hide')
    params =
      sendCookie: true
      success: (data) =>
        # console.log "success"
        console.log data
        options = ""
        length = 0
        printAppList = (object) =>
          if object is null
            return
          length = length + 1
          if object.name?
            object.name = object.name #+ "(#{object.id})"
          else
            object.name = object.id #+ "(#{object.id})"
          options = options + "<div class='upload-view-padding'><div class='checkboxFive'><input type='checkbox' class='hide' id='#{object.id}_#{length}' value='#{object.id}' /><label for='#{object.id}_#{length}'></label></div><label for='#{object.id}_#{length}' class='label-empty'>#{object.name}</label></div>"
        printAppList object for object in data
        options = options + "<div class='upload-view-padding btngroup'><button name='hideAppListbtn' class='btn'>取消</button><button class='btn' name='uploadMApp'>确认</button><div>"
        if length == 0
          options = "还没与应用关联，请到网页客户端添加关联。<button name='hideAppListbtn' class='btn cancel'>取消</button>"
        # console.log @.find("button[name=uploadMApp]")
        @appListView.html(options)
        @.find("button[name=uploadMApp]").on 'click',(e) => @actModuleToApp(e)
        @.find("button[name=hideAppListbtn]").on 'click',(e) => @hideAppListVIew(e)
      error:() =>
        console.log "error"
    client.getAppListByModule(params,$(btn2).val())
  hideAppListVIew:(e)->
    @appListView.addClass('hide')

  #  upload_module_use_to_application
  actModuleToApp:(e) ->
    # alert "ssss"
    checkboxList = this.find('input[type=checkbox]')
    app_ids = []
    getAppId = (checkbox) =>
      if $(checkbox).is(':checked')
        app_ids.push($(checkbox).val())
    # console.log checkboxList
    getAppId checkbox for checkbox in checkboxList
    zipPath = PathM.join @uploadBtn.val(),"..",".."
    # console.log zipPath
    zipName = PathM.basename(PathM.join @uploadBtn.val(),"..") + '.zip'
    # console.log zipName

    _version = @version
    _uploadVersion = @uploadVersion
    uploadVersion = @uploadVersion.text()
    version = @version.text()
    #校验版本信息
    result = UtilExtend.checkUploadModuleVersion(uploadVersion,version)
    if result["error"]
      alert result["errorMessage"]
      return
    util.fileCompression(PathM.join @uploadBtn.val(),"..")
    fileParams =
      formData: {
        up_file: fs.createReadStream(PathM.join zipPath,zipName)
      }
      sendCookie: true
      success: (data) =>
        console.log "上传文件成功"
        data2={}
        # console.log app_ids
        configFilePathCallBack = (exists) =>
          if exists
            file = new File(@uploadBtn.val())
            file.read(false).then (content) =>
              contentList = JSON.parse(content)
              # 当  配置信息中不存在build字段时，新建字段 初始化为 1
              #否则  +1
              contentList['build'] = parseInt(_version.attr('value'))
              contentList['build'] = contentList['build'] + 1
              params =
                form:{
                  module_tag: contentList['identifier'],
                  module_name: contentList['name'],
                  module_desc: "",
                  version: contentList['version'],
                  url_id: data['url_id'],
                  logo_url_id: data2['url_id'],
                  update_log: @updateLog.getText(),
                  build:contentList['build'].toString(),
                  app_ids:JSON.stringify(app_ids)
                }
                sendCookie: true
                success: (data) =>
                  console.log data
                  # data = JSON.parse(body)
                  _version.text(_uploadVersion.text())
                  fs.writeJson @uploadBtn.val(),contentList,null
                  alert "上传模块成功"
                  console.log "upload success"
                error: =>
                  alert "error"
              client.uploadModuleAndAct(params)
              util.removeFileDirectory(PathM.join zipPath,zipName)
          else
            util.removeFileDirectory(PathM.join zipPath,zipName)
            console.log "文件不存在#{$(btn2).val()}"
        iconPath = PathM.join @uploadBtn.val(),"..","icon.png"
        #当存在 icon 时 上传Icon后再上传模块信息
        #否则直接上床模块信息
        if !fs.existsSync(iconPath)
          fs.exists(@uploadBtn.val(),configFilePathCallBack)
        else
          fileParams2 =
            formData: {
              up_file: fs.createReadStream(iconPath)
            }
            sendCookie: true
            success: (data) =>
              #给 data2 初始化
              data2 = data
              # console.log data2
              fs.exists(@uploadBtn.val(),configFilePathCallBack)
            error: =>
              # console.log iconPath
              console.log "上传icon失败"
              alert "上传icon失败"
          client.uploadFile(fileParams2,"module","")
      error: =>
        alert "上传文件失败"
    client.uploadFile(fileParams,"module","")

  # upload_module
  postModuleMessage:(btn,btn2) ->
    zipPath = PathM.join $(btn2).val(),"..",".."
    console.log zipPath
    zipName = PathM.basename(PathM.join $(btn2).val(),"..") + '.zip'
    console.log zipName
    _version = @version
    _uploadVersion = @uploadVersion
    uploadVersion = @uploadVersion.text()
    version = @version.text()
    result = UtilExtend.checkUploadModuleVersion(uploadVersion,version)
    if result["error"]
      alert result["errorMessage"]
      return
    util.fileCompression(PathM.join $(btn2).val(),"..")
    fileParams =
      formData: {
        up_file: fs.createReadStream(PathM.join zipPath,zipName)
      }
      sendCookie: true
      success: (data) =>
        console.log "上传文件成功"
        data2={}
        configFilePathCallBack = (exists) =>
          if exists
            file = new File($(btn2).val())
            console.log $(btn2).val()
            file.read(false).then (content) =>
              contentList = JSON.parse(content)
              # 当  配置信息中不存在build字段时，新建字段 初始化为 1
              #否则  +1
              contentList['build'] = parseInt(_version.attr('value'))
              contentList['build'] = contentList['build'] + 1
              console.log contentList['build']
              params =
                formData:{
                  module_tag: contentList['identifier'],
                  module_name: contentList['name'],
                  module_desc: "",
                  version: contentList['version'],
                  url_id: data['url_id'],
                  logo_url_id: data2['url_id'],
                  update_log: @updateLog.getText(),
                  build:contentList['build'].toString()
                }
                sendCookie: true
                success: (data) =>
                  console.log data
                  # data = JSON.parse(body)
                  _version.text(_uploadVersion.text())
                  fs.writeJson $(btn2).val(),contentList,null
                  alert "上传模块成功"
                  console.log "upload success"
                error: =>
                  alert "configFilePathCallBack error"
              client.postModuleMessage(params)
              console.log "sdsd"
              util.removeFileDirectory(PathM.join zipPath,zipName)
          else
            util.removeFileDirectory(PathM.join zipPath,zipName)
            console.log "文件不存在#{$(btn2).val()}"
        iconPath = PathM.join $(btn2).val(),"..","icon.png"
        #当存在 icon 时 上传Icon后再上传模块信息
        #否则直接上床模块信息
        if !fs.existsSync(iconPath)
          console.log "exists"
          data2 =
            url_id: ""
          console.log data2["url_id"]
          fs.exists($(btn2).val(),configFilePathCallBack)
        else
          fileParams2 =
            formData: {
              up_file: fs.createReadStream(iconPath)
            }
            sendCookie: true
            success: (data) =>
              #给 data2 初始化
              data2 = data
              console.log data2
              fs.exists($(btn2).val(),configFilePathCallBack)
            error: =>
              # console.log iconPath
              console.log "上传icon失败"
              alert "上传icon失败"
          client.uploadFile(fileParams2,"module","")
      error: =>
        alert "上传文件失败"
    client.uploadFile(fileParams,"module","")

module.exports =
class PublishModuleView extends ChameleonBox
  setOptions:(flag) ->
    # flag = "123"
    @flag = flag
  options :
    title : desc.publishModule
    subview :  new PublishModuleInfoView()
