hubot-shaky: A clubot bridge to hubot. 
================================

* By Sean Bryant
* https://github.com/sbryant/hubot-shaky

Description
-----------
Shaky is an adapter for hubot that let's [clubot](https://github.com/hackinggibsons/clubot) proxy commands to hubot from IRC over 0mq.

Installtion
-----------
Shaky requires a custom version of hubot right now. 
Please use my fork of [hubot](https://github.com/sbryant/hubot)

Download hubot-shaky. 

In the hubot directory:

```bash
$ npm uninstall hubot
$ npm install /path/to/hubot-fork
$ npm install /path/to/hubot-shaky
```

Configuration
-------------
You configure shaky through environment variables.

* `HUBOT_SHAKY_SUB_ADDRESS` - The 0MQ subscription address.
* `HUBOT_SHAKY_DEALER_ADDRESS` - The 0MQ dealer address.
* `HUBOT_SHAKY_FILTERS` - A comma delimited list filters to subscribe to.

###An example configuration

```bash
$ export HUBOT_SHAKY_SUB_ADDRESS="tcp://localhost:14532"
$ export HUBOT_SHAKY_DEALER_ADDRESS="tcp://localhost:14533"
$ export HUBOT_SHAKY_FILTERS=":PRIVMSG,:PART,:JOIN,:INVITE"
```

Usage
-----
To start hubot with the shaky adpater:

```bash
$ ./bin/hubot -a shaky -w
```

Contribute
----------
Just fork the project and submit a pull request.
