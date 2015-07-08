desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'

module.exports =
class SyncProjectView extends View

  @content: ->
    @div class: 'sync-project container', =>
      @div class: 'row', =>
        @div class: 'col-md-12', =>
          @h2 '导入项目'
          @div class: 'sync-item inline-block text-center', =>
            @img class: 'pic', src: desc.iconPath
            @h3 '测试项目',class: 'project-name'
          # @div class: 'sync-item inline-block add text-center', =>
          #   @div class: 'add-icon icon icon-plus'
          #   @h3 '新建同步项目', class: 'project-name'


  getElement: ->
    @element

  attached: ->
    # ################
    #  判断是否已登录
    # ################
    @parentView.setNextBtn('finish');
    @parentView.setPrevBtn('back');

  nextStep: (box)->
    box.nextStep()
