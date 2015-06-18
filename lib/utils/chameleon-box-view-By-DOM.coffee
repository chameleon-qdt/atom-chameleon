{$, Emitter} = require 'atom'
desc = require './text-description'

module.exports =
class ChameleonBoxView

  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('chameleon')

    # Create title element
    title = @title = document.createElement('h1')
    title.textContent = desc.headtitle
    title.classList.add('box-title')
    @element.appendChild(title)


    @closeBtn = document.createElement('span')
    @closeBtn.classList.add('glyphicon')
    @closeBtn.classList.add('glyphicon-remove')
    @closeBtn.classList.add('close-view')
    @element.appendChild(@closeBtn)
    # <span click="destroy" class="glyphicon glyphicon-remove close-view"></span>

    @content = document.createElement('div')
    @content.classList.add('box')
    @element.appendChild(@content)

    btnGroup = document.createElement('div')
    btnGroup.classList.add('clearfix')

    @cancelBtn = document.createElement('button')
    $(@cancelBtn).addClass 'btn cancel pull-left'
    @cancelBtn.innerText = desc.cancel
    btnGroup.appendChild(@cancelBtn)

    @nextBtn = document.createElement('button')
    $(@nextBtn).addClass 'btn next pull-right'
    @nextBtn.innerText = desc.next
    btnGroup.appendChild(@nextBtn)

    @prevBtn = document.createElement('button')
    $(@prevBtn).addClass 'btn prev pull-right'
    @prevBtn.innerText = desc.prev
    btnGroup.appendChild(@prevBtn)



    @element.appendChild(btnGroup)

  setTitle: (title)->
    @title.textContent = title

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  getElement: ->

  attached: ->
