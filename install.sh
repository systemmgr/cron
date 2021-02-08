#!/usr/bin/env bash

APPNAME="cron"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author          : Jason
# @Contact         : casjaysdev@casjay.net
# @File            : install.sh
# @Created         : Fr, Aug 28, 2020, 00:00 EST
# @License         : WTFPL
# @Copyright       : Copyright (c) CasjaysDev
# @Description     : installer script for cron
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/casjay-dotfiles/scripts/raw/master/functions}"
SCRIPTSFUNCTDIR="${SCRIPTSAPPFUNCTDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-app-installer.bash}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ -f "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/functions/$SCRIPTSFUNCTFILE"
elif [ -f "$HOME/.local/share/CasjaysDev/functions/$SCRIPTSFUNCTFILE" ]; then
  . "$HOME/.local/share/CasjaysDev/functions/$SCRIPTSFUNCTFILE"
else
  curl -LSs "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
system_installdirs

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Make sure the scripts repo is installed

scripts_check

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Defaults
APPNAME="${APPNAME:-cron}"
APPDIR="/usr/local/etc/$APPNAME"
INSTDIR="${INSTDIR}"
REPO="${SYSTEMMGRREPO:-https://github.com/systemmgr}/${APPNAME}"
REPORAW="${REPORAW:-$REPO/raw}"
APPVERSION="$(__appversion "$REPORAW/master/version.txt")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# dfmgr_install fontmgr_install systemmgr_install pkmgr_install systemmgr_install thememgr_install wallpapermgr_install

systemmgr_install

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Script options IE: --help

show_optvars "$@"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Requires root - no point in continuing

sudoreq # sudo required
#sudorun  # sudo optional

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end with a space

APP="crontab fortune cowsay "

# install packages - useful for package that have the same name on all oses
install_packages $APP

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Ensure directories exist

ensure_dirs
ensure_perms

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Main progam

if [ -d "$APPDIR" ]; then
  execute "backupapp $APPDIR $APPNAME" "Backing up $APPDIR"
fi

if [ -d "$APPDIR/.git" ]; then
  execute \
    "git_update $APPDIR" \
    "Updating $APPNAME configurations"
else
  execute \
    "git_clone $REPO/$APPNAME $APPDIR" \
    "Installing $APPNAME configurations"
fi

# exit on fail
failexitcode

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# run post install scripts

run_postinst() {
  systemmgr_run_postinst
  [ ! -f /etc/casjaysdev/messages/legal.txt ] || rm_rf /etc/casjaysdev/messages/legal.txt
  [ ! -f /usr/bin/cowsay ] && [ -f /usr/games/cowsay ] && ln_sf /usr/games/cowsay /usr/bin/cowsay
  [ ! -f /usr/bin/fortune ] && [ -f /usr/games/fortune ] && ln_sf /usr/games/fortune /usr/bin/fortune

  rm_rf /etc/cron*/0*
  rm_rf /etc/cron*/anacron

  mkd /etc/casjaysdev/messages/motd
  mkd /etc/casjaysdev/messages/issue

  cp_rf "$APPDIR/." "/etc/"

  replace /etc/crontab '$(hostname -s)' "$(hostname -f)"
  replace /etc/casjaysdev/messages/ MYHOSTIP "$CURRIP4"
  replace /etc/casjaysdev/messages/ MYHOSTNAME "$(hostname -s)"
  replace /etc/casjaysdev/messages/ MYFULLHOSTNAME "$(hostname -f)"

  if [ -f "$(command -v update-motd)" ]; then
    update-motd
  else
    if [ -f "$(command -v fortune)" ] && [ -f "$(command -v cowsay)" ]; then
      printf "%s\n\n" "$(fortune | cowsay)" >/etc/motd
    fi

    messages_legal=$(ls "/etc/casjaysdev/messages/legal/" 2>/dev/null | wc -l)
    if [ "$messages_legal" != "0" ]; then
      cat /etc/casjaysdev/messages/legal/*.txt | sudo tee -a /etc/issue >>/dev/null 2>&1
    fi

    messages_issue=$(ls "/etc/casjaysdev/messages/issue/" 2>/dev/null | wc -l)
    if [ "$messages_issue" != "0" ]; then
      cat /etc/casjaysdev/messages/issue/*.txt | sudo tee -a /etc/issue >>/dev/null 2>&1
    fi

    messages_motd=$(ls "/etc/casjaysdev/messages/motd/" 2>/dev/null | wc -l)
    if [ "$messages_motd" != "0" ]; then
      cat /etc/casjaysdev/messages/motd/*.txt | sudo tee -a /etc/motd >>/dev/null 2>&1
    fi
  fi
}

execute \
  "run_postinst" \
  "Running post install scripts"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# create version file

systemmgr_install_version

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exit
run_exit

# end
