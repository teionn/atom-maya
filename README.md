# atom-maya

Run python scripts from atom to Maya.


## Installation:

1. Create a userSetup.py script (if you haven't already done so) ```/Users/<user>/Library/Preferences/Autodesk/maya/<version>/scripts/userSetup.py```

2. Add the following:

```
import maya.cmds as cmds

cmds.commandPort(name=":7005", sourceType="python")
```

The default host and port is ```127.0.0.1:7005```

If you need to change these settings you can override them in your atom configuration by adding the following:

```
...
'maya':
  'host': '<host>'
  'port': <port>
```

## Running:

1. Open up a python script and press ```ctrl-alt-r```.

## Todo:

* Add selection support

## Thanks to
[Maya Sublime](https://github.com/justinfx/MayaSublime)
