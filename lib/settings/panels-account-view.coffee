{$, View} = require 'atom-space-pen-views'
LoginView = require '../login/login'

config = require '../../config/config'

Util = require '../utils/util'

module.exports =

class AccountPanel extends View
  @content: ->
    @div =>
      @div class: 'accountMessage' ,outlet: 'accountMessage'

  initialize: () =>
    account = Util.store('chameleon').uname
    shownSection = if account? then new hadAccount(account) else new notFoundAccount()
    @accountMessage.html shownSection
    shownSection = null

class notFoundAccount extends View
  @content: ->
    @div =>
      @h3 '没有账号信息，请先登陆'
      @button '登陆', class: 'btn', click: 'login'
      @a '注册', class: 'btn', href: config.registerUrl

  login: ->
    @LoginView = LoginView
    @LoginView.activate()
    @LoginView.openView()

class hadAccount extends View
  @content: (account) ->
    @div =>
      @h3 "你好, #{account}"
      @button '退出', class: 'btn', click: 'logout'

  logout: ->
    Util.removeStore('chameleon')
    $('.accountMessage').html(new notFoundAccount)