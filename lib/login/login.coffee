{$} = require 'atom-space-pen-views'
desc = require '../utils/text-description'
LoginView = require './login-view'
Settings = require '../settings/settings'

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
    @loginView.find('#sign').on 'click', ()=>
      # window.location.href = 'http://bsl.foreveross.com/qdt-web/html/account/login.html'
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
        password: password
      }
      success: (data, cookie) =>
        console.log data
        switch data.flag
          when '0'
            alert "登录失败：邮箱或密码不正确"
          when '1' or '3'
            util.store('chameleon', data)
            util.store('chameleon-cookie', cookie)
            @closeView()
            atom.workspace.getPanes()[0].destroyActiveItem()
            @settings.activate()
          when '2'
            alert "登录失败：用户未激活"
          when '4'
            alert "登录失败：用户被禁用"
          when '5'
            alert "邮箱或密码不正确"
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
