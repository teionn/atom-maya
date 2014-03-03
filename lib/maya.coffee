sys  = require 'sys'
exec = require('child_process').exec
StatusView = require './status-view'

module.exports =

    activate: (state) ->

        # Set defaults
        atom.config.setDefaults("maya", host: '127.0.0.1', port: 7005)

        @statusView = new StatusView(state.testViewState)

        # Listen for run command
        atom.workspaceView.command "maya:run", => @run()


    deactivate: ->
        @statusView.destroy()

    serialize: ->

    run: ->

        # Get the active pane file path
        file = atom.workspaceView.getActivePaneItem().getPath()

        HOST = atom.config.get('maya').host
        PORT = atom.config.get('maya').port

        cmd  = "python #{__dirname}/send_to_maya.py"
        cmd += " -f #{file}"
        cmd += " -a '#{HOST}'" #h results in a conflict?
        cmd += " -p #{PORT}"

        date = new Date()

        @updateStatusView "Executing file: #{file}"

        exec cmd, (error, stdout, stderr) =>

            # console.log 'stdout', stdout
            # console.log 'stderr', stderr

            ellapsed = (Date.now() - date) / 1000

            if error?
                @updateStatusView "Error: #{stderr}"
                console.error 'error', error
            else
                @updateStatusView "Success: Ran in #{ellapsed}s"


            atom.workspaceView.trigger 'maya:hide'



    updateStatusView: (text) ->
        @statusView.update "[atom-maya] #{text}"
