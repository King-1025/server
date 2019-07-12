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

ROOT=$(get_pwd)
#echo $ROOT
#exit
OUTPUT=$ROOT/output-SSR.txt
SITE=http://www.youneed.win/

CURL_OPTION="-L $($ROOT/old/help/fake.py $SITE)"
echo CURL_OPTION: $CURL_OPTION
#exit

function app(){
  local data=$(mktemp -u)
  rm -rf "$OUTPUT"
  local lru="$SITE"
  for i in "" 2 3 4; do
    local url="${SITE}free-ssr/$i"
    echo ""
    echo fetch $url 
    #continue
    fetch "$data" "$url" "$lru"
    if [ $? -eq 0 ]&&[ -e "$data" ]; then
       sed -n "/<table.*1300px/,/table>/p" "$data" | \
       sed -n "/<td.*ssr:.*td>/p" | \
       awk -F '"' '{print $4}' >> "$OUTPUT"
    fi
    lru="$url"
  done
  echo "crawl ok!"
  rm -rf "$data"
}

function fetch()
{
   #set -x
   echo "" > $1

   local comm="curl $CURL_OPTION -o $1 -H \"Accept-Language: zh-CN,zh;q=0.9\" -H \"X-Forwarded-For: $(get_random_ip)\" -H \"Content-Type: multipart/form-data; session_language=cn_CN\" --connect-timeout 60 --retry 1 --retry-max-time 30 $2"
   eval "$comm"

  # curl -A "$(gen_ua)" -o $1 -H "Accept-Language: zh-CN,zh;q=0.9" -H "X-Forwarded-For: $(get_random_ip)" -H "Content-Type: multipart/form-data; session_language=cn_CN" --connect-timeout 60 --retry 1 --retry-max-time 30 $CURL_OPTION $2
   sleep 1
   #set +x
}

function gen_ua()
{
    local user_agent=("Mozilla/5.0 (Windows NT 10.0; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2870.18 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.3; Trident/4.0)" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2917.90 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2792.54 Safari/537.36" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.2; Win64; x64; Trident/5.0)" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2818.55 Safari/537.36" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2676.60 Safari/537.36" "Mozilla/5.0 (Windows NT 6.3; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2896.66 Safari/537.36" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 5.1; WOW64; Trident/6.0)" "Mozilla/5.0 (X11; Linux i686; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (X11; Linux i686; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2912.44 Safari/537.36" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Windows NT 6.1; Win64; x64; Trident/7.0; rv:11.0) like Gecko")
      local min=0
      local max=$((${#user_agent[@]}-1))
      local index=$(rand $min $max)
      echo ${user_agent[$index]}
}

function get_random_ip()
{
   local ch="."
   if [ "$#" -eq 1 ]; then
      ch=$1
   fi
   echo "$(rand 0 255)$ch$(rand 0 255)$ch$(rand 0 255)$ch$(rand 0 255)"
}

function rand(){
    local min=$1
    local max=$(($2-$min+1))
    local num=$(($RANDOM+1000000000))
    echo $(($num%$max+$min))
}

app $# $*
