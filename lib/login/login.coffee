{$} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
LoginView = require './login-view'
Settings = require '../settings/settings'

module.exports = Login =
  loginView: null
  modalPanel: null

  activate: (state) ->
    @settings = Settings
    @loginView = new LoginView()
    _thisLoginView = @loginView
    #登录按钮 需要 调用接口
    @loginView.on 'click', 'button[name=loginBtn]', =>
      console.log "E-mail: #{_thisLoginView.loginEmail.getText()}"
      console.log "password: #{_thisLoginView.find('#loginPassword').text()}"
      alert "登录成功"
      atom.workspace.getActivePane().destroy()
      @settings.activate()
      @closeView

    # 密码框 输入时加密处理
    @loginView.on 'keydown', @loginView.loginPassword, ->
      inputKeyCode = event.keyCode
      if inputKeyCode != 13
        inputStr = "#{_thisLoginView.loginPassword.getText()}"
        str = _thisLoginView.find('#loginPassword').text()
        #当输入长度小于 实际保存密码的长度时需要截取实际保存长度的子串
        if inputStr.length>=0 && inputStr.length <= str.length
          console.log "length : #{str.length}"
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

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!'
      @modalPanel.show()
      @loginView.show()

  closeView: ->
    if @loginView.isVisible()
      @loginView.hide()
      @modalPanel.hide()
