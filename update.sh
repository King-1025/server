#!/usr/bin/env bash

ROOT=.
SELF=$0
PICK_SSR=$ROOT/doubiSSR.sh
SSR_FILE=$ROOT/output-doubiSSR.txt
SUBSCRIBE=DATA
MODE="BASE64" #TEXT|BASE64
SSR_URL="https://raw.githubusercontent.com/King-1025/server/SSR/$SUBSCRIBE"

if [ $# -eq 1 ]; then
   SUBSCRIBE=$1
fi

function maybe_clean(){
  local others=($(find $ROOT -type f -print | \
                 grep -v "$ROOT/.git*" | \
                 grep -v "$ROOT/README.md" | \
                 grep -v "$PICK_SSR" | \
                 grep -v "$SELF" | \
                 grep -v "$ROOT/$SUBSCRIBE"))
  if [ ${#others[@]} -gt 0 ]; then
     for f in "${others[@]}"; do
       echo "delete $f ok!"
       rm -rf $f > /dev/null 2>&1
     done
  fi
}

function update_by_doubiSSR()
{ 
  $PICK_SSR
  if [ $? -eq 0 ]&&[ -e $SSR_FILE ]; then
    if [ "$MODE" == "TEXT" ]; then
      mv $SSR_FILE > $ROOT/$SUBSCRIBE
    else
      base64 $SSR_FILE > $ROOT/$SUBSCRIBE
    fi
    fresh
  fi
}

function update_readme()
{
  if [ $# -eq 1 ]; then
    echo -e "### SSR 提供SSR订阅服务\n---\n$1 订阅:$SSR_URL" > $ROOT/README.md
  fi
}

function fresh()
{
  local update_time=$(date "+%Y-%m-%d %H:%M:%S")
  update_readme "$update_time"
  maybe_clean
  git add .
  git commit -m "$update_time"
  git push
  echo "$update_time"
  echo "$SSR_URL"
}

update_by_doubiSSR
