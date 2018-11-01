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
      make_data $SSR_FILE $ROOT/$SUBSCRIBE
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

function url_safe_base64_encode()
{
  if [ $# -eq 1 ]; then
    local str=$(echo "$1" | base64)
    str=$(echo "$str" | sed "s/ //g" | sed "s/\//_/g" | sed "s/+/-/g" | sed "s/=//g")
    echo "$str"
  fi
}

function url_safe_base64_decode()
{
  if [ $# -eq 1 ]; then
    local str=$(echo "$1" | sed "s/ //g" | sed "s/_/\//g" | sed "s/-/+/g")
    local mod=$((${#str}%4))
    if [ $mod -gt 0 ]; then
       local eq="====" 
       str="${str}${eq:$mod}"
    fi
    str=$(echo "$str" | base64 -d) > /dev/null 
    if [ $? -eq 0 ]; then
       echo $str
    fi
  fi
}

function change_format()
{
  if [ $# -eq 1 ]; then
     echo $(echo $1 | awk -F ":" -v val="S2luZwo" '{
         if(NF == 6){
	   if($6 != ""){
	    if(match($6,"remarks") == 0){
	      $6=$6"&remarks="val
	    }
            if(match($6,"group") == 0){
	      $6=$6"&group="val
	    }else{
	      gsub("group=.*$","group="val,$6) 
            }
           }else{
             $6=$6"/?remarks=xxx&group="val
           }
           gsub(" ",":",$0)
	   print "ssr://"$0
	 } 
	 }')
  fi
}

function make_data()
{
  if [ $# -eq 2 ]; then
   local src=$1
   if [ -e "$src" ]; then
    local dst=$2
    declare -a ssr=($(sed "s/ssr:..//g" "$src"))
    rm -rf "$dst" > /dev/null 2>&1
    for i in "${ssr[@]}"; do
     local res=$(change_format $(url_safe_base64_decode "$i"))
     if [ "$res" != "" ]; then
       printf %s $(url_safe_base64_encode "$res") >> "$dst"
     fi
    done
   fi
  fi
}

update_by_doubiSSR
