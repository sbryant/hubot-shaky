hubot-shaky: A clubot bridge to hubot. 
================================

* By Sean Bryant
* https://github.com/sbryant/hubot-shaky

Description
-----------
Shaky is an adapter for hubot that let's clubot proxy commands to hubot
from IRC.

Installtion
-----------
Not quite there yet.

Usage
-----
You configure shaky through environment variables.
###An example configuration

```bash
$ export HUBOT_SHAKY_SUB_ADDRESS="tcp://localhost:14532"
$ export HUBOT_SHAKY_DEALER_ADDRESS="tcp://localhost:14533"
$ export HUBOT_SHAKY_FILTERS=":PRIVMSG,:MENTION"
```

Contribute
----------
Just fork the project and submit a pull request.
