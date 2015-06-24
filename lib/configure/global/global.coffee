{$,Emitter} = require 'atom-space-pen-views'
GlobalView = require './global-view'
ChameleonBox = require './../../utils/chameleon-box-view'

module.exports = configureGlobal =
  globalView : null
  modalPanel : null

  activate:(state) ->

    opt =
      title : '全局配置'
      subview : new GlobalView()
      hideNextBtn : true
      hidePrevBtn : true

    @chameleonBox = new ChameleonBox(opt)
    @chameleonBox.cancelBtn.hide()
    @chameleonBox.modalPanel = @modalPanel = atom.workspace.addModalPanel(item: @chameleonBox, isVisible: false)
    @chameleonBox.move()
    @chameleonBox.onCloseClick = =>@closeView()

    _thisLoginView = opt.subview
    #登录按钮 需要 调用接口
    opt.subview.on 'click', 'button[name=loginBtn]', ->
      console.log "E-mail: #{_thisLoginView.loginEmail.getText()}"
      console.log "password: #{_thisLoginView.find('#loginPassword').text()}"
      alert "登录成功"
    # 密码框 输入时加密处理
    opt.subview.on 'keydown', opt.subview.loginPassword, ->
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
    opt.subview.on 'keyup', opt.subview.loginPassword, ->
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

    opt.subview.onCancelClick = => @closeView()

  closeView: ->
    if @modalPanel.isVisible
      @modalPanel.hide()

  deactivate: ->
    @modalPanel.destroy()
    @chameleonBox.destroy()

  serialize: ->
    chameleonBoxState: @chameleonBox.serialize()

  openView: ->
    unless @modalPanel.isVisible()
      @modalPanel.show()
