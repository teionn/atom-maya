fs   = require 'fs'
path = require 'path'
sys  = require 'sys'
exec = require('child_process').exec
StatusView = require './status-view'
temp = require 'temp'

module.exports =

    activate: (state) ->

        # Set defaults
        atom.config.setDefaults("maya", host: '127.0.0.1', port: 7005)

        # Create the status view
        @statusView = new StatusView(state.testViewState)

        # Listen for run command
        atom.workspaceView.command "maya:run", => @run()

        # Automatically track and cleanup files at exit
        temp.track()


    deactivate: ->
        @statusView.destroy()

    serialize: ->

    run: ->

        # Get the current selection
        selection = atom.workspaceView.getActivePaneItem().getSelectedText()

        if selection.length > 0
            # Create a tmp file and save the selection
            @get_tmp_file_for_selection selection, (file) =>
                @send_to_maya file
        else
            # Get the active pane file path
            file = atom.workspaceView.getActivePaneItem().getPath()
            @send_to_maya file

        return

    send_to_maya: (file) ->

        if not file.match '.py'
            @updateStatusView "Error: Not a python file"
            atom.workspaceView.trigger 'maya:show'
            atom.workspaceView.trigger 'maya:hide'
            return

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

            # Cleanup any tmp files created
            temp.cleanup()

            atom.workspaceView.trigger 'maya:hide'


    updateStatusView: (text) ->
        @statusView.update "[atom-maya] #{text}"


    get_tmp_file_for_selection: (selection, callback) ->

        temp.mkdir 'atom-maya-selection', (err, dirPath) ->

            inputPath = path.join dirPath, 'command.py'

            fs.writeFile inputPath, selection, (err) ->

                if err?
                    throw err
                else
                    callback inputPath
