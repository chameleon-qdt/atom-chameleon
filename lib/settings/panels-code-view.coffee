{$, View} = require 'atom-space-pen-views'

pathM = require 'path'
util = require '../utils/util'
desc = require '../utils/text-description'

addNewFramework = require './addNewFramework'

module.exports =
class CodePanel extends View
  @content: ->
    @div class: 'code-view', =>
      @div class: 'frameworkList', =>
        @header class: 'code-panel-header', =>
          @h2 '框架', =>
            @span class: 'icon icon-repo'
          @button class: 'btn icon icon-plus addNewCode',click: 'addNewCode', '添加'
        @ul outlet: 'codePackList'
      @div class: 'tempList', =>
        @header class: 'code-panel-header', =>
          @h2 '模板', =>
            @span class: 'icon icon-file-code'
          @button class: 'btn icon icon-plus addNewCode', '添加'
        @ul =>
          @li class: 'codePack-card', =>
            @h2 =>
              @a '新闻模板', href: 'http://www.baidu.com'
            @p 'version: 1.0.0'
            @p 'butterfly.js grunt product'
            @div class: 'btn-group', =>
              @button class: 'btn icon icon-cloud-download inline-block', '更新'
              @button class: 'btn icon icon-trashcan inline-block', '删除'
          @li class: 'codePack-card', =>
            @h2 =>
              @a '新闻模板', href: 'http://www.baidu.com'
            @p 'version: 1.0.0'
            @p 'butterfly.js grunt product'
            @div class: 'btn-group', =>
              @button class: 'btn icon icon-cloud-download inline-block', '更新'
              @button class: 'btn icon icon-trashcan inline-block', '删除'
          @li class: 'codePack-card', =>
            @h2 =>
              @a '新闻模板', href: 'http://www.baidu.com'
            @p 'version: 1.0.0'
            @p 'butterfly.js grunt product'
            @div class: 'btn-group', =>
              @button class: 'btn icon icon-cloud-download inline-block', '更新'
              @button class: 'btn icon icon-trashcan inline-block', '删除'

  initialize: -> 
    repoDir =  pathM.join desc.chameleonHome,'src','frameworks'
    util.readDir repoDir, (err, files) =>
      console.log files
      if files.length > 0
        files.forEach (file) =>
          packageDir = pathM.join repoDir,file,'package.json'
          util.isFileExist packageDir, (exists) =>
            if exists
              util.readJson packageDir, (err, packageObj) =>
                @renderCodePackList packageObj, file
      else
        @codePackList.html '<li class="nothing">没有找到任何框架</li>'

  renderCodePackList: (packageObj, fileName) =>
    codeListTemp = new CodeListTemp(packageObj, fileName)
    @codePackList.append(codeListTemp)

  addNewCode: ->
    console.log 'hi'
    addNewFramework.activate();
    addNewFramework.openView();


class CodeListTemp extends View
  @content: (data, fileName) ->
    @li class: "codePack-card #{data.name}", =>
      @h2 =>
        @a data.name, href: data.repository
      @p "version: #{data.version}"
      @p data.description
      @div class: 'btn-group', =>
        @button class: 'btn icon icon-cloud-download inline-block', '更新'
        @button class: 'btn icon icon-trashcan inline-block', click: 'deleteCodePack', filename: fileName, '删除'

  deleteCodePack: (event, element) ->
    fileDir = pathM.join desc.chameleonHome,'src','frameworks',element.attr('filename')
    console.log fileDir
    util.delete fileDir, (err) =>
      if err
       console.error err
      else
       $('.' + element.attr('filename')).remove()
