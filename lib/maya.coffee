fs   = require 'fs'
path = require 'path'
sys  = require 'sys'
exec = require('child_process').exec
StatusView = require './status-view'
temp = require 'temp'
{CompositeDisposable} = require 'atom'

module.exports =

    modalTimeout: null

    activate: (state) ->

        # Set defaults
        atom.config.setDefaults("maya", host: '127.0.0.1', port: 7005, save_on_run: true )

        # Create the status view
        @statusView = new StatusView(state.statusViewState)
        @modalPanel = atom.workspace.addModalPanel(item: @statusView.getElement(), visible: false)

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        # Listen for run command
        @subscriptions.add atom.commands.add 'atom-workspace', 'maya:run': => @run()

        # Automatically track and cleanup files at exit
        temp.track()


    deactivate: ->
        @statusView.destroy()
        @subscriptions.dispose()

    serialize: ->

    getActiveEditor: ->
        atom.workspace.getActiveTextEditor()

    run: ->

        # Get the current selection
        editor = @getActiveEditor()

        if atom.config.get('maya').save_on_run
          editor.save()

        selection = editor.getLastSelection()

        if editor.getLastSelection().isEmpty()
            # Get the active pane file path
            @send_to_maya editor.buffer.file.path
        else
            # console.log('send selection', selection)
            # Create a tmp file and save the selection
            text = editor.getSelections()[0].getText()

            @get_tmp_file_for_selection text, (file) =>
               @send_to_maya file

        return

    send_to_maya: (file) ->

        # console.log('send to maya', file)

        if not file.match '.py'
          if not file.match '.mel'
            @updateStatusView "Error: Not a python file"
            @closeModal()
            return

        HOST = atom.config.get('maya').host
        PORT = atom.config.get('maya').port

        cmd  = "python \"#{__dirname}/send_to_maya.py\""
        cmd += " -f \"#{file}\""
        cmd += " -a '#{HOST}'" #h results in a conflict?
        cmd += " -p #{PORT}"

        date = new Date()

        @updateStatusView "Executing file: #{file}"

        exec cmd, (error, stdout, stderr) =>

            # console.log 'stdout', stdout
            # console.log 'stderr', stderr

            ellapsed = (Date.now() - date) / 1000
            # console.log 'Executing command: ', cmd
            if error?
                @updateStatusView "Error: #{stderr}"
                console.error 'error', error
            else
                @updateStatusView "Success: Ran in #{ellapsed}s"

            # Cleanup any tmp files created
            temp.cleanup()

            @closeModal()

    updateStatusView: (text) ->

        clearTimeout @modalTimeout

        @modalPanel.show()
        @statusView.update "[atom-maya] #{text}"

    closeModal: ->

      clearTimeout @modalTimeout

      @modalTimeout = setTimeout =>
        @modalPanel.hide()
      , 2000

    get_tmp_file_for_selection: (selection, callback) ->

        temp.mkdir 'atom-maya-selection', (err, dirPath) ->

            inputPath = path.join dirPath, 'command.py'

            fs.writeFile inputPath, selection, (err) ->

                if err?
                    throw err
                else
                    callback inputPath
