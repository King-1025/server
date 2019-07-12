#!/usr/bin/env bash

function get_pwd()
{
  local s="${BASH_SOURCE[0]}"
  local d=""
  while [ -h "$s" ]; do #resolve $SOURCE until the file is no longer a symlink
     d="$( cd -P "$( dirname "$s" )" >/dev/null && pwd )"
     s="$(readlink "$s")"
     [[ $s != /* ]] && s="$d/$s" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  d="$( cd -P "$( dirname "$s" )" >/dev/null && pwd )"
  echo $d
}

get_pwd
