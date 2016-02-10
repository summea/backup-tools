#!/bin/bash

# compress file(s)
# permissions are preserved with -p option
tar -cpzvf $*

exit $?
