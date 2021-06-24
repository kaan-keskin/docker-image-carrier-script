#!/bin/bash

# Docker Image Carrier Script
# Author: Kaan Keskin
# Co-Authors: 
# Creation Date: 19 October 2020 
# Modification Date: 24 June 2021
# Release: 1.6.24

HELP_MSG=(
""
"   Docker Image Carrier Script (DIC-Script): "
""
"   DIC-Script can be used to archive (save) and load Docker images between different registry addresses in isolated networks. "
"   These Docker registries could be placed in different networks such as the internet and the corporate intranet and can be isolated in any way. "
""
"   This script consists of two steps to deploy Docker Images between different artifact repositories or Docker registries. "
""
"   For the download (archive/save) step, DIC-Script downloads Docker images from defined Docker registry (artifact repository). "
""
"   For the upload (load) step, DIC-Script uploads Docker images to a defined Docker registry (artifact repository). "
""
"   Docker registry addresses and image lists are defined in the configuration files (application.config and docker-image-list.config)."
""
"   The user can check and watch all processes from the prompt screen and also from the log.txt file. "
"   All prompt screen output logged to this file. "
""
"   For Unix/Linux/Mac users: "
"   $ ./dic.sh -option(s) parameter "
""
"   For Windows bash users: "
"   $ bash dic.sh -option(s) parameter "
""
"   Options: "
"   -c : Cleaning option set. All output folders and files will be removed! "
"   -d : Download option set. Defined Docker images will be downloaded to the local disk in the images folder. "
"   -h : Shows this Help message. "
"   -l : Registry login option set. Docker Registry Login option set. Login information in the configuration file will be used. "
"   -r : Remove all Docker images option set. All Docker images in the local registry will be removed. Be careful with this option! "
"   -u : Upload option set. Downloaded Docker images will be uploaded to given Docker registry. "
"   -y : Yes to all for errors option set. Given errors will be neglected and the process will continue. "
""
"   Example Parameter Usages: "
"   local: Local Docker registry will be used. Do not use local for custom registry name in configuration file. This is reserved for local registry usage. "
"   dockerhub : Custom DockerHub registry configuration file will be used. "
"   registry-1 : Internet/Intranet Registry 1 configuration file will be used. "
"   registry-2 : Internet/Intranet Registry 1 configuration file will be used."
""
"   Example Usages: "
"   $ bash dic.sh -ydl dockerhub "
"   $ bash dic.sh -yd dockerhub "
"   $ bash dic.sh -dl dockerhub "
"   $ bash dic.sh -d dockerhub "
"   $ bash dic.sh -d local "
"   -------------------------------- "
"   $ bash dic.sh -yul dockerhub "
"   $ bash dic.sh -ul dockerhub "
"   $ bash dic.sh -yu local"
"   $ bash dic.sh -u local"
"   -------------------------------- "
"   $ bash dic.sh -h "
"   $ bash dic.sh -c "
"   $ bash dic.sh -r "
""
)

# Script Starting Path
START_PATH="$(pwd)"
SCRIPT_NAME="Docker Image Carrier Script"

# Created Folders and Files
OUTPUT_FOLDER="$START_PATH//outputs"
IMAGE_FOLDER="$OUTPUT_FOLDER//images"
LOG_FOLDER="$OUTPUT_FOLDER//logs"
LOG_IMAGE_FOLDER="$LOG_FOLDER//images"
LOG_FILE="$LOG_FOLDER//log.txt"

# Script Configuration Files
CONFIGURATION_FOLDER="$START_PATH//conf"
DOCKER_IMAGE_LIST_FILE="$CONFIGURATION_FOLDER//docker-image-list.config"

# Script Functions
seperator_line() {
    printf "=%.0s"  $(seq 1 60) | tee -a $LOG_FILE
    echo
}

custom_msg() {
    local message="$1"
    echo "[$(date +%H:%M:%S)] [INFO]    ${message}" | tee -a $LOG_FILE
}

custom_err() {
    seperator_line
    local message="$1"
    local code="${3:-1}"
    local working_dir="$(pwd)"
    echo "[$(date +%H:%M:%S)] [ERROR]   Working Directory: ${working_dir}" | tee -a $LOG_FILE
    echo "[$(date +%H:%M:%S)] [ERROR]   Step: ${code}" | tee -a $LOG_FILE
    echo "[$(date +%H:%M:%S)] [ERROR]   Message: ${message}" | tee -a $LOG_FILE
    seperator_line
}

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
err() {
    local code="${3:-1}"
    local working_dir="$(pwd)"
    echo "[ERROR]   WD: ${working_dir}, ${last_command} command filled with exit code ${code}." | tee -a $LOG_FILE
}
# echo an error message before exiting
trap 'err' ERR

