#!/bin/sh

# Read in the file of environment settings
. $HOME/.bashrc
# Then run the CMD
echo "buildops"
exec "$@"
