#!/usr/bin/env bash
#描述:抓取逗比SSR
#版本:1.0


ROOT=.
REQUIREMENT="curl sed ua awk"
CURL_OPTION="-# -sL"
SAVE_TYPE="txt"
SAVE_FILE="$ROOT/output"
SELF_UA=0
RANGE_START=0
RANGE_END=2
PROCESS=2
LOG_FILE="--"
LOG_LEVEL=1
VERSION="1.0"
INTENT="抓取逗比SSR"


function app()
{
  parse_args "$@"
  show
  check $REQUIREMENT
  clock_start
  prepare
  crawl
  free
  clock_end
} 

function check()
{
  log i "requirement checking..."
  local nc=0
  for i in $@; do
      log i "check $i ..."
      which $i > /dev/null  2>&1
      if [ $? -ne 0 ]; then
   if [ "$i" == "ua" ]; then
            SELF_UA=1
      log w "use self ua instead."
         else
      log e "$i not found!"
      let nc+=1
   fi
      fi
      log i "$i is exist!"
  done
  if [ $nc -gt 0 ]; then
     log e "$nc requirements not found!"
     exit 1
  else
     log i "all requirements ok!"
  fi
}

function parse_args()
{
  eval set -- "$@"
  local O=$(getopt -a -o :o:p:r:t:l:e:s:civh -l :output:,process:,range:,save-type:,log-file:,log-level:,log-style:,cache,show-config,version,help "$@")
  eval set -- "$O"
  while true; do
        case "$1" in
        -o|--output) may_set "SAVE_FILE" "$2"; shift 2;;
        -p|--process) may_set "PROCESS" "$2"; shift 2;;
        -r|--range) may_set "RANGE" "$2"; shift 2;;
        -t|--save-type) may_set "SAVE_TYPE" "$2"; shift 2;;
        -l|--log-file) may_set "LOG_FILE" "$2"; shift 2;;
        -e|--log-level) may_set "LOG_LEVEL" "$2"; shift 2;;
        -s|--log-style) may_set "LOG_STYLE" "$2"; shift 2;;
        -c|--cache) may_set "CACHE" 1; shift;;
        -i|--show-config) show; exit 0; shift;;
        -v|--version) echo "$VERSION"; exit 0; shift;;
        -h|--help) help; exit 0; shift;;
        --) shift; break;;
        *) echo "Error!"; exit 1;;
        esac
done
}

function may_set()
{
 if [ $# -eq 2 ]; then
  is_register "$1"
  if [ $? -eq 1 ]; then
     case "$1" in
        "SAVE_FILE") SAVE_FILE="$2" ;;
        "PROCESS") PROCESS="$2" ;;
        "RANGE") RANGE="$2"; handle_range ;;
        "SAVE_TYPE") SAVE_TYPE="$2" ;;
        "LOG_FILE") LOG_FILE="$2" ;;
        "LOG_LEVEL") LOG_LEVEL="$2" ;;
        "LOG_STYLE") LOG_STYLE="$2" ;;
        "CACHE") CACHE="$2" ;;
     esac    
  fi
 fi
}

function handle_range()
{
  local left=$(echo $RANGE|awk -F ":" '{print $1}')
  local right=$(echo $RANGE|awk -F ":" '{print $2}')
  is_number "$left"
  if [ $? -eq 0 ] && [ "$left" != "" ]; then
     RANGE_START=$left
  fi
  is_number "$right"
  if [ $? -eq 0 ] && [ "$right" != "" ]; then
     RANGE_END=$right
  fi
}

function is_number()
{
  printf %d $1 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    return 0
  else
    return 1
  fi
}

function show()
{
  log i "all of var"
  log i "ROOT:$ROOT"
  log i "REQUIREMENT:$REQUIREMENT"
  log i "SELF_UA:$SELF_UA"
  log i "SAVE_FILE:$SAVE_FILE"
  log i "PROCESS:$PROCESS"
  log i "RANGE:$RANGE"
  log i "RANGE_START:$RANGE_START"
  log i "RANGE_END:$RANGE_END"
  log i "SAVE_TYPE:$SAVE_TYPE"
  log i "LOG_FILE:$LOG_FILE"
  log i "LOG_LEVEL:$LOG_LEVEL"
  log i "LOG_STYLE:$LOG_STYLE" 
  log i "CACHE:$CACHE"
  log i "VERSION:$VERSION"
  log i "INTENT:$INTENT"
}