custom_exit() {
   seperator_line
    echo "[$(date +%H:%M:%S)] [EXIT]    An ERROR occured!" | tee -a $LOG_FILE
    if [ $yes_flag -eq 0 ]; then
        read -n10 -p "[$(date +%H:%M:%S)] [EXIT]   Do you want to continue [Y/N]? " answer
        case $answer in
        Y | y | Yes | yes | YES)
            echo "[$(date +%H:%M:%S)] [EXIT]    Fine, continue on..." | tee -a $LOG_FILE
            seperator_line
            ;;
        N | n | No | no | NO)
            echo "[$(date +%H:%M:%S)] [EXIT]    OK, goodbye!" | tee -a $LOG_FILE
            exit
            ;;
        esac
    else
        echo "[$(date +%H:%M:%S)] [EXIT]    Yes to All option set. Fine, continue on..." | tee -a $LOG_FILE
        seperator_line
    fi
}

# Output Folder Operations
if [ -d $OUTPUT_FOLDER ]; then
    echo "Output folder exists: $OUTPUT_FOLDER"
else
    # New Output Folder Created
    mkdir -p "$OUTPUT_FOLDER" || exit
    echo "Output folder created: $OUTPUT_FOLDER"
fi

# Log Folder Operations
if [ -d $LOG_FOLDER ]; then
    echo "Log folder exists: $LOG_FOLDER"
else
    # New Log Folder Created
    mkdir -p "$LOG_FOLDER" || exit
    echo "Log folder created: $LOG_FOLDER"
fi

# Image Log Folder Operations
if [ -d $LOG_IMAGE_FOLDER ]; then
    echo "Image Log folder exists: $LOG_IMAGE_FOLDER"
else
    # New Build Log Folder Created
    mkdir -p "$LOG_IMAGE_FOLDER" || exit
    echo "Image Log folder created: $LOG_IMAGE_FOLDER"
fi

# Log File Operations
if [ -s $LOG_FILE ]; then
    echo "Log file exists: $LOG_FILE"
else
    echo "" >"$LOG_FILE" || exit
    echo "Log file created: $LOG_FILE"
fi

# Script Start Date
custom_msg "$SCRIPT_NAME Starting [$(date --rfc-3339=seconds)]"
custom_msg "Script starting path: $START_PATH"

# Script Options and Parameters
download_flag=0
login_flag=0
upload_flag=0
yes_flag=0
while getopts :cdhlruy opt; do
    case "$opt" in   
    c)
        custom_msg "Found the -c (clean) option."
        custom_msg "Clean option set. All output folders and files will be removed!"
        if [ -d $OUTPUT_FOLDER ]; then
            rm -rf "$OUTPUT_FOLDER" || exit
        fi
        echo "Cleaning operation successfully completed."
        exit 0
        ;;
    d)
        custom_msg "Found the -d (download) option."
        custom_msg "Download option set. Defined Docker images will be downloaded to local images folder."
        download_flag=1
        if [ $upload_flag -eq 1 ]; then
            custom_err "You can not download and upload at the same time."
            exit 1
        fi
        ;;
    h)
        custom_msg "Found the -h (help) option."
        printf '%s\n' "${HELP_MSG[@]}"
        exit 0
        ;;
    l)
        custom_msg "Found the -l (login) option."
        custom_msg "Docker Registry Login option set. Login information in configuration file will be used."
        login_flag=1
        ;;
    r)
        custom_msg "Found the -r (remove) option."
        custom_msg "Remove All Docker Images option set. All Docker images will be removed from local Docker registry."
        custom_msg "Be carefull with this option! This option will remove all Docker images from local Docker registry."
        read -n1 -p "[$(date +%H:%M:%S)] [REMOVE]   Do you want to continue [Y/N]? " answer
        case $answer in
        Y | y | Yes | yes | YES)
            docker image rm $(docker image ls -q) -f | tee -a $LOG_FILE
            docker image rm $(docker image ls -q) -f | tee -a $LOG_FILE
            echo
            echo "Remove operation successfully completed."
            exit 0
            ;;
        N | n | No | no | NO)
            custom_msg "OK, goodbye!"
            exit
            ;;
        esac
        ;;
    u)
        custom_msg "Found the -u (upload) option."
        custom_msg "Docker Image Upload option set. All available Docker images will be uploaded to given Docker Registry."
        custom_msg "Be carefull with this option! This option will upload images to Docker registry."
        if [ $download_flag -eq 1 ]; then
            custom_err "You can not download and upload at the same time."
            exit 1
        fi
        read -n1 -p "[$(date +%H:%M:%S)] [UPLOAD]   Do you want to continue [Y/N]? " answer
        case $answer in
        Y | y | Yes | yes | YES)
            upload_flag=1
            echo
            custom_msg "Docker images will be uploaded to Docker Registry."
            ;;
        N | n | No | no | NO)
            custom_msg "OK, goodbye!"
            exit
            ;;
        esac
        ;;
    y)
        custom_msg "Found the -y (Yes to All Error Continue) option."
        custom_msg "Yes to All Error Continue option set. Given errors will be neglected and process will continue."
        yes_flag=1
        ;;
    *)
        custom_err "Unknown option: $opt."
        exit 1
        ;;
    esac
