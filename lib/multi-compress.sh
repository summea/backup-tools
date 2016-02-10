#!/bin/bash

# compress and split file(s)
# permissions are preserved with -p option
tar -cpzvf - $2 | split -b $3 - $1

exit $?
