{$,TextEditorView,View} = require 'atom-space-pen-views'
pathM = require 'path'
desc = require './../utils/text-description'
Util = require './../utils/util'
ChameleonBox = require '../utils/chameleon-box-view'
fs = require 'fs-extra'
client = require '../utils/client'
UtilExtend = require './../utils/util-extend'

class BuildProjectInfoView extends View
  checkBuildResultTimer: {}
  ticketTimer:{}
  buildPlatformId:{}

  @content: ->
    @div class: 'build_project_vew', =>
      @div outlet: 'main', =>
        @div class: 'col-xs-12', =>
          @label "选择需要构建的应用平台"
        @div class: 'col-xs-6 text-center padding-top', =>
          @div class: 'col-xs-12 text-center', =>
            @div class: 'selectBuildTemplate',value:'ios', =>
              @img outlet:'iosIcon',src: desc.getImgPath 'icon_apple.png'
          @div class: 'col-xs-12 padding-top',outlet:"ios_img_checkbox", =>
            @input type: 'checkbox', value: 'iOS',id:'ios',class:'hide'
            @label "iOS",for: "ios"
        @div class: 'col-xs-6 text-center padding-top', =>
          @div class: 'col-xs-12 text-center', =>
            @div class: 'selectBuildTemplate',value:'android', =>
              @img outlet:'androidIcon',src: desc.getImgPath 'icon_android.png'
          @div class: 'col-xs-12 padding-top',outlet:"android_img_checkbox",=>
            @input type: 'checkbox', value: 'Android', id:'android',class:'hide'
            @label "Android", for: "android"
      @div outlet: 'selectApp', class:'form-horizontal form_width',=>
        # @div class: 'form-group', =>
        @label '选择构建的应用', class: 'col-sm-3 control-label'
        @div class: 'col-sm-9', =>
          @select class: '', outlet: 'selectProject'
      @div outlet: 'buildMessage',  =>
        @div class: 'form-horizontal', =>
          @div class: 'form-group', =>
            @label "应用信息", class: 'col-sm-3 control-label'
            @div class: 'col-sm-9', =>
              @button 'iOS', class: 'btn formBtn', value: 'iOS', outlet: 'iosBtn'
              @button 'Android',class: 'btn formBtn', value: 'Android', outlet: 'androidBtn'
          @div class: 'form-group', =>
            @label '应用标识' , class: 'col-sm-3 text-align-right'
            # @div class: 'col-sm-9', =>
            @label class: 'col-sm-9 disabled-text',outlet:'identifier'
          @div class: 'form-group', =>
            @label "构建平台", class: 'col-sm-3 text-align-right'
            # @div class: 'col-sm-9', =>
            @label class: 'col-sm-9 disabled-text',outlet:'platform'
        @div class: 'form-horizontal', outlet: 'iosForm', =>
          # @div class: 'form-group', =>
          #   @label '应用logo' , class: 'col-sm-3 control-label'
          #   @div class: 'col-sm-9', =>
          #     @subview 'iOSLogo', new TextEditorView(mini: true)
          #     @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openIOS'
          @div class: 'form-group', =>
            @label '应用名称' , class: 'col-sm-3 control-label'
            @div class: 'col-sm-9', =>
              @subview 'iosName', new TextEditorView(mini: true)
          @div class: 'form-group', outlet:'iOSPluginsFormgroup', =>
            @label '所选插件' , class: 'col-sm-3 control-label'
            @label class: 'col-sm-9 padding-left',outlet: 'iOSPlugins'
        @div class: 'form-horizontal', outlet: 'androidForm', =>
          # @div class: 'form-group', =>
          #   @label '应用logo' , class: 'col-sm-3 control-label'
          #   @div class: 'col-sm-9', =>
          #     @subview 'androidLogo', new TextEditorView(mini: true)
          #     @span class: 'inline-block status-added icon icon-file-directory openFolder', click: 'openAndroid'
          @div class: 'form-group', =>
            @label '应用名称' , class: 'col-sm-3 control-label'
            @div class: 'col-sm-9', =>
              @subview 'androidName', new TextEditorView(mini: true)
          @div class: 'form-group', outlet:'androidPluginsFormgroup', =>
            @label '所选插件' , class: 'col-sm-3 control-label'
            @div class: 'col-sm-9', =>
              @label outlet: 'androidPlugins'
      @div outlet: 'buildingTips', =>
        @div class: 'block', =>
          @div class: "col-sm-12", =>
            @span "" ,outlet: "buildTips"
          @div class: "col-sm-12 text-center", =>
            @progress class: 'inline-block'
          @div class: "col-sm-12 text-center", =>
            @span "" ,class: "iosTips"
          @div class: "col-sm-12 text-center", =>
            @span "" ,class: "androidTips"
      @div outlet: 'urlCodeList', =>
        @div class: 'col-sm-12', =>
          @label "构建成功后返回的二维码"
        @div class:'col-sm-12 text-center',  =>
          @div class: 'col-sm-6 text-center', outlet: 'ios_code_view' ,=>
            @div class: 'col-sm-12', outlet: 'ios_build_result_tips'
            @div class: 'col-sm-12', =>
              @img class:'codeImg', outlet: 'iOSCode',src: desc.getImgPath 'iphone.png'
            @div class: 'col-sm-12 label_pad', =>
              @img src: desc.getImgPath 'icon_apple02.png'
              @label "iOS",class:'iosTips platform_tips_label'
            @div class: 'col-sm-12', =>
              @a outlet:'iosUrl'

          @div class: 'col-sm-6 text-center', outlet: 'android_code_view', =>
            @div class: 'col-sm-12', outlet: 'android_build_result_tips'
            @div class: 'col-sm-12', =>
              @img class:'codeImg',outlet: 'androidCode', src: desc.getImgPath 'android.png'
            @div class: 'col-sm-12 label_pad', =>
              @img src: desc.getImgPath 'icon_android02.png'
              @label "Andoird",class:'androidTips platform_tips_label'
            @div class: 'col-sm-12', =>
              @a outlet:'androidUrl'


  clickIcon:(e) ->
    console.log "hinhs"
    el = e.currentTarget
    console.log $(el).attr('value')
    if $(el).attr('value') is 'ios'
      @.find("#ios").trigger('click')
    else
      @.find("#android").trigger('click')
    if $(el).hasClass('active')
      console.log "has"
      $(el).removeClass('active')
    else
      console.log "no have"
      $(el).addClass('active')

  initialize: ->
    @.find('.selectBuildTemplate').on 'click',(e) => @clickIcon(e)
    # @selectProject.on 'change',(e) => @onSelectChange(e)
    # @.find('.formBtn').on 'click', (e) => @formBtnClick(e)

  attached: ->
    # android_img_checkbox_html = "<input type='checkbox' value='android' id='android' class='hide'/><label for='android'>Android</label>"
    # @android_img_checkbox.html(android_img_checkbox_html)
    if @.find("#ios").is(":checked")
      console.log "no"

    @initializeInput()
      #检测是否需要 清空  timeout
    if @checkBuildResultTimer["IOS"]
      window.clearTimeout(@checkBuildResultTimer["IOS"])
    if @checkBuildResultTimer["ANDROID"]
      window.clearTimeout(@checkBuildResultTimer["ANDROID"])
    if @ticketTimer["ANDROID"]
      window.clearTimeout(@ticketTimer["ANDROID"])
    if @ticketTimer["IOS"]
      window.clearTimeout(@ticketTimer["IOS"])
    #检测是否需要取消之前的构建
    @main.addClass('hide')
    @buildMessage.addClass('hide')
    @selectApp.removeClass('hide')
    @buildingTips.addClass('hide')
    @urlCodeList.addClass('hide')
    # @urlCodeList.removeClass('hide')
    # return
    @ios_code_view.addClass('hide')
    @android_code_view.addClass('hide')
    @parentView.nextBtn.attr('disabled',false)
    projectPaths = atom.project.getPaths()
    projectNum = projectPaths.length
    @selectProject.empty()
    if projectNum isnt 0
      @setSelectItem path for path in projectPaths
    if @selectProject.children().length is 0
      optionStr = "<option value=' '> </option>"
      @selectProject.append optionStr
    optionStr = "<option value='其他'>其他</option>"
    @selectProject.append optionStr
    @selectProject.on 'change',(e) => @onSelectChange(e)
    @.find('.formBtn').on 'click', (e) => @formBtnClick(e)

  initializeInput: ->
    @.find('input[type=checkbox]').attr('checked',false)
    @.find('.selectBuildTemplate').removeClass('active')
    @iosName.setText("")
    @androidName.setText("")

  setSelectItem:(path) ->
    filePath = pathM.join path,desc.ProjectConfigFileName
    obj = Util.readJsonSync filePath
    if obj
      projectName = pathM.basename path
      optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
      @selectProject.append optionStr

  # initialize: ->

  formBtnClick: (e) ->
    el = e.currentTarget
    if el.value is 'iOS'
      @platform.html('iOS')
      @iosForm.show()
      @androidForm.hide()
    else
      @platform.html('Android')
      @iosForm.hide()
      @androidForm.show()

  onSelectChange: (e) ->
    el = e.currentTarget
    if el.value == '其他'
      @open()

  open: ->
    atom.pickFolder (paths) =>
      if paths?
        path = pathM.join paths[0]
        # console.log  path
        filePath = pathM.join path,desc.ProjectConfigFileName
        # console.log filePath
        obj = Util.readJsonSync filePath
        if obj
          projectName = pathM.basename path
          optionStr = "<option value='#{path}'>#{projectName}  -  #{path}</option>"
          @.find("select option[value=' ']").remove()
          @selectProject.prepend optionStr
        else
          alert "请选择变色龙应用"
        @selectProject.get(0).selectedIndex = 0
      else
        @selectProject.get(0).selectedIndex = 0

  nextBtnClick: ->
    if @selectApp.is(':visible')
      @selectApp.addClass('hide')
      @main.removeClass('hide')
      @parentView.prevBtn.show()
    else if @main.is(':visible')
      checkboxList = this.find('input[type=checkbox]:checked')
      # console.log checkboxList
      # console.log  @.find('#ios').is(':checked')
      # console.log @.find('#android').is(':checked')
      if checkboxList.length isnt 0
        # console.log 'Build'
        hasIos = false
        configPath = pathM.join this.find('select').val(),desc.ProjectConfigFileName
        options =
          encoding: "UTF-8"
        state = fs.statSync(configPath)
        if !state.isFile()
          alert "文件不存在"
          return
        strContent = fs.readFileSync(configPath,options)
        # fs.closeSync(configPath)
        jsonContent = JSON.parse(strContent)
        @identifier.attr('value',jsonContent['identifier'])
        @identifier.html(jsonContent['identifier'])
        showBuildMessage = (checkbox) =>
          # console.log $(checkbox).attr('value')
          if $(checkbox).attr('value') is 'iOS'
            hasIos = true
            # 获取IOS插件信息
            params =
              sendCookie: true
              success: (data) =>
                # console.log data
                strContent = ""
                showPlaugins = (obj) ->
                  strContent = strContent+" | "+ "#{obj['identifier']} : #{obj['version']}(#{obj['type']})"
                showPlaugins obj for obj in data
                if strContent == ""
                  @iOSPluginsFormgroup.hide()
                else
                  @iOSPluginsFormgroup.show()
                @iOSPlugins.html(strContent)
              error: =>
                # console.log "console.error"
            client.getAppPlugins(params, jsonContent['identifier'], 'IOS')
          else
            params =
              sendCookie: true
              success: (data) =>
                # console.log data
                strContent = ""
                showPlaugins = (obj) ->
                  strContent = strContent+" | "+ "#{obj['identifier']} : #{obj['version']}(#{obj['type']})"
                showPlaugins obj for obj in data
                if strContent == ""
                  @androidPluginsFormgroup.hide()
                else
                  @androidPluginsFormgroup.show()
                @androidPlugins.html(strContent)
              error: =>
                # console.log "console.error"
            client.getAppPlugins(params, jsonContent['identifier'], 'ANDROID')
            # 结束获取插件信息
        showBuildMessage checkbox for checkbox in checkboxList
        @main.addClass('hide')
        @buildMessage.removeClass('hide')
        # console.log @androidBtn
        if hasIos
          @androidForm.hide()
          @iosForm.show()
          @platform.html('iOS')
          @iosBtn.attr( 'disabled', false)
          @androidBtn.attr( 'disabled', false)
          if checkboxList.length is 1
            @androidBtn.attr( 'disabled', true)
        else
          @platform.html('Android')
          @androidBtn.attr( 'disabled', false)
          @iosBtn.attr( 'disabled', true)
          @iosForm.hide()
          @androidForm.show()
      else
        alert "请选择构建平台"
        return
    else if @buildMessage.is(':visible')
      if !@iosBtn.attr('disabled')
        if @iosName.getText() is ""
          alert 'iOS 的应用 名字 不能为空'
          return
      if !@androidBtn.attr('disabled')
        if @androidName.getText() is ""
          alert 'android 的应用 名字 不能为空'
          return
      @buildingTips.removeClass('hide')
      @buildMessage.addClass('hide')
      @parentView.prevBtn.text('取消')
      @parentView.nextBtn.hide()
      # @parentView.nextBtn.attr('disabled',true)
      # 开始构建
      # 1、检查本地模块信息在服务器是否已经存在
      #   如果存在则不需上传模块；
      #   如果不存在则需要上床模块。
      # 2、上传完模块后需要上传应用信息
      configPath = pathM.join this.find('select').val(),desc.ProjectConfigFileName
      options =
        encoding: "UTF-8"
      strContent = fs.readFileSync(configPath,options)
      jsonContent = JSON.parse(strContent)
      modules = jsonContent['modules']
      @buildTips.html("正在检测模块信息......")
      projectPath = pathM.join this.find('select').val(), 'modules'
      moduleList = []
      @buildTips.html("构建准备......")
      getModuleMessage = (identifier,version) =>
        module =
          identifier: identifier
          version: version
        moduleList.push module
      getModuleMessage identifier,version for identifier, version of modules
      @checkModuleNeedUpload projectPath, moduleList, 0

  checkModuleNeedUpload: (modulePath, modules, index) ->
    if modules.length == 0
      # console.log "length = 0"
      @sendBuildMessage()
      return
    else
      moduleIdentifer = modules[index]['identifier']
      moduleVersion = modules[index]['version']
      moduleRealPath = pathM.join modulePath, moduleIdentifer
      params =
        sendCookie: true
        success: (data) =>
          # console.log "check version success"
          build = data['build']
          if data['version'] != ""
            # uploadVersion = moduleVersion.split('.')
            # version = data['version'].split('.')
            # 判断是否需要上传模块
            result = UtilExtend.checkUploadModuleVersion(moduleVersion,data['version'])
            if result['error']
              console.log "无需更新#{moduleIdentifer} 本地版本为#{moduleVersion},服务器版本为：#{data['version']}"
              if modules.length == index+1
                @sendBuildMessage()
              else
                @checkModuleNeedUpload(modulePath, modules, index+1)
              return

          if fs.existsSync(moduleRealPath)
            Util.fileCompression(moduleRealPath)
            zipPath = moduleRealPath+'.zip'
            if fs.existsSync(zipPath)
              # console.log zipPath
              fileParams =
                formData: {
                  up_file: fs.createReadStream(zipPath)
                }
                sendCookie: true
                success: (data) =>
                  data2 = {}
                  Util.removeFileDirectory(zipPath)
                  methodUploadModule = =>
                    if fs.existsSync(pathM.join moduleRealPath,'package.json')
                      packagePath = pathM.join moduleRealPath,'package.json'
                      options =
                        encoding: 'utf-8'
                      contentList = JSON.parse(fs.readFileSync(packagePath,options))
                      # 当  配置信息中不存在build字段时，新建字段 初始化为 1
                      #否则  +1
                      if build? and build != ""
                        contentList['build'] = parseInt(build) + 1
                      else
                        contentList['build'] = 1
                      # alert contentList['build']+"  "+data2['url_id']
                      params =
                        formData:{
                          module_tag: contentList['identifier'],
                          module_name: contentList['name'],
                          module_desc: "",#contentList['description']
                          version: contentList['version'],
                          url_id: data['url_id'],
                          build:contentList['build'].toString(),
                          logo_url_id: data2['url_id'],
                          update_log: "构建应用时发现本地版本高于服务器版本，所以上传 #{contentList['identifier']} 模块"
                        }
                        sendCookie: true
                        success: (data) =>
                          if modules.length == index+1
                            @sendBuildMessage()
                          else
                            @checkModuleNeedUpload(modulePath, modules, index+1)
                        error: =>
                          alert "上传#{modulePath}失败"
                      client.postModuleMessage(params)
                    else
                      console.log "文件不存在#{pathM.join modulePath,'package.json'}"
                  if fs.existsSync(pathM.join moduleRealPath,'icon.png')
                    fileParams2 =
                      formData: {
                        up_file: fs.createReadStream(pathM.join moduleRealPath,'icon.png')
                      }
                      sendCookie: true
                      success: (data) =>
                        #给 data2 初始化
                        data2 = data
                        # console.log data2
                        methodUploadModule()
                      error: =>
                        # console.log iconPath
                        console.log "上传icon失败"
                        alert "上传icon失败"
                    client.uploadFile(fileParams2,"module","")
                  else
                    data2["url_id"] = ""
                    methodUploadModule()
                error: =>
                  Util.removeFileDirectory(zipPath)
                  alert "上传文件失败"
              client.uploadFile(fileParams,"module","")
            else
              alert "打包#{moduleRealPath}失败"
          else
            alert "不存在#{moduleRealPath}"
        error : =>
          console.log "获取模板最新版本 的url 调不通"
      client.getModuleLastVersion(params,moduleIdentifer)
    # console.log

  sendBuildMessage: ->
    # console.log "finish send"
    checkboxList = this.find('input[type=checkbox]:checked')  # param 1
    platformInfo = []
    iosObj = null
    androidObj = null
    postAppBuildMessage = (checkbox) =>
      if $(checkbox).attr('value') is 'iOS'
        iosObj =
          logoFileId: ""
          platform: "IOS"
          pkgName: @iosName.getText()
      else
        androidObj =
          logoFileId: ""
          platform: "ANDROID"
          pkgName: @androidName.getText()
    postAppBuildMessage checkbox for checkbox in checkboxList
    if iosObj
      platformInfo.push(iosObj)
    if androidObj
      platformInfo.push(androidObj)
    configPath = pathM.join this.find('select').val(),desc.ProjectConfigFileName
    # console.log configPath
    options =
      encoding: "utf-8"
    contentList = JSON.parse(fs.readFileSync(configPath,options))
    userMail = Util.store('chameleon').mail
    bodyJSON =
      identifier: @identifier.attr("value"),
      platformInfo: platformInfo,
      # account: userMail
      mainModule: contentList["mainModule"]
      classify: "",
      version: contentList["version"],
      describe: contentList["description"],
      modules: contentList["modules"]
      releaseNote: contentList["releaseNote"]
    bodyStr = JSON.stringify(bodyJSON)
    params =
      body: bodyStr
      sendCookie: true
      success: (data) =>
        # console.log JSON.stringify(data)
        if data["status"] is "success"
          @buildTips.html("正在排队构建请耐心等待......")
          # if data["IOS"]
          #在这里需要不断的查构建结果
          showObject = (obj) =>
            if obj.status != 'success'
              console.log "上传#{obj.platform}不成功！"
            else
              console.log "上传#{obj.platform}成功！"
              @buildPlatformId[obj.platform] = obj.id
              @checkBuildResult obj.id,obj.platform,0
          if data['data'].length > 0
            showObject obj for obj in data['data']
      error: =>
        console.log "error"
    client.buildApp(params)
    # console.log params

  checkBuildResult: (id,platform,time) ->
    # console.log id,platform,time
    # ticket = (timeTips,loopTime,waitTime) =>
    #   console.log timeTips,loopTime
    #   if loopTime <= 1
    #     return
    #   loopTime = loopTime - 1
    #   num = waitTime - 1
    #   @.find(timeTips).html(num)
    #   # console.log timeTips,num,@.find(timeTips).html(num),waitTime
    #   setTimeout =>
    #     ticket timeTips,loopTime,num
    #   ,1000
      # @.find(timeTips).html(num-1)
    params =
      sendCookie: true
      success: (data) =>
        # data['status'] = "SUCCESS"
        # data['url'] = "http://baidu.com"
        console.log data
        if data['code'] == -1
          alert "#{platform}构建不存在！"
          return
        if data['status'] == "WAITING"
          # setTimeout("checkBuildResult(#{id},#{platform})", 1000*60)
          if platform == "IOS"
            timeTips = ".iosWaitTime"
            if data['waitingTime'] == 0
              @.find(".iosTips").html("IOS 准备开始构建")
            else
              @.find(".iosTips").html("IOS 还需等待构建<span class='iosWaitTime'>#{data['waitingTime']}</span>秒")
          else
            timeTips = ".androidWaitTime"
            if data['waitingTime'] == 0
              @.find(".androidTips").html("ANDOIRD 准备开始构建")
            else
              @.find(".androidTips").html("ANDOIRD 还需等待构建<span class='androidWaitTime'>#{data['waitingTime']}</span>秒")
          loopTime = 25 # 调服务器时间 的时间间隔
          loopTime2 = 25  # 倒计时循环次数
          if data['waitingTime'] < 25
            loopTime = data['waitingTime']
            loopTime2 = data['waitingTime']
            if data['waitingTime'] == 0
              loopTime = loopTime + 2
          @checkBuildResultTimer[platform] = setTimeout =>
            @checkBuildResult id,platform,time+1
          ,1000*loopTime
          @ticketTimer[platform] = setTimeout =>
            @ticket timeTips,loopTime2,data['waitingTime'],platform
          ,1000
        else if data['status'] == "SUCCESS"
          if !@urlCodeList.is(':visible')
            @buildingTips.addClass('hide')
            @urlCodeList.removeClass('hide')
            @parentView.nextBtn.hide()
            @parentView.prevBtn.hide()
            if @checkBuildResultTimer[platform]
              window.clearTimeout(@checkBuildResultTimer[platform])
            if @ticketTimer[platform]
              window.clearTimeout(@ticketTimer[platform])
          str = "<img src='"+ desc.getImgPath 'icon_success.png' +"'/>构建成功"
          if @.find('#ios').is(':checked')
            @ios_code_view.removeClass('hide')
          if @.find('#android').is(':checked')
            @android_code_view.removeClass('hide')
          if platform == 'IOS'
            @.find(".iosTips").html("iOS")
            @iOSCode.attr('src',"http://qr.liantu.com/api.php?text=#{data['url']}")
            @iosUrl.attr('href',data['url'])
            @iosUrl.html("app下载地址[IOS]")
            @ios_build_result_tips.html(str)
          else
            @.find(".androidTips").html("Android")
            @androidCode.attr('src',"http://qr.liantu.com/api.php?text=#{data['url']}")
            @androidUrl.attr('href',data['url'])
            @androidUrl.html("app下载地址[Android]")
            @android_build_result_tips.html(str)
        else if data['status'] == "BUILDING"
          @buildTips.html("正在构建请耐心等待......")
          if platform == "IOS"
            timeTips = ".iosWaitTime"
            @.find(".iosTips").html("IOS 正在构建<span class='iosWaitTime'>#{data['remainTime']}</span>秒")
          else
            timeTips = ".androidWaitTime"
            @.find(".androidTips").html("ANDOIRD 正在构建<span class='androidWaitTime'>#{data['remainTime']}</span>秒")
          loopTime = 25 # 调服务器时间 的时间间隔
          loopTime2 = 25# 倒计时循环次数
          if data['remainTime'] < 25
            loopTime = data['remainTime']
            loopTime2 = data['remainTime']
          @checkBuildResultTimer[platform] = setTimeout =>
            @checkBuildResult id,platform,time+1
          ,1000*loopTime
          @ticketTimer[platform] = setTimeout =>
            @ticket timeTips,loopTime2,data['remainTime'],platform
          ,1000
        else
          if @checkBuildResultTimer[platform]
            window.clearTimeout(@checkBuildResultTimer[platform])
          if @ticketTimer[platform]
            window.clearTimeout(@ticketTimer[platform])
          if @.find('#ios').is(':checked')
            @ios_code_view.removeClass('hide')
          else
            console.log "ios is hide"
          if @.find('#android').is(':checked')
            @andoird_code_view.removeClass('hide')
          else
            console.log "android is hide"
          if !@urlCodeList.is(':visible')
            @buildingTips.addClass('hide')
            @urlCodeList.removeClass('hide')
            @parentView.nextBtn.hide()
            @parentView.prevBtn.hide()
          str = "<img src='"+ desc.getImgPath 'btn_close.png' +"'/>构建失败"
          if platform == 'IOS'
            @ios_build_result_tips.html(str)
          else
            @android_build_result_tips.html(str)
          # alert "#{platform}构建失败"
      error: =>
        console.log  "error"
    client.getBuildUrl(params,id)

  ticket: (timeTips,loopTime,waitTime,platform) ->
    # console.log timeTips,loopTime
    if loopTime <= 1
      return
    loopTime = loopTime - 1
    num = waitTime - 1
    @.find(timeTips).html(num)
    # console.log timeTips,num,@.find(timeTips).html(num),waitTime
    @ticketTimer[platform] = setTimeout =>
      @ticket timeTips,loopTime,num,platform
    ,1000

  prevBtnClick: ->
    if @main.is(':visible')
      @main.addClass('hide')
      @selectApp.removeClass('hide')
      @parentView.prevBtn.hide()
    else if @buildMessage.is(':visible')
      @buildMessage.addClass('hide')
      @main.removeClass('hide')
    else if @buildingTips.is(':visible')
      @buildingTips.addClass('hide')
      @buildMessage.removeClass('hide')
      @parentView.prevBtn.text('上一步')
      @parentView.nextBtn.show()
      console.log "kill timer"
      if @checkBuildResultTimer["IOS"]
        window.clearTimeout(@checkBuildResultTimer["IOS"])
      if @checkBuildResultTimer["ANDROID"]
        window.clearTimeout(@checkBuildResultTimer["ANDROID"])
      if @ticketTimer["ANDROID"]
        window.clearTimeout(@ticketTimer["ANDROID"])
      if @ticketTimer["IOS"]
        window.clearTimeout(@ticketTimer["IOS"])
      #检测是否需要取消之前的构建

module.exports =
  class BuildProjectView extends ChameleonBox
    options :
      title: desc.buildProjectMainTitle
      subview: new BuildProjectInfoView()
