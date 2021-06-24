# Docker Image Carrier Script (DIC-Script)

DIC-Script can be used to archive (save) and load Docker images between different registry addresses in isolated networks. 
These Docker registries could be placed in different networks such as the internet and the corporate intranet and can be isolated in any way.

This script consists of two steps to deploy Docker Images between different artifact repositories or Docker registries. 

For the download (archive/save) step, DIC-Script downloads Docker images from defined Docker registry (artifact repository).

For the upload (load) step, DIC-Script uploads Docker images to a defined Docker registry (artifact repository).

Docker registry addresses and image lists are defined in the configuration files (application.config and docker-image-list.config).

The user can check and watch all processes from the prompt screen and also from the log.txt file. 
All prompt screen output logged to this file.

For Unix/Linux/Mac users:
```bash
./dic.sh -option(s) parameter 
```

For Windows Bash users: 
```bash
bash dic.sh -option(s) parameter 
```

Options: 
```bash
-c : Cleaning option set. All output folders and files will be removed! 
-d : Download option set. Defined Docker images will be downloaded to the local disk in the images folder. 
-h : Shows this Help message.
-l : Registry login option set. Docker Registry Login option set. Login information in the configuration file will be used. 
-r : Remove all Docker images option set. All Docker images in the local registry will be removed. Be careful with this option!
-u : Upload option set. Downloaded Docker images will be uploaded to given Docker registry.
-y : Yes to all for errors option set. Given errors will be neglected and the process will continue.
```

Example Parameter Usages:

The command prompt parameter read from the file [parameter].application.config in the conf folder.

```
local: Local Docker registry will be used. Do not use local for custom registry name in configuration file. This is reserved for local registry usage.

dockerhub : Custom DockerHub registry configuration file will be used.

registry-1 : Internet/Intranet Registry 1 configuration file will be used.

registry-2 : Internet/Intranet Registry 2 configuration file will be used.
```

Example Usages:
```bash
bash dic.sh -ydl dockerhub
bash dic.sh -yd dockerhub
bash dic.sh -dl dockerhub
bash dic.sh -d dockerhub
bash dic.sh -d local
--------------------------------
bash dic.sh -yul dockerhub
bash dic.sh -ul dockerhub
bash dic.sh -yu local
bash dic.sh -u local
--------------------------------
bash dic.sh -h
bash dic.sh -c
bash dic.sh -r
```
