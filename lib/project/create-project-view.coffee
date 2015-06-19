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

  @content: ->
    @div class: 'create-project container', =>
      @div class: 'row',outlet: 'main', =>
        @div class: 'col-xs-6', =>
          @div class: 'item new-project text-center', click:'newProject', =>
            @img class: 'pic', src: 'atom://chameleon/images/icon.png'
            @h3 desc.newProject, class: 'title'
            @div class: 'desc', '创建一个本地应用'
        @div class: 'col-xs-6', =>
          @div class: 'item sync-project text-center', click:'syncProject', =>
            @img class: 'pic', src: 'atom://chameleon/images/icon.png'
            @h3 desc.syncProject, class: 'title'
            @div class: 'desc', '同步已登录账户中的项目到本地，未登录的用户请登录'
      @div class: 'row hide',outlet: 'second', =>
        @div class: 'col-md-12', =>
          @subview 'syncProjectView', new syncProjectView()
          @subview 'newProjectView', new newProjectView()

  attached: ->
    @prevBtn?= @parentView.prevBtn
    @nextBtn?= @parentView.nextBtn

  getElement: ->
    @element

  newProject: ->
    # console.log @parentView
    @main.addClass('hide');
    @second.find('.sync-project').addClass('hide')
    @second.removeClass('hide').find('.new-project').removeClass('hide')
    @parentView.prevBtn.text(desc.back).addClass('back').removeClass('hide');

  syncProject: ->

    # 先检测是否登录
    #
    ##############
    @main.addClass('hide');
    @second.find('.new-project').addClass('hide')
    @second.removeClass('hide').find('.sync-project').removeClass('hide')
    @parentView.prevBtn.text(desc.back).addClass('back').removeClass('hide');
    @parentView.nextBtn.text(desc.finish).addClass('finish').removeClass('hide');

  createProject: ->
    info = @newProjectView.getProjectInfo()
    # dir =
    nDir = new Directory(info.appPath);
    # if nDir.existsSync() isnt true
    #   console.log nDir.create()
    # else
    #   alert '文件夹已存在'
    # nDir.create()
    #   .then (a,b,c) ->
    #     # nDir.create() if isExists is no
    #     console.log a,b,c

    # console.log nDir

  prevStep: ->
    if @prevBtn.hasClass 'back'
      console.log 'back'
      @second.addClass('hide')
      @main.removeClass('hide')
      @prevBtn.addClass('hide')
      @nextBtn.addClass('hide')
    else
      console.log 'prevStep'
      currStep = $('.step.active');
      prevStep = $('[data-step='+( currStep.attr('data-step') - 1)+']')
      currStep.removeClass 'active'
      prevStep.addClass 'active'

    @prevBtn.removeClass('back')
    @nextBtn.removeClass('finish')

  nextStep: ->
    if @nextBtn.hasClass 'finish'
      console.log 'finish'
      # @nextBtn.removeClass('finish')
      if($('.new-project [data-step="2"].active').length>0)
        @createProject()
    else
      console.log 'nextStep'
      currStep = $('.step.active');
      nextStep = $('[data-step='+( currStep.attr('data-step') + 1)+']')
      currStep.removeClass 'active'
      nextStep.addClass 'active'
