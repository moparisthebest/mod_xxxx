#!/bin/sh
set -e
squish
echo -e 'config:reload()\nmodule:reload("ircd", "burtrum.org")' | telnet localhost 5582

exit

echo -e 'module:load("ircd", "burtrum.org")' | telnet localhost 5582