function clock_start()
{
  TIME=$(date +%s)
  log i "clock start at $(date +%H:%M:%S)"
}

function prepare()
{
   local is_clean=1
   if [ ! -z $CACHE ]; then
     if [ $CACHE -eq 1 ]; then
        is_clean=0
     fi
   fi
   if [ ! -z $SAVE_FILE ]; then
     if [ $is_clean -eq 0 ]; then
       log i "continue to use file '$SAVE_FILE' for saving data"
     else
       log d "clean file '$SAVE_FILE'"
       rm -rf $SAVE_FILE
     fi
   fi

   buid_FIFO
}

function free()
{
   log d "close FIFO"
   exec 6>&-
   log d "make clean"
   clean_tmp
}

function clean_tmp()
{
  rm $(dirname $(mktemp -u))/tmp.* > /dev/null 2>&1
}

function clock_end()
{
  let tmp_time=$(date +%s)-$TIME
  local info="during time:"
  if [ $# -eq 1 ]; then
     info="$1 $info"
  fi
  if [ $tmp_time -gt 0 ]; then
     local per=3600
     if [ $tmp_time -gt $per ]; then
        info="$info$(($tmp_time/$per))h"
	tmp_time=$(($tmp_time%$per))
     fi
     per=60
     if [ $tmp_time -gt $per ]; then
        info="$info$(($tmp_time/$per))m"
        tmp_time=$(($tmp_time%$per))
     fi
     if [ $tmp_time -gt 0 ];then
        info="${info}${tmp_time}s"
     fi
  else 
     info="${info}0s"
  fi
  log i "$info"
}

function help()
{
  print_about
  print_usage
  print_options
}

function print_about()
{
   return 0
}

function print_usage()
{
  local script=$(basename $0 .sh)
  local intent=$INTENT
  local usage="Usage: %s [OPTIONS] "
  is_register "SAVE_FILE"
  [[ $? -eq 1 ]] && usage+="[-o file] "
  is_register "PROCESS"
  [[ $? -eq 1 ]] && usage+="[-p number] "
  is_register "RANGE"
  [[ $? -eq 1 ]] && usage+="[-r start:end] "
  is_register "SAVE_TYPE"
  [[ $? -eq 1 ]] && usage+="[-t txt|html|file] "
  is_register "LOG_FILE"
  [[ $? -eq 1 ]] && usage+="[-l logfile] "
  printf "$usage... %s\n\n" "$script" "$intent"
}

function print_options()
{
  printf "Options:\n" 
  may_printf "SAVE_FILE" "\t-o | --output\t\t%s\n" "设置输出文件"  
  may_printf "PROCESS" "\t-p | --process\t\t%s\n" "设置进程数，默认:1"
  may_printf "RANGE" "\t-r | --range\t\t%s\n" "指定抓取范围,默认:[0,2]"
  may_printf "SAVE_TYPE" "\t-t | --save-type\t%s\n" "保存类型(txt,html,file)"
  may_printf "LOG_FILE" "\t-l | --log-file\t\t%s\n" "设置日志文件"
  may_printf "LOG_LEVEL" "\t-e | --log-level\t%s\n" "日志等级(debug,info,warn,error)"
  may_printf "LOG_STYLE" "\t-s | --log-style\t%s\n" "日志风格(default,less,middle,more)"
  may_printf "CACHE" "\t-c | --cache\t\t%s\n" "尝试使用上次的缓存"
  printf "\t-i | --show-config\t%s\n" "显示当前配置"
  may_printf "VERSION" "\t-v | --version\t\t%s\n" "打印版本信息"
  printf "\t-h | --help\t\t%s\n\n" "显示帮助"
}

function may_printf()
{
 if [ $# -eq 3 ]; then
  is_register "$1"
  if [ $? -eq 1 ]; then
     printf "$2" "$3"
  fi
 fi
}

function is_register()
{
   if [ $# -eq 1 ]; then
     local res=$(eval echo "$"$1)
     if [ ! -z $res ]; then
        return 1
     fi
  fi
  return 0
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

function fetch()
{
   #set -x
   echo "" > $1
   curl -A "$(gen_ua)" -e $3 -o $1 -H "Accept-Language: zh-CN,zh;q=0.9" -H "X-Forwarded-For: $(get_random_ip)" -H "Content-Type: multipart/form-data; session_language=cn_CN" --connect-timeout 30 --retry 3 --retry-max-time 10 $CURL_OPTION $2
   sleep 1
   #set +x
}   

function is_null()
{
 if [ $# -eq 3 ]; then
  if [ "$2" == "" ]; then
      log w "$1 is empty!($3)"
      return 1
  else
      log i "$1:$2($3)"
      return 0
  fi
 fi
}

function buid_FIFO()
{
   if [ ! -z $PROCESS ]; then
      log d "build FIFO..."
      local tmp="$ROOT/.fifo_tmp"
      log d "create temp file:$tmp"
      mkfifo $tmp
      log d "use 6 to bind FIFO"
      exec 6<>$tmp
      log d "delete temp file:$tmp"
      rm -f $tmp
      log d "set process:$PROCESS"
      for ((i=0;i<$PROCESS;i++))
      do
          echo >&6
      done
      log d "FIFO ok!"
  fi
}

function not_implement()
{
  log w "$1 not implement!"
  exit 0
}

function inspect()
{
   if [ $[$1+$2] -lt $3 ]; then
      return 1
   else
      return 0
   fi
}

function log()
{                      
    local logtype=$1        
    local logmsg=$2
    local logfile=$LOG_FILE           
    local loglevel=$LOG_LEVEL
    local logstyle=$LOG_STYLE
    local logdate=$(date +'%F %H:%M:%S')       
    local line=$(caller 0 | awk '{print $1}')
    local format="$logmsg"
    #echo "loglevel:"$loglevel
    if [ ! -z $loglevel ]; then
      if   [ "$loglevel" == "debug" ]; then loglevel=0
      elif [ "$loglevel" == "info"  ]; then loglevel=1
      elif [ "$loglevel" == "warn"  ]; then loglevel=2 
      elif [ "$loglevel" == "error" ]; then loglevel=3
      else loglevel=1; fi
    else
       loglevel=1
    fi
    #echo "level:"$loglevel
    if [ "$logstyle" == "less" ]; then
       format="$logdate $logmsg"
    elif [ "$logstyle" == "middle" ]; then
       format="${FUNCNAME[@]/log/} [line:$line] $logmsg"
       format="${FUNCNAME[@]/log/} [line:$line] $logmsg"
       format=${format:1}
    elif [ "$logstyle" == "more" ]; then
       format="$logdate${FUNCNAME[@]/log/} [line:$line] $logmsg"
    fi
    case $logtype in          
        "d"|"debug")                                                             [[ $loglevel -le 0 ]] && echo -e "\033[30m[debug] ${format}\033[0m"
        ;;
        "i"|"info")
                  [[ $loglevel -le 1 ]] && echo -e "\033[32m[info] ${format}\033[0m"
         ;;
        "w"|"warn")
                 [[ $loglevel -le 2 ]] && echo -e "\033[33m[warn] ${format}\033[0m"
        ;;
        "e"|"error")
                 [[ $loglevel -le 3 ]] && echo -e "\033[31m[error] ${format}\033[0m"
        ;;
     esac | tee -a $logfile
}

function gen_ua()
{
  if [ $SELF_UA == 1 ]; then
      local user_agent=("Mozilla/5.0 (Windows NT 10.0; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2870.18 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.3; Trident/4.0)" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2917.90 Safari/537.36" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2792.54 Safari/537.36" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.2; Win64; x64; Trident/5.0)" "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2818.55 Safari/537.36" "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2676.60 Safari/537.36" "Mozilla/5.0 (Windows NT 6.3; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2896.66 Safari/537.36" "Mozilla/5.0 (X11; Linux i686 on x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 5.1; WOW64; Trident/6.0)" "Mozilla/5.0 (X11; Linux i686; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0" "Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0" "Mozilla/5.0 (X11; Linux i686; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2912.44 Safari/537.36" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:49.0) Gecko/20100101 Firefox/49.0" "Mozilla/5.0 (Windows NT 6.1; Win64; x64; Trident/7.0; rv:11.0) like Gecko")
      local min=0
      local max=$((${#user_agent[@]}-1))
      local index=$(rand $min $max)
      echo ${user_agent[$index]}
  else
      echo $(ua)
  fi
}

function init_record()
{
  if [ $# -eq 1 ]; then
    echo "TOTAL:0" > $1
    echo "SAVE:0" >> $1
  else 
    log e "init_record() needs 1 argument"
  fi
}

function read_record()
{
  if [ $# -eq 2 ]; then
    if [ -e "$2" ]; then
      awk -F ":" -v key=$1 '{if($1 == key) print $2 }' $2
    fi
 fi
}

function write_record()
{
  if [ $# -eq 3 ]; then
    if [ -e "$3" ]; then
      sed -i "s/$1:.*/$1:$2/g" $3
    fi
 fi
}

function update_record()
{
  if [ $# -eq 4 ]; then
    is_number $3
    if [ $? -eq 0 ]&&[ -e "$4" ]; then
      local value=$(read_record $2 $4)
      is_number $value
      if [ $? -eq 0 ]; then
        if [ "$1" == "+" ]; then
          value=$(($value + $3))
        elif [ "$1" == "-" ]; then
          value=$(($value - $3))
        elif [ "$1" == "×" ]; then
          value=$(($value * $3))
        elif [ "$1" == "÷" ]; then
          value=$(($value / $3))
        fi
        write_record $2 $value $4
      fi
    fi
  else
    log e "update_record() needs 4 argument"
  fi
}

function plus_record()
{
  update_record + "$@"
}

function init_html()
{
if [ $# -eq 2 ]; then echo \
"<!DOCTYPE Html>
 <html>
 <head><title>$2 "$(date "+%Y-%m-%d %H:%M:%S")"</title>
 <meta charset=\"utf-8\">
 <style>
 div{border:2px solid #333333;} 
 p{font-size:20px;}
 </style>
 </head>
 <body align=\"center\">" > $1
fi
}

function may_fix_html()
{
 if [ $# -eq 1 ]; then
  if [ "$SAVE_TYPE" == "html" ]; then
    local file="${SAVE_FILE}-${1}.${SAVE_TYPE}"
    if [ -e "$file" ]; then
     echo "</body>" >> $file
     echo "</html>" >> $file
    fi
  fi
 fi
}

function do_save()
{
  local list=$1
  local part=$2
  if [ "$SAVE_TYPE" == "txt" ]; then
     local result="${SAVE_FILE}-${part}.${SAVE_TYPE}"
     if [ ! -e "$result" ]; then
        touch "$result"
        log i "create file:$result"
     fi
     awk -F "*" -v file="$result" '{print $1":"$3 >> file }' "$list"
     echo "" >> "$result"
  elif [ "$SAVE_TYPE" == "html" ]; then
     local result="${SAVE_FILE}-${part}.${SAVE_TYPE}"
     if [ ! -e "$result" ]; then
        touch "$result"
        init_html "$result" "$part"
  log i "create file:$result"
     fi
     awk -F "*" -v file="$result" \
     'BEGIN{html="<div>"} {
       if($2 == "IMAGE"){
         html=html"<img src=\""$3"\" width=\"100%\"/><hr>"
       } else if( $2 == "URL" || $2 == "VIDEO" || $2 == "MUSIC"){
         tmp=""$4
         if(tmp == ""){
           tmp="查看"$1
         }
         html=html"<a href=\""$3"\"><p>"tmp"</p></a><br>"
       } else{
         html=html"<p>"$3"</p><br>"
       }
     }END{html=html"</div>";print html >> file}' "$list"
  elif [ "$SAVE_TYPE" == "file" ]; then
      if [ ! -e "$SAVE_FILE" ]; then
         mkdir -p "$SAVE_FILE"
         log i "create dir:$SAVE_FILE"
      fi
      local result=($(awk -F "*" '{if($1 == "title" && $2 == "TEXT")print $3}' $list))
      if [ "$result" == "" ]; then
         result=$(mktemp -u result.XXXXXX)"~"$(date +%Y-%m-%d_%H:%M:%S)
      fi
      result="$SAVE_FILE/$part/$result"
      if [ ! -e "$result" ]; then
         mkdir -p "$result"
      fi
      awk -F "*" -v dir="$result" '{
        subfix="NONE"
        if($2 == "IMAGE"){
          subfix="jpg"
        }else if($2 == "VIDEO"){
          subfix="mp4"
        }else if($2 == "MUSIC"){
          subfix="mp3"
        }
        if(subfix != "NONE"){
          cmd="curl -# -L -o "dir"/"$1"."subfix" "$3
        }else{
          cmd="echo \""$1":"$3"\" >> "dir"/others"
        }system(cmd)}' "$list"
       if [ -e "$result/others" ];then
          echo "" >> $result/others
       fi
 fi
}

function save()
{
  if [ $# -eq 3 ]; then
   if [ -e "$1" ]; then
      do_save $1 $3
      if [ $? -eq 0 ]; then
        plus_record SAVE 1 $2
      fi
   fi
  fi
}
 

function doubiSSR()
{
  log i "doubiSSR start..."
  record_doubiSSR=$ROOT/.doubiSSR_crawl_record
  init_record ${record_doubiSSR}
  declare -a page=("https://doub.io/sszhfx/")
   for i0 in ${page}; do
    read -u 6
    {
    data=$(mktemp -u)
    log i "fetch ${i0}"
    fetch "${data}" "${i0}" "${i0}"
    if [ $? != 0 ]||[ ! -e ${data} ];then continue; fi
    declare -a view=$(n=$(sed -n "/page-numbers current/p" ${data} | awk -F ">|<" '{print $3}');echo https://doub.io/sszhfx/comment-page-{$n,$((n-1)),$((n-2))}/#comments)
    rm ${data} > /dev/null 2>&1
    for i1 in ${view}; do
     read -u 6
     {
     data=$(mktemp -u)
     log i "fetch ${i1}"
     fetch "${data}" "${i1}" "${i1}"
     if [ $? != 0 ]||[ ! -e ${data} ];then continue; fi
     local list=$(mktemp -u)
     local size=0
     local ss=($(sed -n '/prettyprint linenums/,/<\/pre>/p' ${data} | grep -Ev '(strong>|://xxx)' |  sed -n "/ss:\/\//p" | sed "s/\(.*\)ss\(.*\)/ss\2/g" | sed "s/ //g" | sed "s/ //g"))
     is_null "ss" "${ss}" $(read_record SAVE ${record_doubiSSR})
     if [ ${size} -lt ${#ss[@]} ]; then size=${#ss[@]}; fi
     local ssr_0=($(sed -n '/prettyprint linenums/,/<\/pre>/p' ${data} | grep -Ev '(strong>|://xxx)' |  sed -n "/ssr:\/\//p" | sed "s/\(.*\)ssr\(.*\)/ssr\2/g" | sed "s/ //g" | sed "s/ //g"))
     is_null "ssr_0" "${ssr_0}" $(read_record SAVE ${record_doubiSSR})
     if [ ${size} -lt ${#ssr_0[@]} ]; then size=${#ssr_0[@]}; fi
     local ssr_1=($(sed -n "/dl1.*ss/p" ${data} | sed 's/\(.*\)ssr\(.*\)" t\(.*\)/ssr\2/g' | awk -F '"' '{print $1}' | sed "s/ //g"))
     is_null "ssr_1" "${ssr_1}" $(read_record SAVE ${record_doubiSSR})
     if [ ${size} -lt ${#ssr_1[@]} ]; then size=${#ssr_1[@]}; fi
     for((i=0;i<${size};i++)); do
       echo "ss*URL*${ss[i]}*导入评论区SS" > ${list}
       echo "ssr_0*URL*${ssr_0[i]}*导入评论区SSR" >> ${list}
       echo "ssr_1*URL*${ssr_1[i]}*导入逗逼自建SSR" >> ${list}
       save ${list} ${record_doubiSSR} "doubiSSR"
     done
     rm -rf ${list} > /dev/null 2>&1
     plus_record TOTAL 1 ${record_doubiSSR}
     rm ${data} > /dev/null 2>&1
     echo >&6
     } &
     done
     wait
    echo >&6
    } &
    done
    wait
  may_fix_html "doubiSSR"
  log i "doubiSSR done!"
}

function crawl()
{
  doubiSSR
  log i "doubiSSR TOTAL:$(read_record TOTAL ${record_doubiSSR}) SAVE:$(read_record SAVE ${record_doubiSSR})"
  rm -rf ${record_doubiSSR}
  log i "all crawl tasks finished!"
}


app "$#" "$*"
