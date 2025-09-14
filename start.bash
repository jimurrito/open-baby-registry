#!/bin/bash

OTP_APP=$1

if [[ -z $OTP_APP ]]; then
    echo "Please provide the name of the OTP application."
    echo "Ex: use 'app' and not ':app'"
    exit 1
fi

export SECRET_KEY_BASE="$(mix phx.gen.secret)"

# IEX
_build/prod/rel/"$OTP_APP"/bin/"$OTP_APP" start_iex

# non-interactive
#_build/prod/rel/"$OTP_APP"/bin/"$OTP_APP" start


