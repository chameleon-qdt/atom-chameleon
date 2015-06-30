{$, View} = require 'atom-space-pen-views'

Util = require '../utils/util'

module.exports =
class AccountPanel extends View
  @content: ->
    @div outlet: 'accountMessage'

  initialize: () =>
  	account = Util.store('chameleon')
  	console.log account
  	console.log @accountMessage
  	# if account.lenght is 0
  	# @accountMessage.html "<p>没有账号信息，请先登陆</p>"
  	