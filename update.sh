#!/usr/bin/env bash

ROOT=.
SELF=$0
PICK_SSR=$ROOT/doubiSSR.sh
SSR_FILE=$ROOT/output-doubiSSR.txt
SUBSCRIBE=DATA
MODE="BASE64" #TEXT|BASE64
SSR_URL="https://raw.githubusercontent.com/King-1025/server/SSR/$SUBSCRIBE"
REMARKS=$(date "+%Y-%m-%d")
GROUP=King-1025 

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
  echo ""
}

function update_by_doubiSSR()
{
  if [ ! -e $SSR_FILE ]; then
    $PICK_SSR
  fi
  if [ $? -eq 0 ]&&[ -e $SSR_FILE ]; then
    if [ "$MODE" == "TEXT" ]; then
      mv "$SSR_FILE" > "$ROOT/$SUBSCRIBE"
    else
      make_data "$SSR_FILE" "$ROOT/$SUBSCRIBE" "$REMARKS" "$GROUP"
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
  if [ $# -eq 2 ]; then
    declare -a str=()
    if [ "$1" == "STRING" ]; then
        str=($(echo "$2" | base64))
    elif [ "$1" == "FILE" ]; then
      if [ -e "$2" ]; then
        str=($(base64 "$2"))
      fi
    fi
    if [ ${#str[@]} -gt 0 ]; then
      local res=""
      for i in ${str[@]}; do
        res+=$(echo "$i" | sed "s/\//_/g" | sed "s/+/-/g" | sed "s/=//g")
      done
      echo "$res"
    fi
  fi
}

function url_safe_base64_decode()
{
  if [ $# -eq 2 ]; then
    declare -a str=()
    if [ "$1" == "STRING" ]; then
        str=($(echo "$2" | sed "s/ //g" | sed "s/_/\//g" | sed "s/-/+/g"))
    elif [ "$1" == "FILE" ]; then
      if [ -e "$2" ]; then
        str=($(sed "s/ //g" "$2" | sed "s/_/\//g" | sed "s/-/+/g"))
      fi
    fi
    if [ ${#str[@]} -gt 0 ]; then
      local res=""
      for i in ${str[@]}; do
       local mod=$((${#i}%4))
       if [ $mod -gt 0 ]; then
         local eq="===="
         res="${i}${eq:$mod}"
        else
         res=$i
       fi
       res=$(echo "$res" | base64 -d)
       if [ $? -eq 0 ]&&[ "$res" != "" ]; then
         echo "$res"
       fi
     done
    fi
  fi
}

function change_format()
{
  if [ $# -eq 3 ]; then
    local remarks=$2
    local group=$3
    local flag=$(echo $1 | awk -F ":" '{
      if(NF == 6){
       if(match($6,"\?.") != 0){
         print "VALID_HAVE"
       }else{
         print "VALID_EMPTY"
       }
      }else{
        print "INVALID"
      }
    }')
    if [ "$flag" == "VALID_HAVE" ]; then
      echo $1 | awk -F "&" -v drs="$remarks" -v dgp="$group" '{
       have_remarks="no"
       have_group="no"
       for(i=1;i<=NF;i++){
 	      if(match($i,"remarks") != 0){
          have_remarks="yes"
	      }
        if(match($i,"group") != 0){
	        $i="group="dgp
          have_group=yes
         }
	     }
       if(have_remarks == "no"){
         $NF=$NF"&remarks="drs
       }
       if(have_group == "no"){
         $NF=$NF"&group="dgp
       }
      gsub(" ","\\&",$0)
	    print $0
	  }'
    elif [ "$flag" == "VALID_EMPTY" ]; then
      echo "$1/?remarks=${remarks}&group=${group}"
    elif [ "$flag" == "INVAILD" ]; then
      echo "INVAILD:$1"
      return 1
    fi
  fi
}

function make_data()
{
#  set -x
  if [ $# -eq 4 ]; then
   local src=$1
   if [ -e "$src" ]; then
    local dst=$2
    local remarks=$(url_safe_base64_encode STRING $3)
    local group=$(url_safe_base64_encode STRING $4)
#    local remarks=$(echo "$3" | base64)
#    local group=$(echo "$4" | base64)
    local tmp=$(mktemp -u)
    cp "$src" "$tmp"
    sed -i "s/ssr:..//g" "$tmp"
    sed -i "s/ss:..//g" "$tmp"
    declare -a stxt=($(url_safe_base64_decode FILE "$tmp"))
    rm -rf "$tmp" > /dev/null 2>&1
    tmp=$(mktemp -u)
    local number=0
    for i in "${stxt[@]}"; do
     local res=$(change_format "$i" "$remarks" "$group")
     if [ $? -eq 0 ]&&[ "$res" != "" ]; then
       echo "============ecoding=========="
       echo -e "$res\n"
       res=$(url_safe_base64_encode STRING "$res")
       echo "ssr://$res" >> "$tmp"
       number=$(($number+1))
     else
       echo "------------passing---------"
       echo -e "Invalid:$i\n"
     fi
    done
    echo "Total:${#stxt[@]} Valid:$number"
    sed -i "1i\MAX=$number" $tmp
   # mv $tmp 1
   # exit 0
    echo $(url_safe_base64_encode FILE "$tmp") > "$dst"
    rm -rf "$tmp" > /dev/null 2>&1
   fi
  fi
  # set +x
  # exit 0
}

update_by_doubiSSR
