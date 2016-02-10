#!/bin/bash

# expand (uncompress) file(s)
# permissions are preserved with -p option
tar -xpzvf $*

exit $?
