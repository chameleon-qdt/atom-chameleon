{$} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
LoginView = require './login-view'
Settings = require '../settings/settings'
Config = require '../../config/config'
util = require '../utils/util'

client = require '../utils/client'

module.exports = Login =
  loginView: null
  modalPanel: null

  activate: (state) ->
    @settings = Settings
    @loginView = new LoginView()
    @loginPassword = @loginView.loginPassword

    @loginPassword.getModel().onDidChange =>
      @password = @loginPassword.getText()
      spanLine = $('#psw /deep/ div.lines')
      string = @password.split('').map(->
        '*'
      ).join ''
      spanLine.addClass('password-lines')
      spanLine.find('#password-style').remove()
      spanLine.append('<style id="password-style">.password-lines .line span.text:before {content:"' + string + '";}</style>')

    @loginView.find('#login').on 'click', ()=>
      @login()
    @loginView.find('#osclogin').on 'click', ()=>
      @closeView()
      util.rumAtomCommand('chameleon:openOschinaLogin')

    @loginView.find('#sign').on 'click', ()=>
      window.location.href = Config.registerUrl
    @loginView.on 'keydown', (event)=>
      if event.keyCode is 13
        @login()

    @loginView.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @loginView, visible: false)
    @loginView.move()
    @loginView.onCancelClick = => @closeView()


  deactivate: ->
    @modalPanel.destroy()
    @loginView.destroy()

  login: ->
    mail = $.trim(@loginView.loginEmail.getText());
    password = if @password is '' or typeof @password is 'undefined' then '' else @password
    params =
      form: {
        mail: mail,
        password: password,
        platform: 'qdt'
      }
      success: (data, cookie) =>
        console.log data
        switch data.flag
          when 'unregister'
            alert "登录失败：用户未注册"
          when 'ordinary' or 'admin'
            util.store('chameleon', data)
            util.store('chameleon-cookie', cookie)
            @closeView()
            util.getPanes().destroyItem(util.getThatPane("atom://ChameleonSettings"))
            @settings.activate()
          when 'unactivation'
            alert "登录失败：用户未激活"
          when 'forbidden'
            alert "登录失败：用户被禁用"
          when 'emailwrongful'
            alert "登录失败：邮箱不正确"
          when 'errorpassword'
            alert "登录失败：密码错误"
      error: (err) =>
        alert err

    if mail isnt '' and password isnt ''
      client.login(params)
    else
      alert "邮箱或密码不能为空"

  openView: ->
    unless @modalPanel.isVisible()
      console.log 'CreateProject was opened!'
      @modalPanel.show()
      @loginView.show()

  closeView: ->
    if @loginView.isVisible()
      @loginView.hide()
      @modalPanel.hide()
