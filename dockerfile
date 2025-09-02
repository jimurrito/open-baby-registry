FROM elixir:1.18.4-otp-28
#
#

#
# OPTIONAL RUNTIME/BUILD ARGUMENTS HERE
#

#
ENV OTP_APP="obr"
ENV MIX_ENV=prod
#
#
RUN apt update && apt upgrade -y
# inotify-tools is required for Erlang OTP
RUN apt install inotify-tools -y
#
# Import files
# local (.) -> /app in docker
ADD ./ /app/
RUN mkdir /db
#
WORKDIR /app
#
RUN mix deps.get 
RUN mix compile
RUN mix assets.setup
RUN mix assets.deploy
RUN mix phx.digest
RUN mix phx.gen.release
RUN mix release
#
EXPOSE 4000
#
CMD ["bash", "start.bash", "$OTP_APP"]
