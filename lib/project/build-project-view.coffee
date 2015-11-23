{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
UtilExtend = require './../utils/util-extend'
loadingMask = require '../utils/loadingMask'
qrCode = require 'qrcode-npm'

class BuildProjectInfoView extends View
  LoadingMask: loadingMask
  checkBuildResultTimer: {}
  ticketTimer:{}
  buildPlatformId:{}
  moduleConfigFileName: desc.moduleConfigFileName
  projectConfigFileName: desc.projectConfigFileName
  moduleLogoFileName: desc.moduleLogoFileName
  moduleLocatFileName: desc.moduleLocatFileName
  moduleDir:"modules"
  selectProjectTxt:"请选择变色龙项目"
  selectModuleTxt:"请选择主模块"
  versionLegalTips:"版本填写不合法"
  buildIsFail:"构建失败"
  buildIsExist:"构建不存在"
  appConfigNoExistTips:"本地应用配置文件不存在"
  appConfigIsNoCompleteTips:"本地配置文件有缺损"
  pleaseSelectRealProjectTips:"请选择正确的应用"
  noPluginIsExistTips:"存在未上传的插件"
  conflictPluginIsExistTips:"存在冲突的插件未处理"
  passCheckTips:"校验通过"
  unPassCheckTips:"校验不通过"
  projectPath:null #项目的路径
  engineType:"PUBLIC"
  buildPlatform:"iOS"   # 对应构建应用的 platform
  engineVersionList:[]
  imageList:{}          # 对应构建应用的 images
  projectConfigContent:null
  projectLastContent:null
  projectIdFromServer:null  #服务器的最新版本
  logoImage:null        # 对应构建应用的 logoFileId
  moduleList :{}        # 对应构建应用的 moduleList 不过需要转一下格式 []
  pluginList:[]         # 对应构建应用的 pluginList
  mainModuleId:null     # 对应构建应用的 mainModuleId
  pageSize:4
  pageIndex:1
  engineId:null
  pageTotal:1
  noPluginIsExist:false  # 存在所需插件未上传          在获取插件时初始化
  conflictPluginIsExist:true  #存在插件冲突未处理     在获取插件时初始化
  httpType:"http"
  engineMessage:null
  certInfo:null
  buildingId:null
  timerEvent:null
  textEditorViewItems:{}
  pluginFromServer:null
  # buildStep:1 #1、表示上传图片 2、表示调构建接口 3、表示见识构建结果 4、表示显示结果
  step:1 #1、代表第一步选择应用  2、为选择选择平台 3、为选择引擎 4、为选择引擎的版本 5、为引擎基本信息
         #6、应用基本信息，上传各个分辨率的封面图片  7、 选择模块 8、选择插件 9、证书管理 10、构建预览
  #分页都还没做

  @content: ->
    @div class: 'build_project_view', =>
      @div outlet: 'selectProjectView', class:'form-horizontal form_width',=>
        @label '选择构建的应用', class: 'label-width control-label'
        @div class: 'input-width', =>
          @select class: 'projectPath', outlet: 'selectProject'
      @div outlet: 'platformSelectView',class:'form-horizontal form_width', =>
        @div class: 'col-xs-12', =>
          @label "选择需要构建的应用平台",class:"title-2-level"
        @div class: 'col-xs-6 text-center padding-top', =>
          @div class: 'col-xs-12 text-center', =>
            @div class: 'selectBuildTemplate active',value:'iOS', =>
              @img outlet:'iosIcon',src: desc.getImgPath 'icon_apple.png'
            @div class: "",=>
              @label "iOS"
        @div class: 'col-xs-6 text-center padding-top', =>
          @div class: 'col-xs-12 text-center', =>
            @div class: 'selectBuildTemplate',value:'Android', =>
              @img outlet:'androidIcon',src: desc.getImgPath 'icon_android.png'
            @div class: "",=>
              @label "Android"
      @div outlet:"engineTableView",class:'form-horizontal form_width', =>
        @div class: "col-xs-12", =>
          @label "引擎选择（可跳过）",class:"title-2-level"
        @div class: "col-xs-12", =>
          @label "公有引擎", value:"PUBLIC" ,class:"public-view click-platform platformBtn",click:"platformBtnClick"
          @label "私有引擎", value:"PRIVATE",class:"private-view platformBtn",click:"platformBtnClick"
          @div class:"div-table-view", =>
            @table outlet:"enginesView",=>
              @thead =>
                @tr =>
                  @td "标识",class:"th-identify"
                  @td "平台",class:"th-platform"
                  @td "引擎名称",class:"th-engine"
                  @td "描述",class:"th-desc"
                  @td "更新时间",class:"th-update-time"
                  @td "操作"
              @tbody outlet:"engineItemShowView"
            @div outlet:"tipsNoEngins",=>
              @label "没有引擎",class:"tips_to_NoEngine"
          @div class: "",=>
            @button "上一页",class:"btn engineListClass prevPageButton"
            @button "下一页",class:"btn engineListClass nextPageButton"
      @div outlet:"engineVersionView",class:'form-horizontal form_width',=>
        @div =>
          @label "引擎版本选择（可跳过）:"
          @label outlet:"enginName"
        @div  =>
          @table =>
            @thead =>
              @tr =>
                @td "版本",class:"th-engine"
                @td "文件大小",class:"th-engine"
                @td "发布时间",class:"th-desc"
                @td "更新内容",class:"th-desc"
                @td "操作"
            @tbody outlet:"engineVersionItemView"
        @div class: "",=>
          @button "上一页",class:"btn engineVersionListClass prevPageButton"
          @button "下一页",class:"btn engineVersionListClass nextPageButton"

      @div outlet:"engineBasicMessageView",class:"form-horizontal form_width engineBasicMessageView",=>
        @div class: "col-xs-12", =>
          @label "引擎配置"
        @div class:"col-xs-12",=>
          @label "引擎:"
          @label outlet:"engineName"
        @div class:"col-xs-12",=>
          @label "标识:"
          @label outlet:"engineIdView"
        @div class:"col-xs-12",=>
          @div class:"div-engine-basic",=>
            @label "平台:"
            @label outlet:"platform"
          @div class:"div-engine-basic",=>
            @label "引擎大小:"
            @label outlet:"engineSize"
        @div class:"col-xs-12",=>
          @label "构建环境:"
          @label outlet:"buildEnv"
        @div class:"col-xs-12",=>
          @label "版本:"
          @label outlet:"engineVersion"
        @div class:"col-xs-12",=>
          @label "横竖屏支持:"
          @input type:"checkbox" ,value:"scross",class:"showStyle",id:"scross-view"
          @label "横屏",for:"scross-view"
          @input type:"checkbox" ,value:"vertical",class:"showStyle",id:"vertical-view",checked:"checked"
          @label "竖屏",for:"vertical-view"
        @div class:"col-xs-12 iOSSupportView",=>
          @label "硬件支持:"
          @input type:"checkbox" ,value:"iPhone",class:"supportMobileType",id:"iPhone-checkbox",checked:"checked"
          @label "iPhone",for:"iPhone-checkbox"
          @input type:"checkbox" ,value:"iPad",class:"supportMobileType",id:"iPad-checkbox"
          @label "iPad",for:"iPad-checkbox"
      @div outlet:"projectBasicMessageView",class:"form-horizontal form_width",=>
        @div class: "col-xs-12", =>
          @div class:"" ,=>
            @label "APP LOGO", class:"label-logo"
            @img outlet:"logo",class:'pic img-logo', src: desc.getImgPath 'select-logo.png'
          @div =>
            @div =>
              @label
            @div =>
              @div class:"verticalModelView",=>
                @label "竖屏"
                @div outlet:"verticalModelView"
              @div class:"scrossModelView",=>
                @label "横屏"
                @div outlet:"scrossModelView"

      @div outlet:"selectModuleView",class:"form-horizontal form_width", =>
        @div =>
          @label "关联模块",class:"title-2-level"
        @div =>
          @div =>
            @label "主模块:"
            @label outlet:"mainModuleTag"
          @div =>
            @label "已选模块:"
            @label outlet:"modulesTag"
        @div =>
          @table =>
            @thead =>
              @tr =>
                @td "名字",class:"th-desc-1"
                @td "版本",class:"th-desc"
                @td "操作"
            @tbody outlet:"modulesShowView",class:"modulesShowView"
        @div class: "",=>
          @button "上一页",class:"btn moduleListClass prevPageButton"
          @button "下一页",class:"btn moduleListClass nextPageButton"
      @div outlet:"selectPluginView",class:"form-horizontal form_width", =>
        @div outlet:"noPluginView",=>
          @label "没有任何插件",class:"tips_to_NoPlugins"
        @div outlet:"pluginView",class:"pluginView", =>
          @div outlet:"clashPluginView",class:"clashPluginView"
          @div outlet:"noClashPluginView"
      @div outlet:"certSelectView",class:"form-horizontal form_width",=>
        @div =>
          @label "证书管理（可跳过）",class:"title-2-level"
        @div outlet:"androidCertSelectView", =>
          @div class:"", =>
            @label "Android证书",class:"AndroidCertTh"
          @div class:"border-style",=>
            @div class:"col-xs-12",=>
              @label "Keystore别名" ,class:"certInfo-label"
              @input type:"text",class:"label-disable",outlet:"certAlias",disabled:true
            @div class:"col-xs-12", =>
              @label "Android证书文件",class:"certInfo-label"
              @div class: 'inline-view cert_file_input_click certFile', =>
                @subview 'certFile', new TextEditorView(mini: true,placeholderText: 'Click to select Certificate File...')
            @div class:"col-xs-12", =>
              @label "Android证书存储库口令",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'storePassword', new TextEditorView(mini: true,placeholderText: 'The certificate repository password...')
            @div class:"col-xs-12", =>
              @label "Android证书密钥库口令",class:"certInfo-label"
              @div class: 'inline-view', =>
                @subview 'keyPassword', new TextEditorView(mini: true,placeholderText: 'Certificate keystore password...')
            @div class:"col-xs-12 text-right-align",=>
              @button "提交并检验证书",class:"btn androidCertCheck uploadAndCheckCertBtn"
        @div outlet:"iosCertSelectView", =>
          @div =>
            @label "iOS发布证书",class:"iOSPersonCert iOSCertTh "
            @label "iOS企业证书",class:"companyPersonCert iOSCertTh "
          @div outlet:"iOSCertView", =>
            @div class:"border-style", =>
              @div class:"col-xs-12",=>
                @label "App ID",class:"certInfo-label"
                @input type:"text",class:"label-disable",outlet:"appId",disabled:true
              @div class:"col-xs-12",=>
                @label "发布证书",class:"certInfo-label"
                @div class: 'inline-view cert_file_input_click appCert', =>
                  @subview 'appCert', new TextEditorView(mini: true,placeholderText: 'Click to select Certificate File...')
              @div class:"col-xs-12",=>
                @label "证书密码",class:"certInfo-label"
                @div class: 'inline-view', =>
                  @subview 'appPassword', new TextEditorView(mini: true,placeholderText: 'Certificate password...')
              @div class:"col-xs-12",=>
                @label "证书解释文件",class:"certInfo-label"
                @div class: 'inline-view cert_file_input_click descFile', =>
                  @subview 'descFile', new TextEditorView(mini: true,placeholderText: 'Click to select Certificate to explain file...')
              @div class:"col-xs-12 text-right-align",=>
                @button "提交并检验证书",class:"btn iOSCertCheck uploadAndCheckCertBtn"
          @div outlet:"iOSCompanyCertView", =>
            @div class:"border-style", =>
              @div class:"col-xs-12",=>
                @label "App ID",class:"certInfo-label"
                @input type:"text",class:"label-disable",outlet:"companyAppId",disabled:true
              @div class:"col-xs-12",=>
                @label "发布证书",class:"certInfo-label"
                @div class: 'inline-view cert_file_input_click companyAppCert', =>
                  @subview 'companyAppCert', new TextEditorView(mini: true,placeholderText: 'Click to select Certificate File...')
              @div class:"col-xs-12",=>
                @label "证书密码",class:"certInfo-label"
                @div class: 'inline-view', =>
                  @subview 'companyAppPassword', new TextEditorView(mini: true,placeholderText: 'Certificate password...')
              @div class:"col-xs-12",=>
                @label "证书解释文件",class:"certInfo-label"
                @div class: 'inline-view cert_file_input_click companyDescFile', =>
                  @subview 'companyDescFile', new TextEditorView(mini: true,placeholderText: 'Click to select Certificate to explain file...')
              @div class:"col-xs-12 text-right-align",=>
                @button "提交并检验证书",class:"btn iOSCompanyCertCheck uploadAndCheckCertBtn"
      @div outlet:"buildReView",class:"buildReViewClass", =>
        @div =>
          @label "版本号",class:"title-2-level"
        @div =>
          @label "当前版本号："
          @label outlet:"lastAppVersion"
        @div =>
          @label "填写版本号："
          @div class: 'inline-view', =>
            @subview 'versionUpload', new TextEditorView(mini: true,placeholderText: 'upload version...')
        @div =>
          @label "更新内容："
        @div =>
          @div  =>
            @subview "releaseNote", new TextEditorView(placeholderText: 'log description...'),class:"build-log-text"
      @div outlet:"buildAppView", =>
        @div outlet:"uploadImageStepView" ,=>
          @label "正在上传图片..."
          @progress class:'inline-block uploadImagesProgress', max:'100',value:"0", outlet:"imagesUploadProgress"
        @div outlet:"sendBuildRequestView", =>
          @div =>
            @label "正在请求构建,请耐心等待..."
          @div class:"waitToLoad",=>
            @span class:'loading loading-spinner-small inline-block'
        @div outlet:"waitingBuildResultView", =>
          @label outlet:"buildingTips"
          @div class: "col-sm-12 text-center", =>
            @progress class: 'inline-block'
        @div outlet:"buildResultView" , =>
          @div =>
            @label "构建成功"
          @div class:"text-center", =>
            @div class:"urlImageShow",=>
              @img outlet:"imgForDownloadApp"
            @div =>
              @a outlet:"urlForDownloadApp"
        @div outlet:"errorView" , =>
          @label outlet:"buildErrorView"
  # 点击平台图片触发事件  同时初始化  @buildPlatform
  clickIcon:(e) ->
    el = e.currentTarget
    console.log "选择 #{$(el).attr('value')} 平台"
    @buildPlatform = $(el).attr('value')
    @.find(".selectBuildTemplate").removeClass("active")
    $(el).addClass("active")

  # 点击平台按钮事件
  platformBtnClick:(m1,b1) ->
    @engineType = $(b1).attr("value")
    # console.log $(b1).attr("value"),@engineType
    @.find(".platformBtn").removeClass("click-platform")
    $(b1).addClass("click-platform")
    @initEngineTableView()


  # 初始化
  attached: ->
    @platformSelectView.hide()
    @engineTableView.hide()
    @engineVersionView.hide()
    @engineBasicMessageView.hide()
    @projectBasicMessageView.hide()
    @selectModuleView.hide()
    @selectPluginView.hide()
    @certSelectView.hide()
    @buildReView.hide()
    @buildAppView.hide()
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    @selectProject.empty()
    if projectNum isnt 0
      @setSelectItem path for path in projectPaths
    if @selectProject.children().length is 0
      optionStr = "<option value=' '> </option>"
      @selectProject.append optionStr
    path = $('.entry.selected span').attr("data-path")

    filePath = pathM.join path, @projectConfigFileName
    #判断文件是否存在，不存在则跳出
    if fs.existsSync(filePath)
      obj = Util.readJsonSync filePath
      if obj
        projectName = pathM.basename path
        optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
      options = @.find(".projectPath > option")
      length = 0
      console.log options
      setDefualt = (item) =>
        m = $(item).attr("value")
        if m is path
          return
        length = length + 1
      setDefualt item for item in options
      if length == options.length
        @selectProject.append str
      @selectProject.val(path)
    optionStr = "<option value='其他'>其他</option>"
    @selectProject.append optionStr
    @selectProject.on 'change',(e) => @onSelectChange(e)
    @.find('.formBtn').on 'click', (e) => @formBtnClick(e)
    @.find('.selectBuildTemplate').on 'click',(e) => @clickIcon(e)
    # 绑定点击上一页下一页事件
    @.find('.prevPageButton').on 'click',(e) => @prevPageClick(e)
    @.find('.nextPageButton').on 'click',(e) => @nextPageClick(e)
    @.find('.iOSCertTh').on 'click',(e) => @clickIosCert(e)
    @.find(".uploadAndCheckCertBtn").on "click",(e) => @uploadCheckCert(e)
    @.find(".cert_file_input_click").on "click",(e) => @selectCertViewFile(e)

  initParam: ->
    @imageList = {}
    @pluginList = {}
    @moduleList = {}
    @logoImage = null
    @buildPlatform = "iOS"
    @engineType = "PUBLIC"
    @httpType = "http"


  checkModuleNeedToUpload:(path) ->
    modulesPath = pathM.join path,@moduleDir
    # console.log modulesPath
    if fs.existsSync(modulesPath)
      modules = fs.readdirSync(modulesPath)
      identifierList = []
      getModuleIdentifiers = (modulePath) =>
         filePath = pathM.join modulesPath,modulePath,desc.moduleConfigFileName
         if fs.existsSync(filePath)
           identifierList.push(modulePath)
         else
           return
      getModuleIdentifiers modulePath for modulePath in modules
      console.log identifierList
      params =
        formData:{
          identifier:JSON.stringify(identifierList)
        }
        sendCookie: true
        success: (data) =>
          console.log data
          moduleList = []
          getNeedToUploadModuleIdentifier = (item) =>
            if item["build"] is ""
              moduleList.push(item["identifier"])
            # moduleList.push(item["identifier"])
          getNeedToUploadModuleIdentifier item for item in data
          # return moduleList
          str = moduleList.join(",")
          console.log str
          if str is ""
            return
          else
            if confirm "检测到未上传模块： #{str}，是否要先上传模块？"
              @parentView.closeView()
              Util.rumAtomCommand("chameleon:publish-module")
        error:=>
          console.log "call the last version api fail"
      # 获取 该模块最新版本 和 build

      client.getModuleLastVersion(params)
    else
      return false

  # 点击下一步按钮触发事件
  nextBtnClick:() ->
    if @step is 1   #1、代表第一步选择应用，初始化 @projectPath
      #初始化 projectPath 的全局变量，只在这里赋值
      @initParam()
      @projectPath = @selectProject.val()
      if @projectPath is " "
        alert @selectProjectTxt
        return
      @checkModuleNeedToUpload(@projectPath)
      @platformSelectView.show()
      @selectProjectView.hide()
      @parentView.prevBtn.show()
      @parentView.prevBtn.attr('disabled',false)
      @step = 2
    else if @step is 2 #2、为选择选择平台   在点击平台图片的时候 初始化 @buildPlatform
      console.log @step,@buildPlatform
      @certInfo = {}
      @platformSelectView.hide()
      @tipsNoEngins.hide()
      @enginesView.hide()
      @engineTableView.show()
      @initEngineTableView() # 需要用到 @buildPlatform 和 @engineType ，@engineType是在点击 tag 时重新赋值的 将 engineMessage 设置为空
      # @parentView.nextBtn.text("跳过")
      @step = 3
    else if @step is 4 #4、为选择引擎的版本  这个已经没用了
      @engineVersionView.hide()
      @engineBasicMessageView.show()
      @getBasicMessageView()
      # @parentView.nextBtn.text("下一步")
      @step = 5
    else if @step is 3 #3、为选择引擎
      console.log "show engin basic message"
      @engineTableView.hide()
      @engineBasicMessageView.show()
      @getBasicMessageView() #初始化  engineMessage 的值
      # @parentView.nextBtn.text("下一步")
      @step = 5
    else if @step is 5 # 5、为引擎基本信息
      if @.find(".showStyle:checked").length is 0
        alert desc.projectTipsStep5_1
        return
      if @buildPlatform is "iOS"
        if @.find(".supportMobileType:checked").length is 0
          alert desc.projectTipsStep5_2
          return
      @engineBasicMessageView.hide()
      @projectBasicMessageView.show()
      # @parentView.nextBtn.text("跳过")
      @initProjectBasicMessageViewStep5_1()
      @step = 6
    else if @step is 6 # 6、模块选择
      # callBack = =>
      @projectBasicMessageView.hide()
      @selectModuleView.show()
      @pageSize = 4
      @pageIndex = 1
      # @parentView.nextBtn.text("下一步")
      @initModuleList()
      @initSelectModuleView([],@pageIndex,@pageSize)
      @step = 7
      # @uploadFileSync(callBack)
    else if @step is 7 # 7、插件选择
      @noPluginIsExist = false
      if !@mainModuleId
        alert @selectModuleTxt
        return
      @pageSize = 4
      @pageIndex = 1
      @selectModuleView.hide()
      @noPluginView.hide()
      @pluginView.hide()
      @selectPluginView.show()
      @initSelectPluginView([],@pageIndex,@pageSize)
      @step = 8
    else if @step is 8 # 8、
      if @noPluginIsExist
        alert @noPluginIsExistTips
        return
      if @.find(".clashPluginView button").length > 0
        alert @conflictPluginIsExistTips
        return
      @initPluginList()
      @selectPluginView.hide()
      @initCertView()
      @certSelectView.show()
      # @parentView.nextBtn.text("跳过")
      @step = 9
    else if @step is 9
      @certSelectView.hide()
      @buildReView.show()
      if @projectLastContent
        @lastAppVersion.html(@projectLastContent["base"]["version"])
        version = @projectLastContent["base"]["version"].split('.')
        version[2] = parseInt(version[2]) + 1
        @versionUpload.setText(version.join("."))
      else
        @lastAppVersion.html("0.0.0")
        @versionUpload.setText("0.0.1")
      @step = 10
      @parentView.nextBtn.text("生成安装")
    else if @step is 10
      @buildAppMethod()

  initPluginList: ->
    arrayPlugin = @.find(".clashPluginView select")
    console.log @.find(".clashPluginView select")
    arr = []
    initPlugin = (item) =>
      console.log $(item).attr("class")
      pluginId = $(item).attr("name")
      params = {}
      getParamsFromTextView = (key,value) =>
        params[key] = value.getText()
      getParamsFromTextView key,value for key,value of @textEditorViewItems[pluginId]
      obj =
        pluginVersionId: $(item).val()
        pluginId: pluginId
        appVersionId:""
        appId:""
        pluginType:$(item).attr("class")
        params:params
      arr.push(obj)
    initPlugin item for item in arrayPlugin
    @pluginList = arr
    console.log @pluginList


  selectCertViewFile:(e) ->
    el = e.currentTarget
    options = {}
    cb = (selectPath) =>
      if selectPath? and selectPath.length != 0
        tmp = selectPath[0].substring(selectPath[0].lastIndexOf('.'))
        if @buildPlatform is "Android" and tmp is ".keystore"
          @certFile.setText(selectPath[0])
        else
          if $(el).hasClass("appCert")
            @appCert.setText(selectPath[0])
          else if $(el).hasClass("descFile")
            @descFile.setText(selectPath[0])
          else if $(el).hasClass("companyAppCert")
            @companyAppCert.setText(selectPath[0])
          else
            @companyDescFile.setText(selectPath[0])
    Util.openFile options,cb

  #检验证书
  uploadCheckCert:(e) ->
    console.log "click check"
    el = e.currentTarget
    if @buildPlatform is "Android"
      params =
        sendCookie:true
        formData: {
          up_file: fs.createReadStream(@certFile.getText())
        }
        success:(data) =>
          console.log data
          obj =
            keystoreFileId:data["url_id"]
            keypass:@keyPassword.getText()
            storepass:@storePassword.getText()
          params1 =
            sendCookie:true
            formData:obj
            success:(data2) =>
              console.log data2
              @parentView.nextBtn.text("下一步")
              @certAlias.val(data2["alias"])
              @certInfo["certAlias"] = data2["alias"]
              @certInfo["certFileId"] = data["url_id"]
              @certInfo["storePassword"] = obj["storepass"]
              @certInfo["keyPassword"] = obj["keypass"]
              alert @passCheckTips
            error:(msg) =>
              console.log msg
              alert @unPassCheckTips
          client.check_cert_android(params1)
        error:(msg) =>
          console.log msg
      client.uploadFileSync(params,"qdt_app",true)
    else
      appCert = null          #iOS应用证书
      descFile = null         #证书解释文件
      appPassword = null      #证书密码
      if $(el).hasClass("iOSCompanyCertCheck")
        console.log "iOSCompanyCertCheck"
        appCert = @companyAppCert.getText()
        descFile = @companyDescFile.getText()
        appPassword = @companyAppPassword.getText()
      else
        appCert = @appCert.getText()
        descFile = @descFile.getText()
        appPassword = @appPassword.getText()
      console.log "开始上传证书 iOS 证书"
      #上传 iOS 证书
      params =
        sendCookie:true
        formData:{
          up_file: fs.createReadStream(appCert)
        }
        success:(data) =>
          console.log data
          console.log "开始上传证书 上传证书解释文件"
          # 上传证书解释文件
          params1 =
            sendCookie:true
            formData:{
              up_file:fs.createReadStream(descFile)
            }
            success:(data1) =>
              obj =
                keypass:appPassword
                certFileId:data["url_id"]
                mobileprovisionFileId:data1["url_id"]
              params2 =
                sendCookie:true
                formData:obj
                success:(data2) =>
                  @parentView.nextBtn.text("下一步")
                  console.log data2
                  if $(el).hasClass("iOSCompanyCertCheck")
                    @companyAppId.val(data2["bundleIdentify"])
                    @certInfo["companyAppId"] = data2["bundleIdentify"]
                    @certInfo["companyAppCert"] = data["url_id"]
                    @certInfo["companyAppPassword"] = @companyAppPassword.getText()
                    @certInfo["companyDescFileId"] = data1["url_id"]
                  else
                    @appId.val(data2["bundleIdentify"])
                    @certInfo["appId"] = data2["bundleIdentify"]
                    @certInfo["appCert"] = data["url_id"]
                    @certInfo["appPassword"] = @appPassword.getText()
                    @certInfo["descFileId"] = data1["url_id"]
                  alert @passCheckTips
                error:(msg) =>
                  console.log msg
                  alert @unPassCheckTips
              client.check_cert_iOS(params2)
            error:(msg) =>
              console.log msg
          client.uploadFileSync(params1,"qdt_app",true)
        error:(msg) =>
          console.log
      client.uploadFileSync(params,"qdt_app",true)

  #初始化证书选择
  initCertView:() ->
    if @buildPlatform is "iOS"
      @androidCertSelectView.hide()
      @iOSCompanyCertView.hide()
      @iosCertSelectView.show()
      @.find(".companyPersonCert").addClass("click-cert-label")
    else
      @iosCertSelectView.hide()
      @androidCertSelectView.show()

  #IOS 切换个人证书与企业证书
  clickIosCert:(e) ->
    el = e.currentTarget
    if $(el).hasClass("click-cert-label")
      @.find('.iOSCertTh').addClass("click-cert-label")
      $(el).removeClass("click-cert-label")
    if $(el).hasClass("companyPersonCert")
      @iOSCompanyCertView.show()
      @iOSCertView.hide()
    else
      @iOSCompanyCertView.hide()
      @iOSCertView.show()

  #上传logo的图片
  uploadFileSync:(callBack) ->
    @buildReView.hide()
    @uploadImageStepView.show()
    @sendBuildRequestView.hide()
    @waitingBuildResultView.hide()
    @buildResultView.hide()
    @buildAppView.show()
    if fs.existsSync(@logoImage)
      params =
        formData: {
          up_file: fs.createReadStream(@logoImage)
        }
        sendCookie:true
        success:(data) =>
          @logoImage = data["url_id"]
          keyArray = []
          getKeyList = (key,path) =>
            keyArray.push(key)
          getKeyList key,path for key,path of @imageList
          @uploadImageFileListSync(keyArray,0,callBack)
        error:(msg) =>
          console.log msg
      client.uploadFileSync(params,"qdt_app",true)
    else
      keyArray = []
      getKeyList = (key,path) =>
        keyArray.push(key)
      getKeyList key,path for key,path of @imageList
      @uploadImageFileListSync(keyArray,0,callBack)

  # 同步上传文件
  uploadImageFileListSync:(keyArray,index,callBack)->
    length = keyArray.length
    if length > index
      key = keyArray[index]
      path = @imageList["#{key}"]
      if fs.existsSync(path)
        params =
          formData: {
            up_file: fs.createReadStream(path)
          }
          sendCookie:true
          success:(data) =>
            @imageList["#{key}"] = data["url_id"]
            @uploadImageFileListSync(keyArray,index+1,callBack)
          error:(msg) =>
            console.log msg
        client.uploadFileSync(params,"qdt_app",true)
      else
        @uploadImageFileListSync(keyArray,index+1,callBack)
      @imagesUploadProgress.attr("value",(index+1)*100/length)
    else
      callBack()

  buildAppMethod:() ->
    #判断输入的版本合法
    uplaoadVersion = @versionUpload.getText()
    if @checkVersionIsLegal(@versionUpload.getText())
      if @projectLastContent
        object = UtilExtend.checkUploadModuleVersion(uplaoadVersion,@projectLastContent["base"]["version"])
        if object["error"]
          alert object["errorMessage"]
          return
    else
      alert @versionLegalTips
      return
    @parentView.prevBtn.hide()
    @parentView.nextBtn.hide()
    callBack = =>
      @uploadImageStepView.hide()
      @sendBuildRequestView.show()
      platform = "IOS"
      if @buildPlatform is "Android"
        platform = "ANDROID"
      data = {}
      data["certInfo"] = @certInfo
      data["platform"] = platform
      data["appId"] = @projectIdFromServer
      data["identifier"] = @projectConfigContent["identifier"]
      data["logoFileId"] = @logoImage
      data["classify"] = "appdisplay" #可不填
      data["status"] = "OFFLINE" #
      data["appName"] = @projectConfigContent["name"]
      data["version"] = uplaoadVersion
      data["createTime"] = UtilExtend.dateFormat("YYYY-MM-DD HH:mm:ss",new Date()) #当前时间
      data["images"] = @imageList #文件id
      data["releaseNote"] = @releaseNote.getText()
      modules = []
      formatModuleList = (key,item) =>
        tmp =
          "moduleVersionId":item["moduleVersionId"]
          "moduleId": item["moduleId"]
          "appVersionId":""
          "appId":""
        modules.push(tmp)
      formatModuleList key,item for key,item of @moduleList
      plugins = []
      # formatPlugineList = (key,item) =>
      #   tmp =
      #     "pluginVersionId":item["pluginVersionId"]
      #     "pluginId": item["pluginId"]
      #     "appVersionId":""
      #     "appId":""
      #   plugins.push(tmp)
      # formatPluginList key,item for key,item of @pluginList
      data["moduleList"] = modules
      data["pluginList"] = @pluginList
      data["mainModuleId"] = @mainModuleId
      data["engineId"] = @engineMessage["engineId"]
      data["engineVersionId"] = @engineMessage["id"]
      console.log data
      params =
        sendCookie:true
        body: JSON.stringify(data)
        success:(data) =>
          console.log "requestBuildApp data = #{data}"
          @buildingId = data["buildId"]
          #监听构建结果
          @sendBuildRequestView.hide()
          @waitingBuildResultView.show()
          @checkBuildStatusByBuildId(@buildingId)
        error:(msg) =>
          console.log msg
      client.requestBuildApp(params)
    @uploadFileSync(callBack)

  # 判断版本是否合法，判断规则：是否由三个数和两个点组成
  checkVersionIsLegal:(version)->
    numbers = version.split('.')
    if numbers.length != 3
      return false
    if isNaN(numbers[0]) or isNaN(numbers[1]) or isNaN(numbers[2])
      return false
    return true

  # 根据构建  ID  来查看构建结果
  checkBuildStatusByBuildId:(buildingId)->
    params =
      sendCookie:true
      success:(data) =>
        console.log data
        waitTime = 0
        if data["code"] == -1
          alert @buildIsExist
          return
        if data["status"] == "WAITING"
          waitTime = data["waitingTime"]
          if waitTime == 0
            @buildingTips.html("准备开始构建...")
          else
            @buildingTips.html("还需等待构建<span class='waitTime'>#{waitTime}</span>秒")
          loopTime = 25 # 调服务器时间 的时间间隔
          if waitTime < loopTime
            loopTime = waitTime
            if waitTime == 0
              loopTime = loopTime + 2
        else if data["status"] == "BUILDING"
          waitTime = data['remainTime']
          number = @.find(".waitTime").html()
          console.log number,typeof(number)
          if typeof(number) is "undefined"
            @buildingTips.html("正在构建，已完成<span class='waitTime'>0</span>%")
          loopTime = 25
          if waitTime < loopTime
            loopTime = waitTime
        else if data["status"] == "SUCCESS"
          @waitingBuildResultView.hide()
          @buildResultView.show()
          qr1 = qrCode.qrcode(8, 'L')
          qr1.addData(data['url'])
          qr1.make()
          img1 = qr1.createImgTag(4)
          @imgForDownloadApp.attr("src",$(img1).attr('src'))
          @urlForDownloadApp.attr('href',data['url'])
          @urlForDownloadApp.html("app下载地址")
          window.clearTimeout(@timerEvent)
        else
          alert @buildIsFail
          @parentView.closeView()
          return
        @timerEvent = setTimeout =>
          @timerMethod buildingId,loopTime
        ,2000
      error:(msg) =>
        console.log msg
    client.getBuildUrl(params,buildingId)

  # 定时任务
  timerMethod: (buildingId,loopTime) ->
    # console.log @timerEvent
    if loopTime <= 0
      @checkBuildStatusByBuildId(buildingId)
    else
      number = parseInt(@.find(".waitTime").html())
      if number < 99
        number = number+1
      # console.log number
      @.find(".waitTime").html(number)
      loopTime = loopTime - 1
      @timerEvent = setTimeout =>
        @timerMethod buildingId,loopTime
      ,2000

  # 初始化插件
  # array 需要过滤掉的插件数据
  initSelectPluginView:(array,pageIndex,pageSize) ->
    # console.log "begin to initSelectPluginView"
    platform = "ANDROID"
    if @buildPlatform is "iOS"
      platform = "IOS"
    exceptModuleArray = array
    moduleIds = []
    getModuleIds = (item,value) =>
      console.log value
      moduleIds.push(value["moduleVersionId"])
    getModuleIds item,value for item,value of @moduleList
    console.log moduleIds,@moduleList,@projectIdFromServer
    dataJson =
      "module_version_ids":moduleIds.join(",")
      "platform": platform
      "app_id": @projectIdFromServer
    dataStr = UtilExtend.convertJsonToUrlParams(dataJson)
    if !dataStr
      dataStr = null
    LoadingMask = new @LoadingMask()
    params =
      sendCookie:true
      success:(data) =>
        # console.log data
        if data.length > 0
          @pluginView.show()
          @initPluginViewTableBody(data)
        else
          @noPluginView.show()
          console.log "没有任何插件"
        $(LoadingMask).remove()
      error:(msg) =>
        console.log "initSelectPluginView api error = #{msg}"
        $(LoadingMask).remove()
    @.append(LoadingMask)
    client.getPluginByModuleIds(params,dataStr)

  # 初始化插件信息
  initPluginViewTableBody:(data) ->
    noPluginList = []
    conflictList = []
    normalList = []
    console.log data
    classifyItems = (item) =>
      if item["type"] is "zero"
        noPluginList.push(item)
      else if item["type"] is "many"
        conflictList.push(item)
      else
        normalList.push(item)
    classifyItems item for item in data
    if noPluginList.length > 0
      @noPluginIsExist = true
    @pluginFromServer = data
    noPluginListHtmlStr = @noPluginListToHtml(noPluginList)
    @clashPluginView.html(noPluginListHtmlStr)
    conflictListHtmlStr = @conflictListToHtml(conflictList)
    @clashPluginView.append(conflictListHtmlStr)
    normalListHtmlStr = @normalListToHtml(normalList)#conflictList  normalList
    clickConflictBtn = (e) =>
      el = e.currentTarget
      pluginIndex = parseInt($(el).attr("value"))
      itemIndex = parseInt($(el).parent().attr("value"))
      console.log $(el).parent("div")
      @initPluginItemView(conflictList[itemIndex],pluginIndex,"many",el)
    @.find(".conflictBtn").on "click",(e) => clickConflictBtn(e)
    @.find(".clashPluginView").on "change","select",(e) => @changePluginVersionEvent(e)

  changePluginVersionEvent:(e) ->
    console.log "changePluginVersionEvent"
    el = e.currentTarget
    authority = $(el).attr("class")
    pluginDocId = $(el).attr("name")
    identifier = $(el).attr("text")
    id = $(el).val()
    console.log authority,pluginDocId,identifier
    pluginList = []
    console.log @pluginFromServer
    getPluginList = (item) =>
      if item["identifier"] is identifier
        if item["type"] is "many"
          if item["plugin"][0][0]["pluginDocId"] is pluginDocId and item["plugin"][0][0]["authority"] is authority
            pluginList = item["plugin"][0]
          else
            pluginList = item["plugin"][1]
        else
          pluginList = item["plugin"]
    getPluginList item for item in @pluginFromServer
    console.log pluginList
    plugin = {}
    getPlugin = (itemPlugin) =>
      if itemPlugin["id"] is id
        plugin = itemPlugin
        console.log itemPlugin
    getPlugin itemPlugin for itemPlugin in pluginList
    @reShowPluginParamsView(plugin,el)


  reShowPluginParamsView:(plugin,el) ->
    tmpEl = $(el).parent().parent().find(".paramsView")
    tmpEl.html("")
    paramObj = {}
    console.log plugin
    getParams = (item) =>
      obj =
        display:item["display"]
      paramView = new ParamsItem(obj)
      tmpEl.append(paramView)
      paramView.display.setText(item["value"])
      paramObj[item["key"]] = paramView.display
    getParams item for item in plugin["params"]
    @textEditorViewItems["#{plugin["pluginDocId"]}"] = paramObj

  # 对象数组   noPluginList
  noPluginListToHtml:(noPluginList) ->
    console.log noPluginList
    identifierList = []
    printIdentifierList = (item) =>
      identifierList.push(item["identifier"])
    printIdentifierList item for item in noPluginList
    if identifierList.length > 0
      """
        <div class="plugin-view-div">
          <label style="color: red;">插件#{identifierList.join(",")}不存在，请先上传这些插件。</label>
        </div>
        <br>
      """
    else
      ""

  # 对象数组   noPluginList
  conflictListToHtml:(conflictList) ->
    console.log conflictList
    conflictMessageShow = []
    itemLength = 0
    printPluginItem = (item) =>
      pluginMessage = []
      length = 0
      printPluginMessage = (pluginItem) =>
        if pluginItem[0]["authority"] is "PUBLIC"
          authority = "共有"
        else
          authority = "私有"
        str = """
          <li value="#{itemLength}">#{authority}-#{pluginItem[0]["pluginDocId"]} <button class="btn conflictBtn" value="#{length}">选择插件</button></li>
        """
        pluginMessage.push(str)
        length = length + 1
      printPluginMessage pluginItem for pluginItem in item["plugin"]
      itemLength = itemLength + 1
      str = """
      <div>
      #{item["identifier"]}
      <div class="plugin-view-div">
      #{pluginMessage.join("")}
      </div>
      </div>
      <br>
      """
      conflictMessageShow.push(str)
    printPluginItem item for item in conflictList
    conflictMessageShow.join("")

  # item 为调用获取插件时最外层数组的一个元素
  initPluginItemView:(item,index,type,el) ->
    # 模块信息变量   moduleMessage
    moduleMessage = []
    # 将要打印输出的 模块插件对应关系压入 moduleMessage
    printModuleMessage = (moduleItem) =>
      str = """
        <li> <label class="label-select-view">#{moduleItem["moduleName"]} </label>: #{moduleItem["pluginVersion"]} </li>
      """
      moduleMessage.push(str)
    printModuleMessage moduleItem for moduleItem in item["module"]
    # 获取插件版本选项
    selectArray = []
    arrayItem = null
    console.log item
    if type is "many"
      arrayItem = item["plugin"][index]
    else
      arrayItem = item["plugin"]
    printSelectOptionItem = (selectItem) =>
      str = """
        <option value="#{selectItem["id"]}" >#{selectItem["version"]}</option>
      """
      selectArray.push(str)
    printSelectOptionItem selectItem for selectItem in arrayItem
    console.log selectArray
    str = """
      <li> <label class="label-select-view">选择版本 :</label> <select class="#{arrayItem[0]["authority"]}" name="#{arrayItem[0]["pluginDocId"]}" text="#{arrayItem[0]["identifier"]}">#{selectArray.join(" ")}</select> </li>
    """
    moduleMessage.push(str)
    paramArray = []
    str = """
      #{item["identifier"]}
      <div class="plugin-view-div">
        #{moduleMessage.join("")}
        <div class="paramsView"></div>
      </div>
    <br>
    """
    tmpEl = $(el).parent().parent().parent()
    if type is "many"
      tmpEl.html(str)
    else
      @clashPluginView.append(str)
    paramObj = {}
    paramItemMethod = (paramItem) =>
      obj =
        display:paramItem["display"]
      paramView = new ParamsItem(obj)
      paramView.display.setText(paramItem["value"])
      paramObj[paramItem["key"]] = paramView.display
      if type is "many"
        tmpEl.find(".paramsView").append(paramView)
      else
        @.find(".paramsView:last").append(paramView)
    if typeof(arrayItem[0]["params"]) isnt "undefined"
      paramItemMethod paramItem for paramItem in arrayItem[0]["params"]
    console.log arrayItem[0]["params"]
    @textEditorViewItems["#{arrayItem[0]["pluginDocId"]}"] = paramObj

  # 对象数组   noPluginList
  normalListToHtml:(normalList) ->
    console.log normalList
    normalMessageShow = []
    printPluginItem = (item) =>
      str = @initPluginItemView(item,0,"one",null)
      normalMessageShow.push(str)
    printPluginItem item for item in normalList
    if normalMessageShow.length > 0
      """
      #{normalMessageShow.join("")}
      """
    else
      ""

  initModuleList: ->
    if @projectLastContent
      array = @projectLastContent["moduleTree"]
      @mainModuleId = @projectLastContent["base"]["mainModuleId"]
    else
      array = []
      @mainModuleId = null
    initModuleListMessage = (item) =>
      text = null
      getTxt = (item1) =>
        # console.log item["value"],item[""]
        if item1["value"] is item["version"]
          text = item1["text"]
          return
      getTxt item1 for item1 in item["versions"]

      @moduleList["#{item['name']}"] =
        "moduleVersionId": item["version"]
        "moduleId": item["id"]
        "appVersionId":""
        "appId":""
        "name": item["name"]
        "moduleVersion": text
    initModuleListMessage item for item in array
    @printShowViewOfModule()

  getJsonObjLength:(jsonObj) ->
    length = 0
    printLength = (item) =>
      length = length + 1
    printLength item for item of jsonObj
    length

  # 打印输出模块信息
  printShowViewOfModule:->
    mainModuleStr = ""
    modulesTagArray = []
    showHtmlView = (key,item) =>
      str = """
      <span>[ #{item["name"]}:#{item["moduleVersion"]} ]  </span>
      """
      modulesTagArray.push(str)
      if item["moduleId"] is @mainModuleId
        mainModuleStr = str
    showHtmlView key,item for key,item of @moduleList
    if mainModuleStr is ""
      @mainModuleId = null
    if @mainModuleId is null
      @mainModuleTag.parent().hide()
    else
      @mainModuleTag.parent().show()
    if modulesTagArray.length == 0
      @modulesTag.parent().hide()
    else
      @modulesTag.parent().show()
    @mainModuleTag.html(mainModuleStr)
    @modulesTag.html(modulesTagArray.join(""))
  #初始化模块
  initSelectModuleView:(array,pageIndex,pageSize)->
    platform = "ANDROID"
    if @buildPlatform is "iOS"
      platform = "IOS"
    exceptModuleArray = array
    LoadingMask = new @LoadingMask()
    params =
      sendCookie:true
      success:(data)=>
        # console.log data
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineListClass.nextPageButton").attr("disabled",false)

        if data["totalCount"] > 0
          htmlArray = []
          getHtmlItem = (item) =>
            operationItem = ""
            if typeof(@moduleList[item["name"]]) is "undefined"
              operationItem = """
              <a value="#{item["id"]}" class="a-padding">选择</a>
              """
            else if item["id"] is @mainModuleId
              operationItem = """
              <a value="#{item["id"]}" class="cancelMainModuleTag a-padding">取消主模块</a>
              <a value="#{item["id"]}" class="cancelSelect a-padding">取消</a>
              """
              item["version"] = @moduleList[item["name"]]["moduleVersionId"]
            else
              operationItem = """
              <a value="#{item["id"]}" class="mainModuleTag a-padding">设置主模块</a>
              <a value="#{item["id"]}" class="cancelSelect a-padding">取消</a>
              """
              item["version"] = @moduleList[item["name"]]["moduleVersionId"]
            # 获取下拉框的选项
            itemArray = []
            getChildOptions = (optionItem) =>
              optionStr = ""
              if optionItem["value"] is item["version"]
                optionStr = """
                <option value="#{optionItem["value"]}" selected="selected">#{optionItem["text"]}</option>
                """
              else
                optionStr = """
                <option value="#{optionItem["value"]}">#{optionItem["text"]}</option>
                """
              itemArray.push(optionStr)
            getChildOptions optionItem for optionItem in item["versions"]
            str = """
            <tr>
              <td><span class="#{item["id"]}" value="#{item["version"]}">#{item["name"]}</span></td>
              <td>
                  <select class="#{item["id"]}">
                    #{itemArray.join("")}
                  </select>
              </td>
              <td>
                #{operationItem}
              </td>
            </tr>
            """
            htmlArray.push(str)
          getHtmlItem item for item in data["datas"]
          @modulesShowView.html(htmlArray.join(""))
          console.log "mainModuleId = #{@mainModuleId}"
          # 点击模块button按钮触发事件
          clickModuleShowViewBtn = (e) =>
            el = e.target
            className = $(el).attr("value")
            moduleName = @.find("span.#{className}").html()
            moduleVersionId = @.find("td>select.#{className}").val()
            moduleVersion = @.find("td>select.#{className}>option[value=#{moduleVersionId}]").html()
            if @moduleList.length > 0
              htmlStr = """
              <a value="#{className}" class="mainModuleTag a-padding">设置主模块</a>
              <a value="#{className}" class="cancelSelect a-padding">取消</a>
              """
            else
              @mainModuleId = className
              htmlStr = """
              <a value="#{className}" class="cancelMainModuleTag a-padding">取消主模块</a>
              <a value="#{className}" class="cancelSelect a-padding">取消</a>
              """
            if $(el).hasClass("cancelMainModuleTag")
              @mainModuleId = null
              htmlStr = """
              <a value="#{className}" class="mainModuleTag a-padding">设置主模块</a>
              <a value="#{className}" class="cancelSelect a-padding">取消</a>
              """
            else
              @moduleList[moduleName] =
                "moduleVersionId": moduleVersionId
                "moduleId":className
                "appVersionId":""
                "appId":""
                "name":moduleName
                "moduleVersion":moduleVersion
              if $(el).hasClass("mainModuleTag")
                @mainModuleId = className
                htmlStr = """
                <a value="#{className}" class="cancelMainModuleTag a-padding">取消主模块</a>
                <a value="#{className}" class="cancelSelect a-padding">取消</a>
                """
                @.find(".cancelMainModuleTag").html("设置主模块")
                @.find(".cancelMainModuleTag").addClass("mainModuleTag")
                @.find(".cancelMainModuleTag").removeClass("cancelMainModuleTag")
              else if $(el).hasClass("cancelSelect")
                delete @moduleList[moduleName]
                if @mainModuleId is className
                  @mainModuleId = null
                htmlStr = """
                <a value="#{className}" class="a-padding">选择</a>
                """
            $(el).parent().html(htmlStr)
            # view
            @printShowViewOfModule()
          @.find(".modulesShowView").on "click","a",(e) => clickModuleShowViewBtn(e)
        else
          console.log  "没有模块"
        $(LoadingMask).remove()
      error:(msg) =>
        console.log "initSelectModuleView api error = #{msg}"
        $(LoadingMask).remove()
    @.append(LoadingMask)
    client.getModuleList(params,platform,"PRIVATE",exceptModuleArray.join(","),pageIndex,pageSize)

  # 获取上一次构建时的信息
  getLastBuildMessage:()->
    if @buildPlatform is "iOS"
      platform = "IOS"
    else
      platform = "ANDROID"
    params =
      sendCookie:true
      success:(data) =>
        # console.log "getLastBuildMessage #{data}"
        @projectLastContent = data
        @initProjectBasicMessageViewStep5_2()
      error: (msg) =>
        console.log msg
        @initProjectBasicMessageViewStep5_2()
    client.getLastBuildProjectMessage(params,@projectIdFromServer,platform)

  # 获取应用ID 如果应用ID不存在则判断为
  getProjectId: () ->
    filePath = pathM.join @projectPath,@projectConfigFileName
    if !fs.existsSync(filePath)
      alert @appConfigNoExistTips
      return
    @projectConfigContent = Util.readJsonSync filePath
    if !@projectConfigContent["identifier"] or typeof(@projectConfigContent["identifier"]) == undefined
      alert @appConfigIsNoCompleteTips
      return
    LoadingMask = new @LoadingMask()
    params =
      sendCookie: true
      success: (data) =>
        # console.log data
        @projectIdFromServer = data["id"]
        @getLastBuildMessage()
        $(LoadingMask).remove()
        #如果data存在则从中获取 projectId
      error:(msg) =>
        @initProjectBasicMessageViewStep5_2()
        $(LoadingMask).remove()
        console.log msg
    @.append(LoadingMask)
    client.getAppIdByAppIndentifer(params,@projectConfigContent["identifier"])

  #初始化基本信息，也就
  initProjectBasicMessageViewStep5_1:()->
    @projectLastContent = null
    # console.log "projectBasicMessageView is show"
    @getProjectId()

  #显示内容
  initProjectBasicMessageViewStep5_2:()->
    showStyleArray = []
    # 如果获取到了上一次构建时的信息则执行这一步
    if @projectLastContent
      @logo.attr("src",@getImageUrlMethod(@projectLastContent["base"]["logoFileId"]))
      @logoImage = @projectLastContent["base"]["logoFileId"]
    getShowStyle = (item) ->
      showStyleArray.push(item.value)
    getShowStyle item for item in @.find(".showStyle:checked")
    supportMobileTypeArray = []
    if @buildPlatform is "iOS"
      getShowStyle = (item) ->
        supportMobileTypeArray.push(item.value)
      getShowStyle item for item in @.find(".supportMobileType:checked")
    else
      supportMobileTypeArray.push("Android")
    isNeedHide = 0 # 0表示需要把横竖屏都隐藏，1表示隐藏横屏，2表示隐藏竖屏，3表示不隐藏
    showView = (item) =>
      if item is "vertical"
        if isNeedHide is 0
          isNeedHide = 1
        else
          isNeedHide = 3
        htmlVerticalArray = []
        getVerticalStr = (item1) =>
          if item1 is "iPad"
            # console.log "getIPadVerticalHtml"
            htmlVerticalArray.push(@getIPadVerticalHtml())
          else if item1 is "iPhone"
            # console.log "getIPhoneVerticalHtml"
            htmlVerticalArray.push(@getIPhoneVerticalHtml())
          else
            # console.log "getAndroidVerticalHtml"
            htmlVerticalArray.push(@getAndroidVerticalHtml())
        getVerticalStr item1 for item1 in supportMobileTypeArray
        @.find(".verticalModelView").show()
        # console.log htmlVerticalArray.join("")
        @verticalModelView.html(htmlVerticalArray.join(""))
      else
        if isNeedHide is 0
          isNeedHide = 2
        else
          isNeedHide = 3
        htmlScrossArray = []
        getScrossStr = (item2) =>
          if item2 is "iPad"
            # console.log "getIPadScrossHtml"
            htmlScrossArray.push(@getIPadScrossHtml())
          else if item2 is "iPhone"
            # console.log "getIPhoneScrossHtml"
            htmlScrossArray.push(@getIPhoneScrossHtml())
          else
            # console.log "getAndroidScrossHtml"
            htmlScrossArray.push(@getAndroidScrossHtml())
        getScrossStr item2 for item2 in supportMobileTypeArray
        @.find(".scrossModelView").show()
        # console.log htmlScrossArray.join("")
        @scrossModelView.html(htmlScrossArray.join(""))
    showView item for item in showStyleArray
    @.find("img").on "click",(e) => @selectImg(e)
    # 隐藏不必要的显示
    if isNeedHide is 0
      @.find(".verticalModelView").hide()
      @.find(".scrossModelView").hide()
    else if isNeedHide is 1
      @.find(".scrossModelView").hide()
    else if isNeedHide is 2
      @.find(".verticalModelView").hide()
    # @getProjectId()

  # 点击图片,按下一步后就上传图片
  selectImg:(e) ->
    options = {}
    el = e.currentTarget
    cb = (selectPath) =>
      if selectPath? and selectPath.length != 0
        tmp = selectPath[0].substring(selectPath[0].lastIndexOf('.'))
        # console.log tmp
        if tmp is ".png"
          $(el).attr("src",selectPath[0])
          if $(el).hasClass("img-logo")
            @logoImage = selectPath[0]
          else
            @imageList[$(el).attr("value")] = selectPath[0]
          # console.log @imageList
        else
          alert desc.projectTipsStep6_selectImg
    Util.openFile options,cb

  # 点击上一步按钮触发事件
  prevBtnClick:() ->
    # console.log "prevBtnClick"
    if @step is 2
      # console.log "prevBtnClick"
      @platformSelectView.hide()
      @selectProjectView.show()
      @parentView.prevBtn.hide()
      @step = 1
    else if @step is 3
      @engineTableView.hide()
      @platformSelectView.show()
      @step = 2
    else if @step is 4
      @engineVersionView.hide()
      @engineTableView.show()
      @step = 3
    else if @step is 5
      @engineBasicMessageView.hide()
      @engineTableView.show()
      @step = 3
      # @parentView.nextBtn.text("跳过")
    else if @step is 6
      @projectBasicMessageView.hide()
      @engineBasicMessageView.show()
      # @parentView.nextBtn.text("下一步")
      @step = 5
    else if @step is 7
      @selectModuleView.hide()
      @projectBasicMessageView.show()
      # @parentView.nextBtn.text("跳过")
      @step = 6
    else if @step is 8
      @selectPluginView.hide()
      @selectModuleView.show()
      @step = 7
    else if @step is 9
      @certSelectView.hide()
      @selectPluginView.show()
      # @parentView.nextBtn.text("下一步")
      @step = 8
    else if @step is 10
      @buildReView.hide()
      @certSelectView.show()
      # @parentView.nextBtn.show()
      @parentView.nextBtn.text("下一步")
      @step = 9

  getList:(el,pageIndex,pageSize) ->
    LoadingMask = new @LoadingMask()
    @.append(LoadingMask)
    if $(el).hasClass("engineListClass")
      @getApiEngingList(pageIndex,pageSize)
    else if $(el).hasClass("engineVersionListClass")
      @getEngineVersionList(pageIndex,pageSize)
    else if $(el).hasClass("moduleListClass")
      @initSelectModuleView([],pageIndex,pageSize)
    else if $(el).hasClass("pluginListClass")
      @initSelectPluginView([],pageIndex,pageSize)
    $(LoadingMask).remove()

  # 点击下一页所触发的事件
  nextPageClick:(e) ->
    el = e.currentTarget
    @pageIndex = @pageIndex + 1
    # console.log @pageIndex
    @getList(el,@pageIndex,@pageSize)

  # 点击上一页所触发的事件
  prevPageClick:(e) ->
    el = e.currentTarget
    if @pageIndex > 1
      @pageIndex = @pageIndex - 1
    else
      @pageIndex = 1
      return
    # console.log @pageIndex
    @getList(el,@pageIndex,@pageSize)

  # 获取引擎列表
  getApiEngingList:(pageIndex,pageSize) ->
    LoadingMask = new @LoadingMask()
    platform = "IOS"
    if @buildPlatform is "Android"
      platform = "ANDROID"
    params =
      sendCookie: true
      success:(data) =>
        # console.log data
        # 判断是否没有下一页了
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineListClass.nextPageButton").attr("disabled",false)
        if data['totalCount'] > 0
          @tipsNoEngins.hide()
          @enginesView.show()
          htmlArray = []
          jointBodyItem = (item) =>
            if item['platform'] is "android"
              item['platform'] = "Android"
            else
              item['platform'] = "iOS"
            str = """
              <tr>
              <td>#{item['identifier']}</td>
              <td>#{item['platform']}</td>
              <td>#{item['name']}</td>
              <td>#{item['describe']}</td>
              <td>#{item['updateTime']}</td>
              <td><a value="#{item['id']}" text="#{item['name']}" class="engineSelectA">选择</a></td>
              </tr>
            """
            htmlArray.push(str)
          jointBodyItem item for item in data["data"]
          @engineItemShowView.html(htmlArray.join(""))
          @.find(".engineSelectA").on "click",(e) => @clickEngineSelectA(e)
        else
          @enginesView.hide()
          @tipsNoEngins.show()
          @engineItemShowView.html("没有引擎...")
        $(LoadingMask).remove()
      error:(msg) =>
        console.log msg
        $(LoadingMask).remove()
    @.append(LoadingMask)
    client.getEngineList params,@engineType,platform,pageIndex,pageSize

  # 初始化引擎列表
  initEngineTableView:() ->
    @engineMessage = null
    @pageIndex = 1
    @pageSize = 4
    @getApiEngingList @pageIndex,@pageSize

  # 点击选择，直接就获取引擎的版本列表
  clickEngineSelectA:(e) ->
    @step = 4
    @engineTableView.hide()
    @engineVersionView.show()

    #初始化分页信息
    @pageSize = 4
    @pageIndex = 1
    @pageTotal = 1
    el = e.currentTarget
    @engineId = $(el).attr("value")
    @enginName.html("&nbsp;&nbsp;"+$(el).attr("text"))
    console.log @engineId
    @getEngineVersionList(@pageIndex,@pageSize)

  # 根据引擎的Id 获取引擎版本列表并显示出来
  getEngineVersionList:(pageIndex,pageSize) ->
    params =
      sendCookie:true
      success:(data)=>
        # console.log data
        # 判断是否没有下一页了
        if data['totalCount'] <= pageIndex*@pageSize
          @.find(".engineVersionListClass.nextPageButton").attr("disabled",true)
        else
          @.find(".engineVersionListClass.nextPageButton").attr("disabled",false)
        if data["totalCount"] > 0
          htmlArray = []
          count = 0
          # @engineVersionList = data["data"]
          jointBodyItem = (item) =>
            str = """
            <tr>
            <td>#{item["version"]}</td>
            <td>#{item["fileSize"]}</td>
            <td>#{item["uploadTime"]}</td>
            <td>#{item["updateContent"]}</td>
            <td><a value="#{count}" class="selectEngineVersionA">选择</a></td>
            </tr>
            """
            count = count + 1
            htmlArray.push(str)
          jointBodyItem item for item in data["data"]
          @engineVersionItemView.html(htmlArray.join(""))
          # 点击选择引擎版本链接所触发的事件
          selectEngineVersionAClick = (e) =>
            LoadingMask = new @LoadingMask()
            @.append(LoadingMask)
            @engineVersionView.hide()
            @engineBasicMessageView.show()
            el = e.currentTarget
            index = $(el).attr("value")
            @step = 5
            # console.log @engineVersionList[index]
            @initEngineBasicView(data["data"][index])
            $(LoadingMask).remove()
          @.find(".selectEngineVersionA").on "click",(e) => selectEngineVersionAClick(e)
        else
          @engineVersionItemView.html("没有任何版本...")
      error: (msg) =>
        console.log msg
    client.getEngineVersionList(params,@engineId,pageIndex,pageSize)

  # 获取引擎信息
  getBasicMessageView:() ->
    LoadingMask = new @LoadingMask()
    params =
      sendCookie:true
      success:(data) =>
        # console.log data
        @initEngineBasicView(data)
        $(LoadingMask).remove()
      error: (msg) =>
        console.log msg
        $(LoadingMask).remove()
    @.append(LoadingMask)
    client.getDefaultEngineMessage(params,@buildPlatform)

  # 初始化引擎基本信息
  initEngineBasicView:(data) ->
    @engineMessage = data
    if @buildPlatform is "iOS"
      @.find(".iOSSupportView").show()
    else
      @.find(".iOSSupportView").hide()
    if data["platform"] is "android"
      data["platform"] = "Android"
    else
      data["platform"] = "iOS"
    @engineIdView.html(data["identifier"])
    @engineName.html(data["name"])
    @platform.html(data["platform"])
    @engineSize.html(data["fileSize"])
    @engineVersion.html(data["version"])
    # console.log "env=",data["buildEnvironment"]["name"]
    @buildEnv.html(data["buildEnvironment"]["name"]+data["buildEnvironment"]["version"])

  # 获取左边文件
  setSelectItem:(path) ->
    filePath = pathM.join path, @projectConfigFileName
    #判断文件是否存在，不存在则跳出
    if !fs.existsSync(filePath)
      return
    obj = Util.readJsonSync filePath
    if obj
      projectName = pathM.basename path
      optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
      @selectProject.append optionStr

  # 选择应用下来框选择的选项发生改变时会被触发
  onSelectChange: (e) ->
    el = e.currentTarget
    if el.value == '其他'
      @open()

  # 当选择应用是点击了下拉框中的其他选项时触发
  open: ->
    atom.pickFolder (paths) =>
      if paths?
        path = pathM.join paths[0]
        # console.log  path
        filePath = pathM.join path,@projectConfigFileName
        if !fs.existsSync(filePath)
          @.find("select option:first").prop("selected","selected")
          alert @selectProjectTxt
          return
        # console.log filePath
        if !fs.existsSync(filePath)
          @.find("select option:first").prop("selected","selected")
          alert @pleaseSelectRealProjectTips
          return
        obj = Util.readJsonSync filePath
        if obj
          projectName = pathM.basename path
          optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
          @.find("select option[value=' ']").remove()
          @selectProject.prepend optionStr
        else
          alert desc.selectCorrectProject
        @selectProject.get(0).selectedIndex = 0
      else
        @selectProject.get(0).selectedIndex = 0

  #获取苹果手机横屏显示类型
  getIPhoneScrossHtml:() ->
    iphoneSrc = desc.getImgPath "default_app_iphone_scross_logo.png"
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      if typeof(images["iphone960_640"]) is "undefined" || images["iphone960_640"] == ""
        images["iphone960_640"] = iphoneSrc
      else
        @imageList["iphone960_640"] = images["iphone960_640"]
        images["iphone960_640"] = @getImageUrlMethod(images["iphone960_640"])
      if typeof(images["iphone1136_640"]) is "undefined" || images["iphone1136_640"] == ""
        images["iphone1136_640"] = iphoneSrc
      else
        @imageList["iphone1136_640"] = images["iphone1136_640"]
        images["iphone1136_640"] = @getImageUrlMethod(images["iphone1136_640"])
      if typeof(images["iphone1334_750"]) is "undefined" || images["iphone1334_750"] == ""
        images["iphone1334_750"] = iphoneSrc
      else
        @imageList["iphone1334_750"] = images["iphone1334_750"]
        images["iphone1334_750"] = @getImageUrlMethod(images["iphone1334_750"])
      if typeof(images["iphone2208_1242"]) is "undefined" || images["iphone2208_1242"] == ""
        images["iphone2208_1242"] = iphoneSrc
      else
        @imageList["iphone2208_1242"] = images["iphone2208_1242"]
        images["iphone2208_1242"] = @getImageUrlMethod(images["iphone2208_1242"])
      """
      <li>
      <div class='iphone-scross-launch' >
      <img class='iphone-scross-launch-img' src='#{images["iphone960_640"]}' value='iphone960_640'>
      </div>
      <p>960&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{images["iphone1136_640"]}' value='iphone1136_640'>
      </div>
      <p>1136&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{images["iphone1334_750"]}' value='iphone1334_750'>
      </div>
      <p>1334&nbsp;X&nbsp;750</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{images["iphone2208_1242"]}' value='iphone2208_1242'>
      </div>
      <p>2208&nbsp;X&nbsp;1242</p>
      </li>&nbsp;
      """
    else
      """
      <li>
      <div class='iphone-scross-launch' >
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone960_640'>
      </div>
      <p>960&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone1136_640'>
      </div>
      <p>1136&nbsp;X&nbsp;640</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone1334_750'>
      </div>
      <p>1334&nbsp;X&nbsp;750</p>
      </li>&nbsp;
      <li>
      <div class='iphone-scross-launch'>
      <img class='iphone-scross-launch-img' src='#{iphoneSrc}' value='iphone2208_1242'>
      </div>
      <p>2208&nbsp;X&nbsp;1242</p>
      </li>&nbsp;
      """

  # 获取苹果手机竖屏显示类型
  getIPhoneVerticalHtml:() ->
    iphoneSrc = desc.getImgPath "default_app_iphone_logo.png"
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      if typeof(images["iphone640_960"]) is "undefined" || images["iphone640_960"] == ""
        images["iphone640_960"] = iphoneSrc
      else
        @imageList["iphone640_960"] = images["iphone640_960"]
        images["iphone640_960"] = @getImageUrlMethod(images["iphone640_960"])
      if typeof(images["iphone640_1136"]) is "undefined" || images["iphone640_1136"] == ""
        images["iphone640_1136"] = iphoneSrc
      else
        @imageList["iphone640_1136"] = images["iphone640_1136"]
        images["iphone640_1136"] = @getImageUrlMethod(images["iphone640_1136"])
      if typeof(images["iphone750_1334"]) is "undefined" || images["iphone750_1334"] == ""
        images["iphone750_1334"] = iphoneSrc
      else
        @imageList["iphone750_1334"] = images["iphone750_1334"]
        images["iphone750_1334"] = @getImageUrlMethod(images["iphone750_1334"])
      if typeof(images["iphone1242_2208"]) is "undefined" || images["iphone1242_2208"] == ""
        images["iphone1242_2208"] = iphoneSrc
      else
        @imageList["iphone1242_2208"] = images["iphone1242_2208"]
        images["iphone1242_2208"] = @getImageUrlMethod(images["iphone1242_2208"])
      """
      <li>
      <div class='iphone-launch' >
      <img class='iphone-launch-img' src='#{images["iphone640_960"]}' value='iphone640_960'>
      </div>
      <p>640&nbsp;X&nbsp;960</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{images["iphone640_1136"]}' value='iphone640_1136'>
      </div>
      <p>640&nbsp;X&nbsp;1136</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{images["iphone750_1334"]}' value='iphone750_1334'>
      </div>
      <p>750&nbsp;X&nbsp;1334</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{images["iphone1242_2208"]}' value='iphone1242_2208'>
      </div>
      <p>1242&nbsp;X&nbsp;2208</p>
      </li>&nbsp;
      """
    else
      """
      <li>
      <div class='iphone-launch' >
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone640_960'>
      </div>
      <p>640&nbsp;X&nbsp;960</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone640_1136'>
      </div>
      <p>640&nbsp;X&nbsp;1136</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone750_1334'>
      </div>
      <p>750&nbsp;X&nbsp;1334</p>
      </li>&nbsp;
      <li>
      <div class='iphone-launch'>
      <img class='iphone-launch-img' src='#{iphoneSrc}' value='iphone1242_2208'>
      </div>
      <p>1242&nbsp;X&nbsp;2208</p>
      </li>&nbsp;
      """

  #获取苹果平板横屏显示类型
  getIPadScrossHtml:() ->
    ipadSrc = desc.getImgPath "default_app_ipad_scross_logo.png"
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      if typeof(images["ipad2208_1242"]) is "undefined" || images["ipad2208_1242"] == ""
        images["ipad2208_1242"] = ipadSrc
      else
        @imageList["ipad2208_1242"] = images["ipad2208_1242"]
        images["ipad2208_1242"] = @getImageUrlMethod(images["ipad2208_1242"])
      """
      <li>
      <div class='ipad-scross-launch' >
      <img class='ipad-scross-launch-img' src='#{images["ipad2208_1242"]}' value='ipad2208_1242'>
      </div>
      <p>2208 X 1242</p>
      </li>&nbsp;
      """
    else
      """
      <li>
      <div class='ipad-scross-launch' >
      <img class='ipad-scross-launch-img' src='#{ipadSrc}' value='ipad2208_1242'>
      </div>
      <p>2208 X 1242</p>
      </li>&nbsp;
      """

  #获取苹果平板竖屏显示类型
  getIPadVerticalHtml:() ->
    ipadSrc = desc.getImgPath "default_app_ipad_logo.png"
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      if typeof(images["ipad1242_2208"]) is "undefined" || images["ipad1242_2208"] == ""
        images["ipad1242_2208"] = ipadSrc
      else
        @imageList["ipad1242_2208"] = images["ipad1242_2208"]
        images["ipad1242_2208"] = @getImageUrlMethod(images["ipad1242_2208"])
      """
      <li>
      <div class='ipad-launch' >
      <img class='ipad-launch-img' src='#{images["ipad1242_2208"]}' value='ipad1242_2208'>
      </div>
      <p>1242 X 2208</p>
      </li>&nbsp;
      """
    else
      """
      <li>
      <div class='ipad-launch' >
      <img class='ipad-launch-img' src='#{ipadSrc}' value='ipad1242_2208'>
      </div>
      <p>1242 X 2208</p>
      </li>&nbsp;
      """

  #获取安卓手机横屏显示类型
  getAndroidScrossHtml:() ->
    androidSrc = desc.getImgPath "default_app_android_scross_logo.png"
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      if typeof(images["android960_640"]) is "undefined" || images["android960_640"] == ""
        images["android960_640"] = androidSrc
      else
        @imageList["android960_640"] = images["android960_640"]
        images["android960_640"] = @getImageUrlMethod(images["android960_640"])
        console.log images["android960_640"]
      if typeof(images["android1136_640"]) is "undefined" || images["android1136_640"] == ""
        images["android1136_640"] = androidSrc
      else
        @imageList["android1136_640"] = images["android1136_640"]
        images["android1136_640"] = @getImageUrlMethod(images["android1136_640"])
      """
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{images["android960_640"]}' value='android960_640'>
      </div>
      <p>960 X 640</p>
      </li>&nbsp;
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{images["android1136_640"]}' value='android1136_640'>
      </div>
      <p>1136 X 640</p>
      </li>&nbsp;
      """
    else
      """
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{androidSrc}' value='android960_640'>
      </div>
      <p>960 X 640</p>
      </li>&nbsp;
      <li>
      <div class='android-scross-launch' >
      <img class='android-scross-launch-img' src='#{androidSrc}' value='android1136_640'>
      </div>
      <p>1136 X 640</p>
      </li>&nbsp;
      """

  #获取安卓手机竖屏显示类型
  getAndroidVerticalHtml:() ->
    androidSrc = desc.getImgPath "default_app_android_logo.png"
    if @projectLastContent
      images = @projectLastContent["base"]["images"]
      if typeof(images["android640_960"]) is "undefined" || images["android640_960"] == ""
        images["android640_960"] = androidSrc
      else
        @imageList["android640_960"] = images["android640_960"]
        images["android640_960"] = @getImageUrlMethod(images["android640_960"])
      if typeof(images["android640_1136"]) is "undefined" || images["android640_1136"] == ""
        images["android640_1136"] = androidSrc
      else
        @imageList["android640_1136"] = images["android640_1136"]
        images["android640_1136"] = @getImageUrlMethod(images["android640_1136"])
      """
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{images["android640_960"]}' value='android640_960'>
      </div>
      <p>640 X 960</p>
      </li>&nbsp;
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{images["android640_1136"]}' value='android640_1136'>
      </div>
      <p>640 X 1136</p>
      </li>&nbsp;
      """
    else
      """
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{androidSrc}' value='android640_960'>
      </div>
      <p>640 X 960</p>
      </li>&nbsp;
      <li>
      <div class='android-launch' >
      <img class='android-launch-img' src='#{androidSrc}' value='android640_1136'>
      </div>
      <p>640 X 1136</p>
      </li>&nbsp;
      """

  # 获取图片的url
  getImageUrlMethod:(fileId, pixel) ->
    if !fileId
      return fileId
    if !pixel
      pixel = ''
    QINIU_URL = null
    HEX_RADIX = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f']
    QINIU_HTTP = 'http://7xl047.com2.z0.glb.qiniucdn.com/'
    WEB_CONTEXT = @httpType+'://bsl.foreveross.com/qdt-web-dev/images/'
    QINIU_HTTPS = 'https://dn-qdt-web.qbox.me/'
    if @httpType is 'http'
      QINIU_URL = QINIU_HTTP
    else if @httpType is 'https'
      QINIU_URL = QINIU_HTTPS
    else
      QINIU_URL = ''
    if fileId.indexOf("qdt_icon_") is 0
      return  WEB_CONTEXT + fileId
    else
      start = fileId.toLowerCase().charAt(0)
      index = 0
      returnUrl = null
      methodFor = (item) =>
        if start is HEX_RADIX[index]
          returnUrl = QINIU_URL + fileId + pixel
          return returnUrl
        index = index + 1
      methodFor item for item in HEX_RADIX
      if returnUrl
        return returnUrl
      if fileId.indexOf(QINIU_URL) is 0
        return QINIU_URL + fileId.substring(QINIU_URL.length, fileId.length) + pixel
      else if fileId.indexOf(QINIU_URL) is 0
        return QINIU_URL + fileId.substring(QINIU_URL.length, fileId.length) + pixel
      return fileId


class ParamsItem extends View
  @content:(obj)->
    @li =>
      @label obj.display,class:"label-plugin-param-view"
      @div class: 'inline-plugin-view',name:"", =>
        @subview "display", new TextEditorView(mini: true,placeholderText: 'Certificate keystore password...')

module.exports =
  class BuildProjectView extends ChameleonBox
    options :
      title: desc.buildProjectMainTitle
      subview: new BuildProjectInfoView()
    closeView: ->
      # console.log @contentView.buildPlatform
      window.clearTimeout(@contentView.timerEvent)
      super()
