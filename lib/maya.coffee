sys  = require 'sys'
exec = require('child_process').exec

module.exports =

    activate: (state) ->

        # Set defaults
        atom.config.setDefaults("maya", host: '127.0.0.1', port: 7005)

        # Listen for run command
        atom.workspaceView.command "maya:run", @run

    deactivate: ->

    serialize: ->

    run: =>

        # Get the active pane file path
        file = atom.workspaceView.getActivePaneItem().getPath()

        HOST = atom.config.get('maya').host
        PORT = atom.config.get('maya').port

        cmd  = "python #{__dirname}/send_to_maya.py"
        cmd += " -f #{file}"
        cmd += " -a '#{HOST}'" #h results in a conflict?
        cmd += " -p #{PORT}"

        # console.log cmd

        exec cmd, (error, stdout, stderr) ->

            # console.log 'stdout', stdout
            # console.log 'stderr', stderr

            if error?
                console.error 'error', error
