{$, View} = require 'atom-space-pen-views'
LoginView = require '../login/login'

config = require '../../config/config'
util = require '../utils/util'
client = require '../utils/client'
module.exports =

class AccountPanel extends View
  @content: ->
    @div =>
      @div class: 'accountMessage' ,outlet: 'accountMessage'

  initialize: () =>
    account = util.store('chameleon').uname
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
    console.log util.store('chameleon').session_id
    params = 
      form: 
        session_id: util.store('chameleon').session_id
      sendCookie: true
      success: (data) ->
        console.log data
        util.removeStore('chameleon')
        util.removeStore('chameleon-cookie')
        $('.accountMessage').html(new notFoundAccount)
      error: (err) ->
        console.log err
    client.loggout(params)