desc = require '../utils/text-description'
{$, View} = require 'atom-space-pen-views'
Settings = require '../settings/settings'
Util = require '../utils/util'
client = require '../utils/client'
loadingMask = require '../utils/loadingMask'

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
      @parentView.setNextBtn('finish');
      @parentView.setPrevBtn('back');
      account_id = Util.store('chameleon').account_id
      params = 
        qs:
          account: account_id
          pageSize: @pageSize
          page: @page
        sendCookie: true
        cb: (err,httpResponse,body) =>
          console.log httpResponse
          if !err && httpResponse.statusCode is 200 
            data = JSON.parse(body)
            dataLength = data.length
            if dataLength > 0
              data.forEach (item)=>
                projectItem = new ProjectItem(item)
                @projectList.append projectItem
              $('.sync-item').on 'click', (e) => @onItemClick(e)
            else
              projectItem = new notProjectItem()
              @projectList.append projectItem
        error: (err) =>
          console.log err

      @.append(LoadingMask)
      client.getUserProjects params

  nextStep: (box)->
    box.nextStep()

  onItemClick: (e) ->
    el = e.currentTarget
    $('.sync-item.select').removeClass 'select'
    el.classList.add 'select'
    @createType = el.dataset.type
    @parentView.enableNext()

class ProjectItem extends View
  @content: (data) ->
    @li class: 'sync-item inline-block new-item text-center',  =>
      @img class: 'pic', src: desc.iconPath
      @h3 data.name, class: 'project-name'

class notProjectItem extends View
  @content: ->
    @li class: 'sync-item inline-block new-item text-center',  =>
      @div class: 'add-icon icon icon-octoface'
      @h3 '暂无项目', class: 'project-name'