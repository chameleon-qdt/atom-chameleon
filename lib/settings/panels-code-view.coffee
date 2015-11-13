{$, View} = require 'atom-space-pen-views'

pathM = require 'path'
util = require '../utils/util'
desc = require '../utils/text-description'
config = require '../../config/config'
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
          # @button class: 'btn icon icon-plus addNewCode', '添加'
        @ul outlet: 'templatesList'

  initialize: ->
    @renderCodePackList()
    @renderTemplatesList()

  renderCodePackList: =>
    repoDir =  desc.getFrameworkPath()
    util.readDir repoDir, (err, files) =>
      if files.indexOf('.gitkeep') >= 0
        files.splice(files.indexOf('.gitkeep'),1)
      if files.length > 0
        @codePackList.html ''
        files.forEach (file) =>
          packageDir = pathM.join repoDir, file, desc.moduleConfigFileName
          util.isFileExist packageDir, (exists) =>
            if exists
              util.readJson packageDir, (err, packageObj) =>
                codeListTemp = new CodeListTemp(packageObj, file)
                projectName = packageObj.name
                @codePackList.append(codeListTemp)
                codeListTemp.deleteCodePack = (event, element) =>
                  fileDir = pathM.join desc.chameleonHome,'src','frameworks',element.attr('filename')
                  if confirm("是否删除这个框架")
                    util.delete fileDir, (err) =>
                      if err
                        console.error err
                      else
                        @renderCodePackList()
                codeListTemp.updateCode = (event, element) =>
                  fileDir = pathM.join desc.chameleonHome,'src','frameworks',element.attr('filename')
                  success = (tips) =>
                    alert "更新成功"
                    @renderCodePackList()
                  error = () =>
                    alert "更新失败"
                    @renderCodePackList()

                  $('.' + projectName).find('.loading-mask').removeClass('hidden')
                  util.updateRepo(fileDir, success, error)
      else
        @codePackList.html '<li class="nothing">没有找到任何框架</li>'

  renderTemplatesList: =>
    repoDir =  pathM.join desc.chameleonHome,'src','templates'
    util.readDir repoDir, (err, files) =>
      if files.indexOf('.gitkeep') >= 0
        files.splice(files.indexOf('.gitkeep'),1)

      if files.length > 0
        @templatesList.html ''
        files.forEach (file) =>
          packageDir = pathM.join repoDir, file, desc.moduleConfigFileName
          util.isFileExist packageDir, (exists) =>
            if exists
              util.readJson packageDir, (err, packageObj) =>
                templatesListTemp = new TemplatesListTemp(packageObj, file)
                projectName = packageObj.name
                @templatesList.append(templatesListTemp)
                templatesListTemp.deleteCodePack = (event, element) =>
                  fileDir = pathM.join desc.chameleonHome,'src','templates',element.attr('filename')
                  if confirm("是否删除这个模板")
                    util.delete fileDir, (err) =>
                      if err
                        console.error err
                      else
                        @renderTemplatesList()
                templatesListTemp.updateCode = (event, element) =>
                  fileDir = pathM.join desc.chameleonHome,'src','templates',element.attr('filename')
                  success = (tips) =>
                    alert "更新成功"
                    @renderTemplatesList()
                  error = () =>
                    alert "更新失败"
                    @renderTemplatesList()

                  $('.' + projectName).find('.loading-mask').removeClass('hidden')
                  util.updateRepo(fileDir, success, error)
      else
        @templatesList.html '<li class="nothing">没有找到任何模板</li>'

  addNewCode: ->
    addNewFramework.activate();
    addNewFramework.openView();
    addNewFramework.rerenderList = => @renderCodePackList()


class CodeListTemp extends View
  @content: (data, fileName) ->
    @li class: "codePack-card #{data.name}", =>
      @h2 =>
        @a data.name, href: data.repository
      @p "version: #{data.version}"
      @p data.description
      @div class: 'btn-group', =>
        @button class: 'btn icon icon-cloud-download inline-block', click: 'updateCode', filename: fileName, '更新'
        @button class: 'btn icon icon-trashcan inline-block', click: 'deleteCodePack', filename: fileName, '删除'
      @div class: 'loading-mask hidden', =>
        @span class: "loading loading-spinner-large inline-block"

  deleteCodePack: (event, element) ->

  updateCode: (event, element) ->

class TemplatesListTemp extends View
  @content: (data, fileName) ->
    @li class: "codePack-card #{data.name}", =>
      @h2 =>
        @a data.name, href: data.repository
      @p "version: #{data.version}"
      @p data.description
      @div class: 'btn-group', =>
        @button class: 'btn icon icon-cloud-download inline-block', click: 'updateCode', fileName: fileName, '更新'
        @button class: 'btn icon icon-trashcan inline-block', click: 'deleteCodePack', filename: fileName, '删除'
      @div class: 'loading-mask hidden', =>
        @span class: "loading loading-spinner-large inline-block"

  updateCode: (event, element) ->

  deleteCodePack: (event, element) ->
