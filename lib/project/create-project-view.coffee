# CmdView = require '../utils/cmd-view'
desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
syncProjectView = require './sync-project-view'
newProjectView = require './new-project-view'

module.exports =
class CreateProjectView extends View

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
          @subview 'sync-project', new syncProjectView()
          @subview 'new-project', new newProjectView()

  getElement: ->
    @element

  newProject: ->
    console.log @parentView

  syncProject: ->

    # 先检测是否登录
    #
    ##############
    @main.addClass('hide');
    @second.removeClass('hide').find('.sync-project').removeClass('hide')
    @parentView.prevBtn.text(desc.back).addClass('back').removeClass('hide');
    @parentView.nextBtn.text(desc.finish).addClass('finish').removeClass('hide');

  prevStep: ->
    prevBtn = @parentView.prevBtn
    nextBtn = @parentView.nextBtn

    if prevBtn.hasClass 'back'
      @second.addClass('hide')
      @main.removeClass('hide')
      prevBtn.addClass('hide')
      nextBtn.addClass('hide')
    else
    # currStep = $('.step.active');
    # prevStep = $('[dataStep='+( currStep.attr('dataStep') - 1)+']')
    # currStep.removeClass 'active'
    # prevStep.addClass 'active'

  nextStep: ->
    nextBtn = @parentView.nextBtn
    # currStep = $('.step.active');
    if nextBtn.hasClass 'finish'
      console.log 'finish'
    else
      console.log @
