{CompositeDisposable} = require 'event-kit'
require 'document-register-element'
PaneResizeHandleElement = require './pane-resize-handle-element'

class PaneAxisElement extends HTMLElement
  attachedCallback: ->
    @subscriptions ?= @subscribeToModel()
    @childAdded({child, index}) for child, index in @model.getChildren()

  detachedCallback: ->
    @subscriptions.dispose()
    @subscriptions = null
    # I have no idea what this line is supposed to do, but it makes the demo
    # crash on Safari and possibly Firefox.  So I'm removing it.  The best
    # I can figure out is that this callback gets called *too late* when it's
    # not in Chrome, and then ends up unintentionally removing the elements
    # with the text editor when it finally gets called.
    # @childRemoved({child}) for child in @model.getChildren()

  initialize: (@model, {@views}) ->
    throw new Error("Must pass a views parameter when initializing TextEditorElements") unless @views?
    @subscriptions ?= @subscribeToModel()
    @childAdded({child, index}) for child, index in @model.getChildren()

    switch @model.getOrientation()
      when 'horizontal'
        @classList.add('horizontal', 'pane-row')
      when 'vertical'
        @classList.add('vertical', 'pane-column')
    this

  subscribeToModel: ->
    subscriptions = new CompositeDisposable
    subscriptions.add @model.onDidAddChild(@childAdded.bind(this))
    subscriptions.add @model.onDidRemoveChild(@childRemoved.bind(this))
    subscriptions.add @model.onDidReplaceChild(@childReplaced.bind(this))
    subscriptions.add @model.observeFlexScale(@flexScaleChanged.bind(this))
    subscriptions

  isPaneResizeHandleElement: (element) ->
    element?.nodeName.toLowerCase() is 'atom-pane-resize-handle'

  childAdded: ({child, index}) ->
    view = @views.getView(child)
    @insertBefore(view, @children[index * 2])

    prevElement = view.previousSibling
    # if previous element is not pane resize element, then insert new resize element
    if prevElement? and not @isPaneResizeHandleElement(prevElement)
      resizeHandle = document.createElement('atom-pane-resize-handle')
      @insertBefore(resizeHandle, view)

    nextElement = view.nextSibling
    # if next element isnot resize element, then insert new resize element
    if nextElement? and not @isPaneResizeHandleElement(nextElement)
      resizeHandle = document.createElement('atom-pane-resize-handle')
      @insertBefore(resizeHandle, nextElement)

  childRemoved: ({child}) ->
    view = @views.getView(child)
    siblingView = view.previousSibling
    # make sure next sibling view is pane resize view
    if siblingView? and @isPaneResizeHandleElement(siblingView)
      siblingView.remove()
    view.remove()

  childReplaced: ({index, oldChild, newChild}) ->
    focusedElement = document.activeElement if @hasFocus()
    @childRemoved({child: oldChild, index})
    @childAdded({child: newChild, index})
    focusedElement?.focus() if document.activeElement is document.body

  flexScaleChanged: (flexScale) -> @style.flexGrow = flexScale

  hasFocus: ->
    this is document.activeElement or @contains(document.activeElement)

module.exports = PaneAxisElement = document.registerElement 'atom-pane-axis', prototype: PaneAxisElement.prototype
