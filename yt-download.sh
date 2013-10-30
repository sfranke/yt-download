#!/bin/bash

# tput config
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Global constants
HOME_PATH=${HOME}"/YoutubeDownload" 
TMP_LOCATION=/tmp
search=""
SEARCH_RESULT_AMOUNT='5'
YT_ID_LENGTH='11'
INET_ACTIVE=false
ADDRESS_LINKED=""

youtube_dl_dependency_check(){
    if [[ ! -x /usr/bin/youtube-dl ]]; then
        echo -ne ${RED}"[ERROR] missing dependency please install ${BOLD} youtube-dl \n"${RESET}
        echo "Do you want to install 'youtube-dl' if available? (Y|n)"
        read INPUT
        case "${INPUT,}" in
            "Y"|"")
                echo -e "Downloading 'youtube-dl'.. \n"
                sudo apt-get install youtube-dl
                if [[ -x /usr/bin/youtube-dl ]]; then
                     echo -e ${GREEN}"Installation successful! \n"${RESET}
                else
                     echo ${RED}"Installation failed.."${RESET}
                     exit 1
                fi
                ;;
            "*")
                echo "Bye, bye!"
                exit 0
                ;;
        esac
    fi
}

# @return boolean connectivity status 
connectivity() {
    if [[ `ping -q -w 1 google.de 2>&1 > /dev/null && echo ok || echo error` == "ok" ]]; then
        INET_ACTIVE=true
    else
        INET_ACTIVE=false
    fi
}

yt_menu(){

    if [[ "$1" == "--retry" ]]; then
        action="n"
    elif [[ "$1" == "--accept" ]]; then
        action="y"
    else
        echo "Please enter your youtube search keywords and press [${BOLD}ENTER${RESET}]" 
        read search
        echo "You search for ${WHITE}${BOLD}\"${search}\"${RESET} ?? type (${BOLD}Y${RESET}|n|e}"
        read action
    fi
    
    case "${action,}" in

        "y"|"")
            echo "Searching.."
            ;;
        "n")
            echo "${YELLOW}${BOLD}Please try again.${RESET}"
            echo ""
            yt_menu
            ;;
        "e")
            echo "${RED}${BOLD}Exiting the program now.${RESET}"
            echo ""
            exit 0
            ;;
        *)
            echo "${YELLOW}${BOLD}Unknown command!${RESET}"
            yt_menu --retry
            ;;
    esac
}

grabOnline(){
    search_param="${search// //}"
    SEARCH_RESULT_LINK=$(curl -silent https://gdata.youtube.com/feeds/api/videos/-/${search_param}\?v\=2\&max-results\=${SEARCH_RESULT_AMOUNT}\&orderby/most_viewed | grep -Eo "https:\/\/www.youtube.com\/watch\?v=[a-zA-Z0-9_\-]{${YT_ID_LENGTH}}" | uniq)
    str=${SEARCH_RESULT_LINK//$'\n'$'\n'/$'\t'}    # replace 2 linebreakes by 1 tab

    while [[ "$str" =~ $'\t'$'\n' ]] ; do
        str=${str//$'\t'$'\n'/$'\t'}          # eat up further newlines
    done

    str=${str//$'\t'$'\t'/$'\t'}            # sqeeze tabs
    IFS=$'\n'                               # field separator is now new line
    RESULT=($str)                           # split into array

    cnt='0'
    for x in ${RESULT[@]}; do               # print result
        echo "" 
        video_title="$(youtube-dl --get-title ${RESULT[cnt]})" 
        echo -e "${BOLD}${WHITE}$((cnt+1))${RESET}   ${YELLOW}${BOLD}${video_title}${RESET}\n    ${CYAN}$x${RESET}"
        RESULT_TITLE[cnt]=${video_title}
        ((cnt++))
    done
}

# User input to select a URL
select_item(){
    echo ""
    echo "Please select a video. [${BOLD}${WHITE}1-"${SEARCH_RESULT_AMOUNT}"${RESET}]"
    read selection

    case "${selection}" in
    [1-${SEARCH_RESULT_AMOUNT}]*)
        ;;
    *)
        echo "" 
        echo "Selection out of range. Please try again."
        select_item
        ;;
    esac

    echo ""
    echo -e "You chose: \"[${BOLD}${selection}${RESET}] ${YELLOW}${BOLD}${RESULT_TITLE[$((selection-1))]}${RESET}\" , please confirm. (${BOLD}Y${RESET}|n|e)"
    read action

    case "${action,}" in

    "y")
        echo "${WHITE}${BOLD}Initializing download..${RESET}"
        echo ""
        ;;
    "")
        echo "${WHITE}${BOLD}Initializing download..${RESET}"
        echo ""
        ;;
    "n")
        echo "${YELLOW}${BOLD}Please try again.${RESET}"
        select_item
        ;;
    "e")
        echo "${RED}${BOLD}Exiting the program now.${RESET}"
        exit 0
        ;;
    *)
        echo ""
        echo "Please select a video within the range of [${BOLD}${WHITE}1-"${SEARCH_RESULT_AMOUNT}"${RESET}]"
        select_item
        ;;
    esac
}

