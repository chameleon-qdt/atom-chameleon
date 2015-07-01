{$, View} = require 'atom-space-pen-views'
LoginView = require '../login/login'

Util = require '../utils/util'

module.exports =

class AccountPanel extends View
  @content: ->
    @div =>
      @div class: 'accountMessage' ,outlet: 'accountMessage'

  initialize: () =>
    account = Util.store('chameleon')
    console.log account
    shownSection = if account.length is 0 then new notFoundAccount else new hadAccount
    @accountMessage.html shownSection

class notFoundAccount extends View
  @content: ->
    @div =>
      @h3 '没有账号信息，请先登陆'
      @button '登陆', class: 'btn', click: 'login'
      @button '注册', class: 'btn', click: 'signin'

  login: ->
    @LoginView = LoginView
    console.log @LoginView
    @LoginView.activate()
    @LoginView.openView()

  signin: ->
    console.log 'signin'

  initialize: ->
    console.log 'hi'

class hadAccount extends View
  @content: ->
    @div =>
      @h3 '你好'
      @button '退出', class: 'btn', click: 'logout'

  logout: ->
    console.log 'logout'