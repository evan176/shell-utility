#!/bin/bash
# Copyright (c) 2016 Evan Gui
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice,this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived from
#       this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
readonly PARENT_NAME="$(basename $0)"
readonly SCRIPT_LOG="${PARENT_NAME}.log"


##############################################################################
# Lock script to avoid cronjob conflict
# Globals:
#   None
# Arguments:
#   $1: locker name
# Returns:
#   None
##############################################################################
function lock_it() {
  if [ "$#" -gt 0 ]; then
    lock_flag="${1}.lock"
  else
    lock_flag="${PARENT_NAME}.lock"
  fi
  if mkdir "$lock_flag" 2>/dev/null; then
    echo "Successfully lock: $lock_flag"
    return 0
  else
    echo "Previous process exists! can't acquire lock!" 1>&2
    exit 1
  fi
}


function unlock_it() {
  if [ "$#" -gt 0 ]; then
    lock_flag="${1}.lock"
  else
    lock_flag="${PARENT_NAME}.lock"
  fi
  if rm -r "$lock_flag" 2>/dev/null; then
    echo "Successfully release locker: $lock_flag"
    return 0
  else
    echo "Can't release locker!!!" 1>&2
    exit 1
  fi
}


##############################################################################
# Control command flow while scripts are dependent
# Globals:
#   None
# Arguments:
#   $1: command line
#   $2: flow controller (1: Continue following job even current job is failed)
#   $3: previous status code(Optional)
# Returns:
#   execute status
##############################################################################
function wfc {
  # Get status
  pre_status="$?"
  if [ "$#" -eq 3 ]; then
    pre_status="$3"
  fi
  # Initial tmp file
  msg_tmp="${PARENT_NAME}.msg"
  error_tmp="${PARENT_NAME}.error"
  if [ "$pre_status" -eq 0 ]; then
    # Redirect stdout & stderr to tmp file
    eval "$1" 1>>"$msg_tmp" 2>>"$error_tmp"
    status="$?"
    # rm "$msg_tmp" "$error_tmp"
    # Ignore error
    if [ "$#" -gt 1 ];then
      if [ "$2" -eq 1 ]; then
        return 0
      fi
    fi
    return "$status"
  else
    return "$pre_status"
  fi
}
