desc = require '../utils/text-description'
Util = require '../utils/util'
{$,TextEditorView,View} = require 'atom-space-pen-views'
{File,Directory} = require 'atom'
PathM = require 'path'
UtilExtend = require './../utils/util-extend'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
loadingMask = require '../utils/loadingMask'

class PublishModuleInfoView extends View
  moduleConfigFileName: desc.moduleConfigFileName
  projectConfigFileName: desc.projectConfigFileName
  moduleLogoFileName: desc.moduleLogoFileName
  moduleLocatFileName: desc.moduleLocatFileName
  moduleIndexFileName:"index.html"
  moduleDir:"modules"
  moduleConfPath:null
  moduleConfigContent:null
  moduleId:null
  moduleVersionId:null
  currentPage:1
  firstPage:1
  lastPage:5
  countPage:0
  moduleConfigNoExsit:"模块配置文件不存在！"
  uploadModuleErrorTips:"模块上传失败"
  imageTypeTips:"请选择 png 格式的图片。"
  moduleIndexHtmlNoExist:"模块缺失 index.html 文件"
  appSuccessTips:"应用成功"
  platform:'iOS'
  step:1
  pageShowItemNumber:8
  # 1 表示步骤 1。选择模块
  # 2 表示步骤 2.填写信息
  @content:() ->
    @div class : "upload-module", =>
      @div outlet: 'selectAppPathView', class:'form-horizontal form_width',=>
        @label desc.publishModuleFirstStep, class: 'label-width control-label'
        @div class: 'input-width', =>
          @select class: '', outlet: 'selectProject'
      @div outlet: 'fillMessageView',class:'form-horizontal form_width',=>
        @label desc.publishModuleSecondStep, class: 'label-width control-label'
        @div class: 'messageContain', =>
          @div class:"div-align-text", =>
            @img outlet:"logo",class:'pic', src: desc.getImgPath 'icon.png'
            @button desc.changeLogoBtn, outlet:"selectLogo",class:"btn btn-width"
          @div =>
            @div class:"div-display",=>
              @label desc.moduleNameLabel
              @label outlet:"moduleName"
              # @div class:"div-inputText", =>
              #   @subview 'moduleName', new TextEditorView(mini: true)
            @div class:"div-display",=>
              @label desc.moduleUploadVersionLabel
              @div class:"div-inputText", =>
                @subview 'moduleUploadVersion', new TextEditorView(mini: true)
            @div class:"div-display",=>
              @label "更新内容:"
              @div class:"div-inputText", =>
                @subview 'moduleUploadLog', new TextEditorView(mini: true)
      @div outlet: 'uploadProgressView',class: 'form-horizontal form_width',=>
        @div class: "process-label", =>
          @span desc.moduleUploadProcessLabel ,outlet: "buildTips"
        @div class: "text-center", =>
          @progress class: 'inline-block'
      @div outlet: "moduleApplyView",class: 'form-horizontal form_width',=>
        @div outlet:"appListViewShow",=>
          @div class:"text-center", =>
            @img class:"icon_success_img",src: desc.getImgPath 'icon_success.png'
            @span outlet:"getAppListTipsView","模块上传成功，以下应用是否应用模块的最新版本？"
            @span "切换平台："
            @select outlet:"selectPlatform",class:"select-platform", =>
              @option "iOS"
              @option "Android"
            @br
          @div outlet:"messageTipsShow",class:"text-center"
          @div outlet:"tableView", =>
            @div outlet: "appListtable",=>
              @table class:"text-center", =>
                @thead =>
                  @tr =>
                    @td "应用"
                    @td "平台"
                    @td "版本"
                    @td "是否应用"
                @tbody outlet:"appListMessage",id:"appBodyList"
            @div class:"listOfPageView",=>
              @div outlet:"",=>
                @a "上一页",outlet:"prePage",click: "prePageClick"
                @div outlet:"pageIndex",class:"page-list"
                @a "下一页",outlet:"nextPage",click: "nextPageClick"
              @div =>
                @label outlet:"pageTipsView","共70个应用，第1页"
          # @div outlet:"tableView_Android", =>
          #   @div outlet: "appListtable_Android",=>
          #     @table class:"text-center", =>
          #       @thead =>
          #         @tr =>
          #           @td "应用"
          #           @td "平台"
          #           @td "版本"
          #           @td "是否应用"
          #       @tbody outlet:"appListMessage"
          #   @div class:"listOfPageView_Android",=>
          #     @div outlet:"",=>
          #       @a "上一页",outlet:"prePage_Android",click: "prePageClick-Android"
          #       @div outlet:"pageIndex_Android",class:"page list-Android"
          #       @a "下一页",outlet:"nextPage_Android",click: "nextPageClick-Android"
          #     @div =>
          #       @label outlet:"pageTipsView_Android","共70个应用，第1页"
        @div outlet:"noAppListShowView",class:"no_app_list_show_view",=>
          @img class:"icon_success_img",src: desc.getImgPath 'icon_success.png'
          @label "模块上传成功，未检测到与该模块关联的应用。",class:"tips_to_NoApp"

  open :(e) ->
    atom.pickFolder (paths) =>
      if paths?
        # console.log paths[0]
        path = PathM.join paths[0]
        # console.log  path
        @appPath.setText path
        # @show_path.html(path)
  # 上一步
  prevStep: ->
    if @step is 2
      @fillMessageView.hide()
      @selectAppPathView.show()
      @parentView.nextBtn.text("下一步")
      @step = 1
  # 下一步
  nextStep: ->
    if @step is 1
      @initFileMessageView()
    else if @step is 2
      # console.log @moduleUploadVersion.getText()
      #判断模块名字和版本是否为空
      # if @moduleName.getText().trim() == ""
      #   alert desc.moduleNameIsNullError
      if @moduleUploadVersion.getText().trim() == ""
        alert desc.moduleVersionIsNullError
      else
        # 判断模块版本格式是否合法
        if @checkVersionIsLegal(@moduleUploadVersion.getText())
          @uploadModule()
        else
          alert desc.moduleVersionUnLegelError
          return

  #初始化表单  1、判断配置文件是否存在  2、读取本地配置文件信息  3、获取服务器最新版本
  initFileMessageView: ->
    # console.log "selected file path ",@selectProject.val()
    @moduleConfPath = @selectProject.val()
    @moduleConfigContent = null  # 初始化模块配置对象
    if !fs.existsSync(@moduleConfPath)  # 判断模块的配置文件是否存在
      alert @moduleConfigNoExsit
      return
    # 当配置文件存在时，显示下一步
    @step = 2
    @selectAppPathView.hide()
    @fillMessageView.show()
    @parentView.prevBtn.removeClass('hide')
    @parentView.nextBtn.text("上传")
    # 获取配置信息
    @moduleConfigContent = Util.readJsonSync @moduleConfPath
    #模块logo
    logoPath = PathM.join @moduleConfPath,"..",@moduleLogoFileName
    # 模块配置读取成功时
    if @moduleConfigContent
      @moduleName.html(@moduleConfigContent['name'])
      #需要查看版本信息的模块id
      moduleIdentiferList = []
      moduleIdentiferList.push(@moduleConfigContent["identifier"])
      # console.log JSON.stringify(moduleIdentiferList)
      #获取上一版本的版本信息
      params =
        formData:{
          identifier:JSON.stringify(moduleIdentiferList)
        }
        sendCookie: true
        success: (data) =>
          # console.log data
          # 返回的信息中是否包含 version 字段和其值部位 ""
          if data[0]['version'] != ""
            console.log "the last version in server is ",data[0]['version']
          else
            data[0]['version'] = "0.0.0"
          # 返回的信息中是否包含 build 字段和其值部位 ""
          if data[0]['build'] is ""
            data[0]['build'] = 0
          # 设置build的值
          # console.log data[0]['build']
          @moduleConfigContent["build"] = parseInt(data[0]['build']) + 1
          # 判断本地配置文件的版本信息与服务器最新版本那个为最新
          # result = UtilExtend.checkUploadModuleVersion(@moduleConfigContent["version"],data[0]['version'])
          # if result["error"]
          # 服务器新
          versionNumber = data[0]['version'].split(".")
          versionNumber[2] = parseInt(versionNumber[2]) + 1
          @moduleUploadVersion.setText(versionNumber.join("."))
          # 将配置信息的版本设置为服务器最新版本，暂不写入文件中
          @moduleConfigContent["version"] = data[0]['version']
          # console.log result
          if fs.existsSync(logoPath)
            @logo.attr("src",logoPath)
        error:(msg) =>
          console.log msg
      # 获取 该模块最新版本 和 build
      client.getModuleLastVersion(params)
  # 判断版本是否合法，判断规则：是否由三个数和两个点组成
  checkVersionIsLegal:(version)->
    numbers = version.split('.')
    if numbers.length != 3
      return false
    if isNaN(numbers[0]) or isNaN(numbers[1]) or isNaN(numbers[2])
      return false
    if numbers[0].length > 3 or numbers[1].length > 3 or numbers[2].length > 3
      return false
    return true
  # 上传模块包
  callUploadModuleApi:(filePath)->
    if fs.existsSync filePath  # 判断文件是否存在
      # 获取七牛的 token 和 key
      paramsOfGettoken =
        sendCookie: true
        success:(data)=>
          token = data["token"]
          key = data["uuid"]+".zip"
          dataField = {}
          dataField["file"] = fs.createReadStream(filePath)
          dataField["token"] = token
          dataField["key"] = key
          #上传至七牛
          paramTo7niu =
            sendCookie:true
            formData:dataField
            success:(data1) =>
              # console.log data1
              fileId = data1["key"]
              checkData = {}
              checkData["up_classify"] = "module_upload_file"
              checkData["file_id"] = fileId
              # checkData["file_name"] = data["uuid"]
              paramCheckFile =
                sendCookie: true
                formData:checkData
                success:(data2) =>
                  # console.log data2
                  @moduleId = data2["module_id"]
                  @moduleVersionId = data2["module_version_id"]
                  @initAppListView()
                error:(err,body) =>
                  json = JSON.parse( body );
                  alert json["message"]
                  @parentView.closeView()
                  return
              client.checkModuleZipFile(paramCheckFile)
            error :(err) =>
              console.log err
          client.uploadTo7niu(paramTo7niu)
        error : (err) =>
          console.log err
      client.get7niuTokenAndKey(paramsOfGettoken)
    else
      alert "文件#{filePath}不存在"

  #初始化应用列表界面
  initAppListView:->
    @uploadProgressView.hide()
    @appListViewShow.hide()
    @noAppListShowView.hide()
    # @tableView_Android.hide()
    @moduleApplyView.show()
    @selectPlatform.on "change",(e) => @platformChange(e)
    @.find("#appBodyList").on "click",".appBtn",(e) => @appBtnClick(e)
    @.find(".page-list").on "click","a",(e) => @clickNumberToPage(e)
    @callGetAppListApi(1,@platform)

  #
  platformChange:(e) ->
    el = e.currentTarget
    @platform = @selectPlatform.val()
    @currentPage=1
    @firstPage=1
    @lastPage=5
    @countPage=0
    @callGetAppListApi(1,@platform)

  clickNumberToPage:(e) ->
    el = e.currentTarget
    number = parseInt($(el).html())
    # console.log el
      # body...
    @callGetAppListApi(number,@platform)
    #根据 模块标识获取 与他相关联的应用标识
    #获取成功则显示

  #应用列表中  点击下一页
  nextPageClick:(m1,b1) ->
    #根据 模块标识获取 与他相关联的应用标识
    if @currentPage >= @countPage
      return
    # console.log @currentPage+1
    @callGetAppListApi(@currentPage+1,@platform)

  #应用列表中点击上一页
  prePageClick:(m1,b1) ->
    #根据 模块标识获取 与他相关联的应用标识
    if @currentPage <= 1
      return
    @callGetAppListApi(@currentPage-1,@platform)

  #获取应用列表的第 page 页
  callGetAppListApi:(page,platformSelect) ->
    #page   页数
    # console.log platformSelect
    if platformSelect is 'iOS'
      platformSelect = "IOS"
    else
      platformSelect = "ANDROID"
    params =
      sendCookie: true
      success: (data) =>
        # console.log data
        if data.hasOwnProperty("message")
          # console.log data["message"]
          alert data["message"]
        else
          # if data["AppAndVersions"].length > 0
            # @noAppListShowView.hide()
          # console.log data
          if data["paginationMap"]["totalCount"] <= 0
            str = "无 #{@platform} 应用与该模块应用。"
            @messageTipsShow.html(str)
            @tableView.hide()
            @messageTipsShow.show()
            # return
          else
            @messageTipsShow.hide()
            @tableView.show()
          @appListViewShow.show()
          itemStr = []
          # 打印 table 的子节点
          printTableView = (item) =>
            if item["platform"] is "ANDROID"
              item["platform"] = "Android"
            else
              item["platform"] = "iOS"
            str = "<tr>
            <td>#{item["appName"]}</td>
            <td>#{item["platform"]}</td>
            <td>#{item["version"]}</td>
            <td><button class='btn appBtn' id='#{item["appId"]}' value='#{item["appVersionId"]}'>应用</button></td>
            </tr>"
            itemStr.push(str)
          printTableView item for item in data["datas"]
          @appListMessage.html(itemStr.join(""))
          @countPage = data["paginationMap"]["totalPage"]
          @currentPage = page
          @firstPage = @currentPage
          if @countPage - @firstPage >= 4
            @lastPage = @firstPage + 4
          else
            @lastPage = @countPage
            if @lastPage - 4 >0
              @firstPage = @lastPage - 4
            else
              @firstPage = 1
            # body...
          tmp = @firstPage
          aItemStr = []
          #初始化 a 标签
          printPageView = =>
            str = "<a>#{tmp}</a>"
            aItemStr.push(str)
            tmp = tmp + 1
          printPageView() while tmp <= @lastPage
          @pageIndex.html(aItemStr.join(""))
          @pageTipsView.html("共#{data["paginationMap"]["totalCount"]}个应用，第#{page}页")
          # else
            # @appListViewShow.hide()
            # @noAppListShowView.show()
      error: (msg) =>
        console.log msg
    client.getAppListByModule_2 params,@moduleConfigContent["identifier"],page,@pageShowItemNumber,platformSelect

  appBtnClick:(e) ->
    el = e.currentTarget
    @callActInAppApi(el)

  #请求应用到应用
  callActInAppApi:(el)->
    #@moduleIdentifer  模块标识
    #@appVersionId     所要应用到的应用ID
    # @moduleId = "5629a80e0cf26371e4d32066"
    platform = "IOS"
    if @platform is "Android"
      platform = "ANDROID"
    dataParam =
      moduleVersionId: @moduleVersionId
      moduleId: @moduleId
      appVersionId: $(el).attr("value")
      appId: $(el).attr("id")
      platform: platform
    console.log dataParam
    params =
      sendCookie: true
      body:JSON.stringify(dataParam)
      success:(data) =>
        $(el).attr("disabled",true)
        # console.log data
        if data["status"] is "FAIL"
          $(el).attr("disabled",false)
          array = []
          getErrorPlugin = (key,item) =>
            str = "#{key} : #{item.join(",")}"
            array.push(str)
          getErrorPlugin key,item for key,item of data["data"]
          alert "应用失败：模块低版本没有配置以下插件\n"+array.join("\n")
        else
          alert @appSuccessTips
        # alert data["message"]
      error: (msg) =>
        console.log msg
    client.checkModuleAndPluginMessage(params)


  # 0、检测版本；1、压缩文件；2、上传压缩包；3删除压缩包
  uploadModule: ->
    # 版本检测
    result = UtilExtend.checkUploadModuleVersion(@moduleUploadVersion.getText(),@moduleConfigContent['version'])
    if result["error"]
      alert desc.uploadModuleVersionErrorTips
    else
      modulePath = PathM.join @moduleConfPath,".."
      # console.log "the module will be upload ."
      path = PathM.join modulePath,@moduleIndexFileName
      if !fs.existsSync(path)
        alert @moduleIndexHtmlNoExist
        @parentView.closeView()
        return
      @fillMessageView.hide()
      @uploadProgressView.show()
      @parentView.prevBtn.addClass("hide")
      @parentView.nextBtn.addClass('hide')
      @moduleConfigContent['name'] = @moduleName.html()
      @moduleConfigContent['version'] = @moduleUploadVersion.getText()
      @moduleConfigContent['releaseNote'] = @moduleUploadLog.getText()
      fs.writeJsonSync @moduleConfPath,@moduleConfigContent,null
      Util.fileCompression(modulePath)
      moduleZipPath = modulePath+".zip"
      # console.log moduleZipPath
      @callUploadModuleApi(moduleZipPath)
      # 调用模块上传接口  调通就todo 上传成功就跳到应用列表
      # @uploadProgressView.hide()
      # @moduleApplyView.show()

  #初始化窗口
  attached: ->
    # @selectAppPathView.hide()
    @fillMessageView.hide()
    @uploadProgressView.hide()
    @moduleApplyView.hide()
    # @callGetAppListApi(1)
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    @selectProject.empty()
    if projectNum isnt 0
      @setSelectItem path for path in projectPaths
    path = $('.entry.selected span').attr("data-path")
    if typeof(path) is "string"
      filePath = PathM.join path, @moduleConfigFileName
      # console.log filePath
      if fs.existsSync(filePath)
        obj = Util.readJsonSync filePath
        type = desc.uAppModule
        if obj
          if obj['identifier']
            str = "<option value='#{filePath}'>#{obj.identifier} -- #{path}</option>"
        options = @.find("option")
        length = 0
        setDefualt = (item) =>
          m = $(item).attr("value")
          if m is filePath
            return
          length = length + 1
        setDefualt item for item in options
        if length == options.length
          @selectProject.append str
        @selectProject.val(filePath)
    if @selectProject.children().length is 0
      optionStr = "<option value=' '> </option>"
      @selectProject.append optionStr
    optionStr = "<option value='其他'>其他</option>"
    @selectProject.append optionStr

    @selectProject.on 'change',(e) => @onSelectChange(e)
    # console.log @selectLogo
    @selectLogo.on 'click', (e) => @selectIcon(e)

  # 模块Logo选择
  selectIcon:(e) ->
    img_path = PathM.join @selectProject.val(),"..",@moduleLogoFileName
    options={}
    cb = (selectPath) =>
      if selectPath? and selectPath.length != 0
        tmp = selectPath[0].substring(selectPath[0].lastIndexOf('.'))
        # 获取上传至七牛的 token 和 key
        params =
          sendCookie:true
          success:(data) =>
            # console.log data
            token = data["token"]
            key = data["uuid"]+".png"
            dataField = {}
            dataField["file"] = fs.createReadStream(selectPath[0])
            dataField["token"] = token
            dataField["key"] = key
            # 上传至七牛
            paramTo7niu =
              sendCookie: true
              formData: dataField
              success:(data1) =>
                # console.log data1
                fileId = data1["key"]
                # 检验文件类型
                paramCheckFile =
                  sendCookie:true
                  success:(data2) =>
                    # 如果文件是 png 格式 则保存文件至模块位置，否则报提示
                    if data2["file_type"] is "image/png"
                      fs.writeFileSync(img_path,fs.readFileSync(selectPath[0]))
                      @logo.attr("src",selectPath[0])
                    else
                      alert @imageTypeTips
                  error:(msg2) =>
                    console.log msg2
                client.checkFileType(paramCheckFile,fileId)
              error:(msg1) ->
                console.log msg1
            client.uploadTo7niu(paramTo7niu)
          error:(msg) =>
            console.log msg
        client.get7niuTokenAndKey(params)
    Util.openFile options,cb

  #下拉框初始化  读取左边导航栏所有模块
  setSelectItem:(path) ->
    # console.log "setSelectItem",path
    filePath = PathM.join path, @projectConfigFileName
    # console.log filePath
    if fs.existsSync(filePath)
      obj = Util.readJsonSync filePath
      if obj
        # console.log path
        str = ""
        type = desc.appModule
        projectName = PathM.basename path
        modulePath = PathM.join path,@moduleDir
        if !fs.existsSync(modulePath)
          return
        modulePathFiles = fs.readdirSync(modulePath)
        # console.log modulePathFiles
        addItem = (id) =>
          # console.log id,version
          moduleConfigFile = PathM.join path,@moduleLocatFileName,id,@moduleConfigFileName
          if !fs.existsSync(moduleConfigFile)
            return
          obj2 = Util.readJsonSync moduleConfigFile
          modulePath = PathM.join path,@moduleLocatFileName,id
          # console.log moduleConfigFile,obj2
          if obj2
            str = str + "<option value='#{moduleConfigFile}'>#{id} -- #{obj.name} : #{path}</option>"
        # addItem id,version for id,version of obj['modules']
        addItem fileName for fileName in modulePathFiles
        # console.log obj['modules']
        # optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
        # console.log str
        if str != ""
          @selectProject.append str
        return
    else
      # console.log path
      filePath = PathM.join path, @moduleConfigFileName
      # console.log filePath
      if !fs.existsSync(filePath)
        return
      obj = Util.readJsonSync filePath
      type = desc.uAppModule
      if obj
        if obj['identifier']
          str = "<option value='#{filePath}'>#{obj.identifier} -- #{path}</option>"
          @selectProject.append str
      return

  #当选择其他时，弹出文件选择框
  onSelectChange: (e) ->
    el = e.currentTarget
    if el.value == '其他'
      @open()

  #文件夹选择窗
  open: ->
    atom.pickFolder (paths) =>
      if paths?
        path = PathM.join paths[0]
        # console.log "path = ",path
        filePath = PathM.join path,@moduleConfigFileName
        # console.log "filePath = ",filePath
        if !fs.existsSync(filePath)
          @.find("select option:first").prop("selected","selected")
          alert desc.selectModuleErrorTips
          return
        obj = Util.readJsonSync filePath
        type = desc.uAppModule
        if obj
          projectName = PathM.basename path
          optionStr = "<option value='#{filePath}'>#{obj['identifier']} -- #{path}</option>"
          @.find("select option[value=' ']").remove()
          @selectProject.prepend optionStr
        else
          alert desc.selectModuleErrorTips
        @selectProject.get(0).selectedIndex = 0
      else
        @selectProject.get(0).selectedIndex = 0

  getElement: ->
    @element

module.exports =
class PublishModuleView extends ChameleonBox
  setOptions:(flag) ->
    @flag = flag
  options :
    title : desc.publishModule
    subview :  new PublishModuleInfoView()
