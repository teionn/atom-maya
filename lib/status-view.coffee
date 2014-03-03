{View} = require 'atom'

module.exports = class StatusView extends View

    @content: ->
        @div class: 'maya overlay from-top', =>
            @div "", class: "message"

    initialize: (serializeState) ->
        atom.workspaceView.command "maya:run", => @show()
        atom.workspaceView.command "maya:show", => @show()
        atom.workspaceView.command "maya:hide", => @hide()

    serialize: ->

    destroy: ->
        @detach()

    update: (text) ->
        # Update the message
        @[0].firstChild.innerHTML = text

    show: ->
        if not @hasParent()
            atom.workspaceView.append(this)


    hide: =>

        callback = =>
            @detach() if @hasParent()

        setTimeout( callback, 2500 )
