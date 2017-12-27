#!/bin/sh

/etc/init.d/jeedom stop

rsync -vra --progress /usb/cache_cache/* /tmp/jeedom-cache/

/etc/init.d/jeedom start
