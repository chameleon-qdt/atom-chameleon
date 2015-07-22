desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
Settings = require '../settings/settings'
Util = require '../utils/util'
client = require '../utils/client'
loadingMask = require '../utils/loadingMask'

syncInfoView = require './sync-project-info'

module.exports =
class SyncProjectView extends View
  LoadingMask: loadingMask
  @content: ->
    @div class: 'sync-project container', =>
      @div class: 'row', =>
        @div class: 'col-md-12', =>
          @h2 '导入项目'
          @ul class: 'projectList', outlet: 'projectList'

  pageSize: 10
  page: 1
  account_id: ''

  getElement: ->
    @element

  attached: ->
    @settings = Settings
    @parentView.disableNext()

    if !Util.isLogin()
      @settings.activate()
      @parentView.closeView()
      alert '请先登录'
    else
      LoadingMask = new @LoadingMask()
      @parentView.setNextBtn();
      @parentView.setPrevBtn('back');
      @account_id = Util.store('chameleon').mail
      params = 
        qs:
          account: @account_id
          pageSize: @pageSize
          page: @page
        sendCookie: true
        success: (data) =>
          dataLength = data.length
          if dataLength > 0
            data.forEach (item)=>
              console.log item
              projectItem = new ProjectItem(item)
              @projectList.append projectItem
            $('.sync-item').on 'click', (e) => @onItemClick(e)
          else
            projectItem = new notProjectItem()
            @projectList.append projectItem
          @.children(".loading-mask").remove()
        error: (err) =>
          console.log err
          @.children(".loading-mask").remove()

      @.append(LoadingMask)
      client.getUserProjects params

  nextStep: (box)=>
    projectId = $('.select').attr('projectId')
    nextStepView = new syncInfoView(projectId)
    box.setPrevStep @
    box.mergeOptions {subview:nextStepView, projectId: projectId, account_id: @account_id}
    box.nextStep()
    @projectList.html('')

  onItemClick: (e) ->
    el = e.currentTarget
    $('.sync-item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()
    

class ProjectItem extends View
  @content: (data) ->
    @li class: 'sync-item inline-block new-item text-center',projectId: data.identifier, =>
      @img class: 'pic', src: desc.iconPath
      @h3 data.name, class: 'project-name'

class notProjectItem extends View
  @content: ->
    @li class: 'sync-item inline-block new-item text-center',  =>
      @div class: 'add-icon icon icon-octoface'
      @h3 '暂无项目', class: 'project-name'