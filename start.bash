#!/bin/bash

OTP_APP=$1

if [[ -z $OTP_APP ]]; then
    echo "Please provide the name of the OTP application."
    echo "Ex: use 'app' and not ':app'"
    exit 1
fi

export SECRET_KEY_BASE="$(mix phx.gen.secret)"

# IEX version
#PHX_SERVER=true _build/prod/rel/"$OTP_APP"/bin/"$OTP_APP" start_iex

# Non-interactive
#
# Only works when you add `server: true` to the config.ex endpoint config for each server.
#_build/prod/rel/"$OTP_APP"/bin/"$OTP_APP" start_iex

#
# TEMPORARY
# Issues running the above compiled binary.
mix phx.server
