desc = require '../utils/text-description'
{$, View, TextEditorView} = require 'atom-space-pen-views'
loadingMask = require '../utils/loadingMask'
client = require '../utils/client'
pathM = require 'path'
desc = require '../utils/text-description'
Util = require '../utils/util'

module.exports =
class addNewFrameworkView extends View
  LoadingMask: loadingMask
  frameworksDir: pathM.join desc.chameleonHome,'src','frameworks'
  @content: ->
    @div class: 'addnewframework-view container', =>
      @h1 '添加框架'
      @div class: 'inputContianer', =>
        @label for:'gitAddress', 'Git地址:'
        @subview 'gitAddress', new TextEditorView(mini: true, placeholderText: '请输入Git地址')
        @ul class:'error-messages block', outlet: 'messagesList'
      @div class: 'btn-group', =>
        @button class: 'btn icon icon-x inline-block', click: 'onCancelClick', '取消'
        @button class: 'btn icon icon-check inline-block', disabled: true, id: 'sure', click: 'getThisRepo', '确定'

  initialize: ->
    @.gitAddress.model.emitter.on 'did-change', () =>
      @inputAddress = @.gitAddress.getText()
      if @inputAddress.length > 0 && @inputAddress.match(/\.git/i)
        @.find('#sure').removeAttr('disabled')
        @messagesList.html ''
      else
        @showErrorAddress()

  getThisRepo: =>
    LoadingMask = new @LoadingMask()
    prefixOne = @inputAddress.split('.')
    prefixOneLength = prefixOne.length
    prefixTwo = prefixOne[prefixOneLength-2].split('/')
    gitName = prefixTwo[prefixTwo.length-1]

    @.append(LoadingMask)

    console.log @inputAddress
      
    # Util.isFileExist targetFile, (exists) =>
    #   if exists
    #     alert '框架已存在'
    #     @.children(".loading-mask").remove()
    #   else
    params =
      url:  @inputAddress
      success: =>
        gitsuccess = (state, appPath) =>
          console.log state
          if state is 0
            alert '添加成功'
            @.children(".loading-mask").remove()
            @onCancelClick()
            @rerenderList()
          else
            alert '项目创建失败：git clone失败，请检查网络连接或者已存在同名框架'
            @.children(".loading-mask").remove()
        Util.getRepo @frameworksDir, @inputAddress, gitsuccess
      error: (error, state) =>
        @showErrorAddress()
        @.children(".loading-mask").remove()

    client.contentGit params


  showErrorAddress: ->
    @messagesList.html '<li>无效的Git地址</li>'
    @.find('#sure').attr('disabled', true)

  destroy: ->
    @element.remove()

  getElement: ->
    @element

  move: ->
    @element.parentElement.classList.add('down')

  onCancelClick: ->

  rerenderList: ->