{$} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
LoginView = require './login-view'
Settings = require '../settings/settings'

util = require '../utils/util'

client = require '../utils/client'

module.exports = Login =
  loginView: null
  modalPanel: null
  password: ''


  activate: (state) ->
    @settings = Settings
    @loginView = new LoginView()
    _thisLoginView = @loginView


    # @loginView.loginPassword.model.emitter.on 'did-change', () =>
    #   coverText = ''
    #   inputPassword = @loginView.loginPassword.getText()
    #   # console.log @loginView.loginPassword
    #   passwordLength = inputPassword.length
    #   if inputPassword.charAt(passwordLength-1) isnt '*'
    #     console.log @password.length < passwordLength
    #     if @password.length < passwordLength
    #       @password += inputPassword.charAt(passwordLength-1)
    #       for str in @password
    #         do (str) =>
    #           coverText = coverText + '*'
    #           setTimeout =>
    #             @loginView.loginPassword.setText(coverText)
    #           , 300

    #       console.log @password
    #     else
    #       @password = @password.slice(passwordLength-1)
    #       console.log @password
    #       for str in @password
    #         do (str) =>
    #           coverText = coverText + '*'
    #           setTimeout =>
    #             @loginView.loginPassword.setText(coverText)
    #           , 300
    #   else
    #     @password = @password.slice(passwordLength-1)
    #     console.log @password
    #登录按钮 需要 调用接口
    @loginView.on 'click', 'button[name=loginBtn]', =>
      mail = $.trim(_thisLoginView.loginEmail.getText())
      password = _thisLoginView.find('#loginPassword').text()
      params =
        form: {
          mail: mail,
          password: password
        }
        cb: (err,httpResponse,body) =>
<<<<<<< HEAD
          if !err && httpResponse.statusCode is 200
=======
          console.log httpResponse.headers['set-cookie']
          if !err && httpResponse.statusCode is 200 
>>>>>>> 0c4b09e244c6141baa988329937b76e43ab8e65a
            data = JSON.parse(body)
            console.log data
            switch data.flag
              when '0'
                alert "登录失败：邮箱或密码不正确"
              when '1'
                util.store('chameleon', data)
                util.store('chameleon-cookie', httpResponse.headers['set-cookie'][0])
                alert "登录成功"
                @closeView()
                atom.workspace.getPanes()[0].destroyActiveItem()
                @settings.activate()
              when '2'
                alert "登录失败：用户未激活"
              when '4'
                alert "登录失败：用户被禁用"
              when '5'
                alert "邮箱或密码不正确"
          else
            alert "登录接口调不通"

      if mail is '' and password is ''
        alert "邮箱或密码不能为空"
      else
        client.login(params)


    # 密码框 输入时加密处理
    @loginView.on 'keydown', @loginView.loginPassword, ->
      inputKeyCode = event.keyCode
      if inputKeyCode != 13
        inputStr = "#{_thisLoginView.loginPassword.getText()}"
        str = _thisLoginView.find('#loginPassword').text()
        #当输入长度小于 实际保存密码的长度时需要截取实际保存长度的子串
        if inputStr.length>=0 && inputStr.length <= str.length
          str = str.substring(0,inputStr.length)
          _thisLoginView.find('#loginPassword').text(str)
          console.log "length : #{str.length}"
        else
          #获取最新输入的字符()
          _thisLoginView.find('#loginPassword').text(str+inputStr.charAt(inputStr.length - 1))
        # body...
    @loginView.on 'keyup', @loginView.loginPassword, ->
      strOuput = ''
      inputKeyCode = event.keyCode
      if inputKeyCode != 13
        inputStr = _thisLoginView.loginPassword.getText()
        str = _thisLoginView.find('#loginPassword').text()
        #当输入长度小于 实际保存密码的长度时需要截取实际保存长度的子串
        if inputStr.length>=0 && inputStr.length <= str.length
          str = str.substring(0,inputStr.length)
          _thisLoginView.find('#loginPassword').text(str)
        else
          #获取最新输入的字符
          _thisLoginView.find('#loginPassword').text(str+inputStr.charAt(inputStr.length - 1))
      for str in inputStr
        do (str) ->
          strOuput = strOuput + '*'
      _thisLoginView.loginPassword.setText(strOuput)
    # 密码框处理结束
    @loginView.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @loginView, visible: false)
    @loginView.move()
    @loginView.onCancelClick = => @closeView()


  deactivate: ->
    @modalPanel.destroy()
    @loginView.destroy()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!'
      @modalPanel.show()
      @loginView.show()

  closeView: ->
    if @loginView.isVisible()
      @loginView.hide()
      @modalPanel.hide()
