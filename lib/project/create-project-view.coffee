# CmdView = require '../utils/cmd-view'
{Directory,File} = require 'atom'
desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
syncProjectView = require './sync-project-view'
newProjectView = require './new-project-view'

module.exports =
class CreateProjectView extends View

  prevBtn:null
  nextBtn:null
  v:
    syncProject:syncProjectView
    newProject:newProjectView

  @content: ->
    @div class: 'create-project container', =>
      @div class: 'row',outlet: 'main', =>
        @div class: 'col-xs-6', =>
          @div class: 'item new-project text-center', 'data-type':'newProject', =>
            @img class: 'pic', src: 'atom://chameleon/images/icon.png'
            @h3 desc.newProject, class: 'title'
            @div class: 'desc', '创建一个本地应用'
        @div class: 'col-xs-6', =>
          @div class: 'item sync-project text-center', 'data-type':'syncProject', =>
            @img class: 'pic', src: 'atom://chameleon/images/icon.png'
            @h3 desc.syncProject, class: 'title'
            @div class: 'desc', '同步已登录账户中的项目到本地，未登录的用户请登录'

  attached: ->
    console.log 'c'
    @parentView.disableNext();
    @parentView.hidePrevBtn();
    $('.item.select').removeClass 'select'
    $('.item').on 'click', (e) => @onTypeItemClick(e)

  onTypeItemClick: (e) ->
    el = e.currentTarget
    $('.item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type;
    @parentView.enableNext();

  getElement: ->
    @element

  nextStep: (box)->
    nextStepView = new @v[@createType]()
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView}
    box.nextStep()

  # createProject: ->
  #   info = @newProjectView.getProjectInfo()
  #   # dir =
  #   nDir = new Directory(info.appPath);
  #   filePath = nDir.getPath()+'/'
  #   indexHtml = new File(filePath+'index.html');
  #   packageJson = new File(filePath+'package.json');
  #
  #   # if nDir.existsSync() isnt true
  #   p = nDir.create()
  #   console.log nDir.getPath()
  #   # else
  #   #   alert '文件夹已存在'
  #   console.log p
  #   p.then (success) ->
  #       # nDir.create() if isExists is no
  #       # console.log success,info
  #       if success is yes
  #         # alert '创建成功'
  #         indexHtml.create()
  #         packageJson.create();
  #       else
  #         alert '创建失败'
  #     .then (a,b,c) ->
  #       console.log a,b,c
  #
  #   # console.log nDir
