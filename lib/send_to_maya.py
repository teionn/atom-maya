import socket
import sys
import textwrap
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-f", "--file", dest="file", help="The file")
parser.add_option("-a", "--host", dest="host", help="The host for the connection to Maya")
parser.add_option("-p", "--port", dest="port", help="The port for the connection to Maya")

(options, args) = parser.parse_args()

def SendToMaya(options):

    PY_CMD_TEMPLATE = textwrap.dedent('''
        import traceback
        import __main__

        namespace = __main__.__dict__.get('_atom_maya_plugin_SendToMaya')
        if not namespace:
            namespace = __main__.__dict__.copy()
            __main__.__dict__['_atom_maya_plugin_SendToMaya'] = namespace

        namespace['__file__'] = {2!r}

        try:
            {0}({1!r}, namespace, namespace)
        except:
            traceback.print_exc()
	''')

    command_tpl = PY_CMD_TEMPLATE.format('execfile', options.file, options.file)

    ADDR = (options.host,int(options.port))

    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(ADDR)

    client.send(command_tpl)
    data = client.recv(1024)

    client.close()

if __name__=='__main__':
    if options.file:
        SendToMaya(options)
    else:
        sys.exit("No command given")