done
shift $(($OPTIND - 1))
if [ $# -eq 0 ]; then
    custom_err "No parameters provided."
    exit 1
elif [ $# -gt 1 ]; then
    custom_err "Not correct number of parameters provided."
    exit 1
fi

local_flag=0
for param in "$@"; do
    CONFIG_FILE="$CONFIGURATION_FOLDER//$param.application.config"
    if [[ "$param" == "local" ]]; then
        custom_msg "Local Docker registry will be used."
        local_flag=1
    elif [ -s $CONFIG_FILE ]; then
        custom_msg "Configuration file for $param exists: $CONFIG_FILE"
    else
        custom_err "Configuration file for $param could not found: $CONFIG_FILE"
        exit 1
    fi
done
seperator_line

# Installed Software Versions
custom_msg "Installed Software Versions"
custom_msg "Git Version:"
git --version | tee -a $LOG_FILE || exit 1
custom_msg "Docker Info:"
docker info | tee -a $LOG_FILE || exit 1
custom_msg "Docker Image List:"
docker image ls -a | tee -a $LOG_FILE || exit 1
seperator_line

# Current Working Directory
custom_msg "Current working directory: $START_PATH"
seperator_line

# Reading Configuration
if [ $local_flag -eq 1 ]; then
    custom_msg "Local registry mode activated. This process does not need any configuration file."
elif [ -s $CONFIG_FILE ]; then
    source $CONFIG_FILE
    custom_msg "Configuration file ($CONFIG_FILE) found and not empty."
    if [ -n "$DOCKER_REGISTRY_DOWNLOAD" ] && [ -n "$DOCKER_REGISTRY_UPLOAD" ]; then
        custom_msg "Docker Registry Address for Download Operation: $DOCKER_REGISTRY_DOWNLOAD"
        custom_msg "Docker Registry Username for Download Operation: $DOCKER_REGISTR_DOWNLOAD_USERNAME"
        custom_msg "Docker Registry Address for Upload Operation: $DOCKER_REGISTRY_UPLOAD"
        custom_msg "Docker Registry Username for Upload Operation: $DOCKER_REGISTRY_UPLOAD_USERNAME"
    else
        custom_err "Configuration file ($CONFIG_FILE) has missing information."
    fi
else
    custom_err "Configuration file ($CONFIG_FILE) not found or empty."
    exit 1
fi
seperator_line

# Docker Registry Login
if [ $local_flag -eq 0 ] && [ $login_flag -eq 1 ]; then
    docker login -u $DOCKER_REGISTRY_DOWNLOAD_USERNAME -p $DOCKER_REGISTRY_DOWNLOAD_PASSWORD $DOCKER_REGISTRY_DOWNLOAD || custom_exit
    docker login -u $DOCKER_REGISTRY_UPLOAD_USERNAME -p $DOCKER_REGISTRY_UPLOAD_PASSWORD $DOCKER_REGISTRY_UPLOAD || custom_exit
fi

# Image Folder Preprocess Operations
if [ -d $IMAGE_FOLDER ]; then
    custom_msg "Image folder exists: $IMAGE_FOLDER"
    if [ $download_flag -eq 1 ]; then
        custom_err "Download operation can not be performed. Please check the options (-d or -u) and restart the script."
        custom_err "Image folder must be deleted to perform download operation. To remove image folder use -c option."
        exit 1
    fi
else
    if [ $upload_flag -eq 1 ]; then
        custom_err "Upload operation can not be performed. Please check the options (-d or -u) and restart the script."
        custom_err "Image folder must be available to perform upload operation. Firstly, you must download images."
        exit 1
    elif [ $download_flag -eq 1 ]; then
        # New Image Folder Created
        mkdir -p "$IMAGE_FOLDER" || exit
        custom_msg "New image folder created: $IMAGE_FOLDER"
    fi
fi
seperator_line
cd "$IMAGE_FOLDER" || exit

# Inter Field Seperator (IFS) Modification
IFS_OLD="$IFS"
IFS=$'\n\r'

# Repository Addresses
if [ -s $DOCKER_IMAGE_LIST_FILE ]; then
    for image_name in $(cat $DOCKER_IMAGE_LIST_FILE); do
        if [ -n "$image_name" ]; then
            custom_msg "Step for Docker Image: $image_name."
            clean_image_name=$(echo $image_name | tr -cd '[a-zA-Z0-9]')
            custom_msg "Docker Image (clean) name: $clean_image_name"
            # Docker Image Download Operations
            if [ $download_flag -eq 1 ]; then
                if [ $local_flag -eq 1 ] || [ -z $DOCKER_REGISTRY_DOWNLOAD ] || [ $DOCKER_REGISTRY_DOWNLOAD == "\n" ] ||  [ $DOCKER_REGISTRY_DOWNLOAD == "\r" ]; then
                    image_address="$image_name"
                else
                    image_address="$DOCKER_REGISTRY_DOWNLOAD$image_name"
                fi
                docker image pull "$image_address" | tee -a $LOG_FILE
                docker tag "$image_address" "$image_name" | tee -a $LOG_FILE
                if [ -e "$IMAGE_FOLDER//$clean_image_name.tar" ]; then
                    custom_msg "$IMAGE_FOLDER//$clean_image_name.tar file already exists. Docker Image ($image_name) could not saved."
                else
                    docker save --output "$IMAGE_FOLDER//$clean_image_name.tar" "$image_name" | tee -a "$LOG_IMAGE_FOLDER//docker-save-$clean_image_name.txt"
                    custom_msg "Docker Image ($image_name) saved to the location: $IMAGE_FOLDER//$clean_image_name.tar"
                fi
            fi
            # Docker Image Upload Operations
            if [ $upload_flag -eq 1 ]; then
                if [ -s "$IMAGE_FOLDER//$clean_image_name.tar" ]; then
                    if [ $local_flag -eq 1 ] || [ -z $DOCKER_REGISTRY_UPLOAD ] || [ $DOCKER_REGISTRY_UPLOAD == "\n" ] ||  [ $DOCKER_REGISTRY_UPLOAD == "\r" ]; then
                        image_address="$image_name"
                    else
                        image_address="$DOCKER_REGISTRY_UPLOAD$image_name"
                    fi
                    custom_msg "Docker Image Upload step started for ($IMAGE_FOLDER//$clean_image_name.tar)"
                    docker load --input "$IMAGE_FOLDER//$clean_image_name.tar" | tee -a "$LOG_IMAGE_FOLDER//docker-load-$clean_image_name.txt"
                    docker tag "$image_name" "$image_address" | tee -a "$LOG_IMAGE_FOLDER//docker-tag-$clean_image_name.txt"
                    if [ $local_flag -eq 0 ]; then
                        docker push "$image_address" | tee -a "$LOG_IMAGE_FOLDER//docker-push-$clean_image_name.txt"
                    fi
                else
                    custom_err "$IMAGE_FOLDER//$clean_image_name.tar file could not found!"
                fi
            fi
        fi
    done
else
    custom_err "Docker Image List file ($DOCKER_IMAGE_LIST_FILE) could not found."
    exit 1
fi

# Docker Image List
custom_msg "Docker Image List:"
docker image ls -a | tee -a $LOG_FILE

# Inter Field Seperator (IFS) Modification
IFS="$IFS_OLD"

# Main Folder Return
cd "$START_PATH"