yt_download(){

if [[ "$1" == "--linked" ]]; then
    address="${ADDRESS_LINKED}"
    regex='v=(.*)'
else
    address="${RESULT[$((selection-1))]}"
    regex='v=(.*)'
fi

    if [[ $address =~ $regex ]]; then

    if [[ ! -d "${HOME_PATH}" ]]; then
        mkdir -p ${HOME_PATH}
    fi

    cd ${TMP_LOCATION}

    video_id=${BASH_REMATCH[1]}
    video_id=$(echo $video_id | cut -d'&' -f1) 
    video_title="$(youtube-dl --get-title $address)"
    video_format="$(youtube-dl --get-format $address)"
    ext=""

    #Format handling
    case "${video_format}" in

    37) ext='mp4'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    22) ext='mp4'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    18) ext='mp4'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    17) ext='mp4'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    35) ext='flv'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    34)
        ext='flv'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    5)
        ext='flv'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    46)
        ext='webm'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    45)
        ext='webm'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    44)
        ext='webm'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    43)
        ext='webm'
        echo "[youtube] ${video_id} is a ${ext} file."
        ;;
    *)
        echo "WARNING! Unsupported fileformat!"
        exit 1
    esac

    # Downloading the video in untoched format
    youtube-dl $address

    # Extract audio as *wav from video source
    ffmpeg -i ${video_id}.${ext} "${video_title}".wav

    if [[ ! -f "${video_title}.wav" ]]; then
        echo "${video_title}.wav was not found. (ffmpg)"
        exit 1
    fi

    # Convert audio to mp3 format
    lame "${video_title}".wav "${HOME_PATH}/${video_title}".mp3

    if [[ ! -f "${HOME_PATH}/${video_title}".mp3 ]]; then
        echo "${video_title}.mp3 was not found. (lame)"
        exit 1
    fi

    # Remove data from /tmp folder (cleanup)
    rm ./${video_id}.${ext} ./"${video_title}".wav

    if [[ -f "${video_title}".${ext} ]] && [[ -f "${video_title}".wav ]]; then
        echo "Cleanup failed!"
        exit 1
    fi
else
    echo "Sorry but the system encountered a problem."
    exit 1
fi
exit 0
}

Search_or_link(){
    echo "Do you want to [${WHITE}${BOLD}1${RESET}]${BOLD}search${RESET} or [${WHITE}${BOLD}2${RESET}]${BOLD}insert a link${RESET}?"
    read search

    if [[ ${search} == 1 ]]; then
        echo "You selected to activate the search."
        yt_menu
    elif [[ ${search} == 2 ]]; then
        echo "Please insert your link"
        read search
        ADDRESS_LINKED="${search}"
        video_title="$(youtube-dl --get-title ${ADDRESS_LINKED})"
        echo -e " ${YELLOW}${BOLD}${video_title}${RESET}\n ${CYAN}${ADDRESS_LINKED}${RESET}"
        yt_download --linked
    else
        echo "Your selection is unrecognized, please try a again!"
        Search_or_link
    fi
}

# check for active internet
connectivity

# Checking youtube-dl availability and donwload
youtube_dl_dependency_check

if [[ ${INET_ACTIVE} == true ]]; then
    echo "Internet connection established!"
    Search_or_link
    grabOnline
    select_item
    yt_download
else
    echo "Plese check your internet connectivity."
fi
exit 0
