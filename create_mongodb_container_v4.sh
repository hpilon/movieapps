#!/bin/bash
#
#
VERSION="BETA 1.0 dev-mongo:8.0.4:6.0.2 mongodb hosted within docker containers with mongodb shard and replication set"
#  +++++++++++++
#
#  WARNING There is no warrantee on this script, use this script at your own risk
# 
#  This script has not been optimized
# 
#  This script is based on the content from - https://github.com/minhhungit/mongodb-cluster-docker-compose
# 
#  This script was adjusted for my personnel purpose, and feel free to make your own adjustments. 
#
# ++++++++++++++++++++++++
#
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BLACK='\033[0;30m'
BACKGROUNDWHITE='\033[0;47m'
BOLD='\033[1m'
REVERSED='\033[7m'
NC='\033[0m'
GREEN='\033[0;32m'
IRED='\033[0;91m'
URED='\033[4;31m'  
ORANGE='\033[38;5;214m'
YELLOW='\033[0,33m'
#
# uncomment the next line to enable full debugging
#set -o xtrace

# enable errorexit 
set -e
#
#
SOLUTION_HOME_DIR="/mongodb"
#
#
function get_mongodb_adm_user_password {
#
  echo ""
  echo -e "${CYAN} We need to collect the main admistrator username and password ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
  echo ""
#
  read -p "
             main mongodb administrator username  ?
             Please enter your response, default:[mongodb_adm] " RESP_MONGODB_ADM

 if [ "$RESP_MONGODB_ADM" ==  "" ] ; then
    MONGODB_ADM_USER="mongodb_adm"
 else
    MONGODB_ADM_USER=$RESP_MONGODB_ADM
 fi 
# 
  read -p "
             main mongodb administrator password ?
             Please enter your response,  default:[Password123!] " RESP_MONGODB_ADM_PASSW

 if [ "$RESP_MONGODB_ADM_PASSW" == "" ] ; then
    MONGODB_ADM_PASSWORD="Password123!"
 else
    MONGODB_ADM_PASSWORD=$RESP_MONGODB_ADM_PASSW
 fi 

  echo ""
  echo -e "${CYAN} main mongodb administrator username:${NC} ${BOLD} $MONGODB_ADM_USER ${NC}"
  echo -e "${CYAN} main mongodb administrator password:${NC} ${BOLD} $MONGODB_ADM_PASSWORD ${NC}"
  echo ""

read -p "
             Is the above information correct  ?
             Please enter your response (Y/N) default: [N] " RESP
if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo " "
                echo -e "${CYAN} Continuing ... with this script: $0 for the next phase ${NC}"  
else
  echo ""
  echo -e "${CYAN} Answer was $RESP, please re-execute this script: $0 ${NC}"
  echo ""
  exit 0
fi                
}
#
#
function clean_folder {
   #
   # disable errorexit 
   set +e
  #
  #
  cd $SOLUTION_HOME_DIR
  pwd
  #
  read -p "
             Are you sure you want to trigger this next action as this will destroy everything in the $SOLUTION_HOME_DIR subfolder ?
             Please enter your response (Y/N) default: [N] " RESP
if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo "Continuing ...  the clean function " 
   
  echo "---"
  echo " Performing rm -Rf $SOLUTION_HOME_DIR/mongodb_cluster_*" 
  rm -Rf $SOLUTION_HOME_DIR/mongodb_cluster_*
  
  if [ -d "$SOLUTION_HOME_DIR/scripts" ]; then
     echo "Deleting  $SOLUTION_HOME_DIR/scripts/*"
     rm -Rf $SOLUTION_HOME_DIR/scripts
  fi
  
  if [ -d "$SOLUTION_HOME_DIR/mongodb-build/" ]; then
     echo "Deleting  $SOLUTION_HOME_DIR/mongodb-build/"
     rm -Rf $SOLUTION_HOME_DIR/mongodb-build/
  fi
  
  ls -l 
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_router01_db and $SOLUTION_HOME_DIR/mongodb_cluster_router01_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_router01_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_router01_config
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_router02_db and $SOLUTION_HOME_DIR/mongodb_cluster_router02_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_router02_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_router02_config
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr01_db and $SOLUTION_HOME_DIR/mongodb_cluster_configsvr01_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr01_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr01_config
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr02_db and $SOLUTION_HOME_DIR/mongodb_cluster_configsvr02_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr02_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr02_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr03_db and $SOLUTION_HOME_DIR/mongodb_cluster_configsvr03_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr03_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_configsvr03_config 
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_a_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard01_a_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_a_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_a_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_b_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard01_b_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_b_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_b_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_c_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard01_c_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_c_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard01_c_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_a_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard02_a_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_a_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_a_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_b_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard02_b_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_b_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_b_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_c_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard02_c_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_c_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_c_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_a_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard03_a_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_a_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_a_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_b_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard03_b_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_b_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_b_config  
  #
  echo " Performing mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_c_db and $SOLUTION_HOME_DIR/mongodb_cluster_shard03_c_config"
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard03_c_db
  mkdir -p $SOLUTION_HOME_DIR/mongodb_cluster_shard02_c_config  
  echo
  echo " Performing chown -R mongodb:mongodb mongodb_cluster_* and  chmod -R 755 mongodb_cluster_*"  
  chown -R mongodb:mongodb mongodb_cluster_*
  chmod -R 755 mongodb_cluster_*

# enable errorexit 
set -e  

else 
    echo 
    echo -e "${ORANGE}Skipping recreating $SOLUTION_HOME_DIR subfolder${NC}"
fi
}
#
function create_docker-compose_file {
#
pwd
#
  read -p "
             Are you sure you want to trigger this action as this will re-create all required files including the docker-compose.yml file ?
             Please enter your response (Y/N default: [N]) " RESP
if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
   echo
   echo -e "${CYAN}Continuing ...  the create_docker-compose_file function ${NC}" 
#
#
echo 
echo -e "${CYAN}Creating the Dockerfile and required folders ... ${NC}" 
mkdir -p $SOLUTION_HOME_DIR/mongodb-build/
mkdir -p $SOLUTION_HOME_DIR/mongodb-build/auth
mkdir -p $SOLUTION_HOME_DIR/scripts/
#
echo
echo  -e "${CYAN}Performing chown -R mongodb:mongodb $SOLUTION_HOME_DIR/mongodb-build/ and  chmod -R 755 $SOLUTION_HOME_DIR/mongodb-build/${NC}" 
chown -R mongodb:mongodb $SOLUTION_HOME_DIR/mongodb-build/
chmod -R 755 $SOLUTION_HOME_DIR/mongodb-build/
#
echo
echo -e "${CYAN}Performing chown -R mongodb:mongodb $SOLUTION_HOME_DIR/scripts/ and  chmod -R 755 $SOLUTION_HOME_DIR/scripts/${NC}"
chown -R mongodb:mongodb $SOLUTION_HOME_DIR/scripts/
chmod -R 755 $SOLUTION_HOME_DIR/scripts/
#
# Let's go create the key file 
#
        create_mongodb_keyfile
#		
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/mongodb-build/Dockerfile file... ${NC}" 
tee $SOLUTION_HOME_DIR/mongodb-build/Dockerfile 1> /dev/null <<EOF
FROM mongo:8.0.4
# Set GLIBC_TUNABLES to disable rseq support
ENV GLIBC_TUNABLES=glibc.pthread.rseq=0
#
COPY /auth/mongodb-keyfile /data
#
RUN chmod 400 /data/mongodb-keyfile
RUN chown 999:999 /data/mongodb-keyfile
EOF
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/dev-init-configserver.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/dev-init-configserver.js 1> /dev/null <<EOF
#!/bin/bash
mongosh <<EOF
var config = {
        "_id": "rs-config-server",
        "configsvr": true,
        "version": 1,
        "members": [
                {
                        "_id": 0,
                        "host": "configsvr01:27017",
                        "priority": 1
                },
                {
                        "_id": 1,
                        "host": "configsvr02:27017",
                        "priority": 0.5
                },
                {
                        "_id": 2,
                        "host": "configsvr03:27017",
                        "priority": 0.5
                }
        ]
};
rs.initiate(config, { force: true });
EOF
# patch to add EOF value to the above file 
echo "EOF" >>$SOLUTION_HOME_DIR/scripts/dev-init-configserver.js
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/dev-init-shard01.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/dev-init-shard01.js 1> /dev/null <<EOF
#!/bin/bash
mongosh <<EOF
var config = {
    "_id": "rs-shard-01",
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "shard01-a:27017",
                        "priority": 1
        },
        {
            "_id": 1,
            "host": "shard01-b:27017",
                        "priority": 0.5
        },
        {
            "_id": 2,
            "host": "shard01-c:27017",
                        "priority": 0.5
        }
    ]
};
rs.initiate(config, { force: true });
EOF
# patch to add EOF value to the above file 
echo "EOF" >>$SOLUTION_HOME_DIR/scripts/dev-init-shard01.js
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/dev-init-shard02.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/dev-init-shard02.js 1> /dev/null <<EOF
#!/bin/bash
mongosh <<EOF
var config = {
    "_id": "rs-shard-02",
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "shard02-a:27017",
                        "priority": 1
        },
        {
            "_id": 1,
            "host": "shard02-b:27017",
                        "priority": 0.5
        },
        {
            "_id": 2,
            "host": "shard02-c:27017",
                        "priority": 0.5
        }
    ]
};
rs.initiate(config, { force: true });
EOF
# patch to add EOF value to the above file 
echo "EOF" >>$SOLUTION_HOME_DIR/scripts/dev-init-shard02.js
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/dev-init-shard03.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/dev-init-shard03.js 1> /dev/null <<EOF
#!/bin/bash
mongosh <<EOF
var config = {
    "_id": "rs-shard-03",
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "shard03-a:27017",
                        "priority": 1
        },
        {
            "_id": 1,
            "host": "shard03-b:27017",
                        "priority": 0.5
        },
        {
            "_id": 2,
            "host": "shard03-c:27017",
                        "priority": 0.5
        }
    ]
};
rs.initiate(config, { force: true });
EOF
# patch to add EOF value to the above file 
echo "EOF" >>$SOLUTION_HOME_DIR/scripts/dev-init-shard03.js
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/dev-init-router.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/dev-init-router.js 1> /dev/null <<EOF
sh.addShard("rs-shard-01/shard01-a:27017")
sh.addShard("rs-shard-01/shard01-b:27017")
sh.addShard("rs-shard-01/shard01-c:27017")
sh.addShard("rs-shard-02/shard02-a:27017")
sh.addShard("rs-shard-02/shard02-b:27017")
sh.addShard("rs-shard-02/shard02-c:27017")
sh.addShard("rs-shard-03/shard03-a:27017")
sh.addShard("rs-shard-03/shard03-b:27017")
sh.addShard("rs-shard-03/shard03-c:27017")
EOF
#
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/dev-auth.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/dev-auth.js 1> /dev/null <<EOF
#!/bin/bash
mongosh <<EOF
use admin;
db.createUser({user: "$MONGODB_ADM_USER", pwd: "$MONGODB_ADM_PASSWORD", roles: [{role: "root", db: "admin"}]})
exit;
EOF
# patch to add EOF value to the above file 
echo "EOF" >>$SOLUTION_HOME_DIR/scripts/dev-auth.js
#
echo 
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/scripts/disableTelemetry.js file... ${NC}" 
tee $SOLUTION_HOME_DIR/scripts/disableTelemetry.js 1> /dev/null <<EOF
mongosh <<EOF
use admin;
config.get('enableTelemetry');
disableTelemetry();
config.get('enableTelemetry');
exit;
EOF
# patch to add EOF value to the above file 
echo "EOF" >>$SOLUTION_HOME_DIR/scripts/disableTelemetry.js
#
#
echo
echo -e "${CYAN}Creating $SOLUTION_HOME_DIR/docker-compose.yml file... ${NC}" 
tee $SOLUTION_HOME_DIR/docker-compose.yml 1> /dev/null <<EOF
version: '3.8'
services:

## Router
  router01:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575
    container_name: router-01
    privileged: true  # Add this line
    command: mongos --port 27017 --configdb rs-config-server/configsvr01:27017,configsvr02:27017,configsvr03:27017 --bind_ip_all --keyFile /data/mongodb-keyfile
    ports:
      - 27117:27017
    restart: always
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_router01_db:/data/db
      - ./mongodb_cluster_router01_config:/data/configdb
  router02:
    #build: 
    # context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: router-02
    privileged: true  # Add this line	
    command: mongos --port 27017 --configdb rs-config-server/configsvr01:27017,configsvr02:27017,configsvr03:27017 --bind_ip_all --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_router02_db:/data/db
      - ./mongodb_cluster_router02_config:/data/configdb
    ports:
      - 27118:27017
    restart: always
    links:
      - router01

## Config Servers
  configsvr01:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575
    container_name: mongo-config-01 
    privileged: true  # Add this line	
    command: mongod --port 27017 --configsvr --replSet rs-config-server --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts 
      - ./mongodb_cluster_configsvr01_db:/data/db
      - ./mongodb_cluster_configsvr01_config:/data/configdb
    ports:
      - 27119:27017
    restart: always
    links:
      - shard01-a
      - shard02-a
      - shard03-a
      - configsvr02
      - configsvr03
  configsvr02:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575
    container_name: mongo-config-02
    privileged: true  # Add this line	
    command: mongod --port 27017 --configsvr --replSet rs-config-server --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_configsvr02_db:/data/db
      - ./mongodb_cluster_configsvr02_config:/data/configdb
    ports:
      - 27120:27017
    restart: always
  configsvr03:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: mongo-config-03 
    privileged: true  # Add this line	
    command: mongod --port 27017 --configsvr --replSet rs-config-server --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_configsvr03_db:/data/db
      - ./mongodb_cluster_configsvr03_config:/data/configdb
    ports:
      - 27121:27017
    restart: always


## Shards
  ## Shards 01
   
  shard01-a:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-01-node-a
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-01 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard01_a_db:/data/db
      - ./mongodb_cluster_shard01_a_config:/data/configdb
    ports:
      - 27122:27017
    restart: always
    links:
      - shard01-b
      - shard01-c
  shard01-b:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-01-node-b
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-01 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard01_b_db:/data/db
      - ./mongodb_cluster_shard01_b_config:/data/configdb
    ports:
      - 27123:27017
    restart: always
  shard01-c:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-01-node-c
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-01 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard01_c_db:/data/db
      - ./mongodb_cluster_shard01_c_config:/data/configdb
    ports:
      - 27124:27017
    restart: always

  ## Shards 02
  shard02-a:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-02-node-a
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-02 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard02_a_db:/data/db
      - ./mongodb_cluster_shard02_a_config:/data/configdb
    ports:
      - 27125:27017
    restart: always
    links:
      - shard02-b
      - shard02-c
  shard02-b:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-02-node-b
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-02 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard02_b_db:/data/db
      - ./mongodb_cluster_shard02_b_config:/data/configdb
    ports:
      - 27126:27017
    restart: always
  shard02-c:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-02-node-c
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-02 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard02_c_db:/data/db
      - ./mongodb_cluster_shard02_c_config:/data/configdb
    ports:
      - 27127:27017
    restart: always

  ## Shards 03
  shard03-a:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-03-node-a
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-03 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard03_a_db:/data/db
      - ./mongodb_cluster_shard03_a_config:/data/configdb
    ports:
      - 27128:27017
    restart: always
    links:
      - shard03-b
      - shard03-c
  shard03-b:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-03-node-b
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-03 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard03_b_db:/data/db
      - ./mongodb_cluster_shard03_b_config:/data/configdb
    ports:
      - 27129:27017
    restart: always
  shard03-c:
    #build: 
    #  context: ./mongodb-build
    image: dev-mongo:8.0.4
    #sysctls:
    #  - vm.max_map_count=1048575	
    container_name: shard-03-node-c
    privileged: true  # Add this line	
    command: mongod --port 27017 --shardsvr --replSet rs-shard-03 --keyFile /data/mongodb-keyfile
    volumes:
      - ./scripts:/scripts
      - ./mongodb_cluster_shard03_c_db:/data/db
      - ./mongodb_cluster_shard03_c_config:/data/configdb
    ports:
      - 27130:27017
    restart: always
  
EOF
# 
echo 
echo -e "Build the image first and push it to the docker register ..."
echo 
CURRENT_FOLDER=${pwd}
#
cd $SOLUTION_HOME_DIR/mongodb-build/
#
pwd
#
docker build -t dev-mongo:8.0.4 .
#  
docker images
#
cd $CURRENT_FOLDER
else 
    echo 
    echo -e "${ORANGE}Skipping re-creating the docker-compose.yml file ... ${NC}"
fi
}
#
function create_mongodb_keyfile {
   #

  read -p "
             Are you sure you want to trigger this action as this will re-create the keyfile  ?
             Please enter your response (Y/N) default: [N] " RESP
if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo  
                echo "Continuing ...  the clean function "    
                echo In the create_mongodb_keyfile function ...
                echo
  
#   rm mongodb-keyfile
   
#   rm /mongodb/mongodb-build/auth/mongodb-keyfile
   
   openssl rand -base64 756 > mongodb-keyfile
   
   pwd
      
   chown mongodb:mongodb mongodb-keyfile

    ls -l mongodb-keyfile

   cp mongodb-keyfile /mongodb/mongodb-build/auth/mongodb-keyfile
   chmod 400 /mongodb/mongodb-build/auth/mongodb-keyfile
   ls -l /mongodb/mongodb-build/auth/mongodb-keyfile
   
else 
    echo 
    echo -e "${ORANGE}Skipping recreating the create_mongodb_keyfile function${NC}" 
fi    
   
}
#
function create_docker_compose  {

  read -p "
             Are you sure you want to trigger this action as this will re-execute the docker compose command  ?
             Please enter your response (Y/N) default: [N] " RESP
if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo  
                echo -e "${CYAN}Continuing ...  the setting_mongodb function${NC} " 
				cd $SOLUTION_HOME_DIR
				docker compose up -d
				
else
                echo 
                echo -e "${ORANGE}Skipping action from the create_docker_compose function${NC}"
fi
}
#
#
function create_setting_mongodb  {

  read -p "
             Are you sure you want to trigger this action as this will destroy and reset the settings  ?
             Please enter your response (Y/N) default: [N] " RESP
if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo "Continuing ...  the create_setting_mongodb function " 
				echo
				echo -e "${GREEN}Doing docker-compose exec configsvr01 bash /scripts/dev-init-configserver.js and sleep 10 seconds${NC}"
				docker-compose exec configsvr01 bash "/scripts/dev-init-configserver.js" 
				wait_time=10
				wait_with_message
				echo
				echo -e "${GREENd}Doing docker-compose exec shard01-a bash /scripts/dev-init-shard01.js and sleep 10 seconds${NC}"
				docker-compose exec shard01-a bash "/scripts/dev-init-shard01.js"
				wait_time=10
				wait_with_message
				echo
				echo -e "${GREEN}Doing docker-compose exec shard02-a bash /scripts/dev-init-shard02.js and sleep 10 seconds${NC}"
                docker-compose exec shard02-a bash "/scripts/dev-init-shard02.js" 
				wait_time=10
				wait_with_message
				echo
				echo -e "${GREEN}Doing docker-compose exec shard03-a bash /scripts/dev-init-shard03.js and sleep 60 seconds${NC}"
                docker-compose exec shard03-a bash "/scripts/dev-init-shard03.js"
				wait_time=60
				wait_with_message
				echo				
				echo -e "${GREEN}Doing docker-compose exec router01 sh -c mongosh < /scripts/dev-init-router.js and sleep 10 seconds${NC}"
				docker-compose exec router01 sh -c "mongosh < /scripts/dev-init-router.js"
				wait_time=10
				wait_with_message
				echo
				echo -e "${GREEN}Doing docker-compose exec configsvr01 bash /scripts/dev-auth.js and sleep 10 seconds${NC}"
				docker-compose exec configsvr01 bash "/scripts/dev-auth.js"
				wait_time=10
				wait_with_message
				echo				
				echo -e "${GREEN}Doing docker-compose exec shard01-a bash /scripts/dev-auth.js and sleep 10 seconds${NC}"
                docker-compose exec shard01-a bash "/scripts/dev-auth.js"	
				wait_time=10
				wait_with_message
			  echo
				echo -e "${GREEN}Doing docker-compose exec shard02-a bash /scripts/dev-auth.js and sleep 10 seconds${NC}"												
                docker-compose exec shard02-a bash "/scripts/dev-auth.js"
				wait_time=10
				wait_with_message
			  echo			
				echo -e "${GREEN}Doing docker-compose exec shard03-a bash /scripts/dev-auth.js${NC} "
                docker-compose exec shard03-a bash "/scripts/dev-auth.js"
        wait_time=10
				wait_with_message
        echo 
			  echo -e "${BOLD} ++++ ${NC} "
        echo -e "${BOLD} Because this is development mongodb and using it for fun, no need to send mongodb Telemetry information${NC}"
				echo -e "${GREEN}And using docker exec XXXX bash /scripts/disableTelemetry.js command instead${NC} "
                docker exec shard-01-node-a bash "/scripts/disableTelemetry.js"  
                docker exec shard-01-node-b bash "/scripts/disableTelemetry.js"  
                docker exec shard-01-node-c bash "/scripts/disableTelemetry.js"    
                docker exec shard-02-node-a bash "/scripts/disableTelemetry.js"
                docker exec shard-02-node-b bash "/scripts/disableTelemetry.js"  
                docker exec shard-02-node-c bash "/scripts/disableTelemetry.js" 
                docker exec shard-03-node-a bash "/scripts/disableTelemetry.js"
                docker exec shard-03-node-b bash "/scripts/disableTelemetry.js"  
                docker exec shard-03-node-c bash "/scripts/disableTelemetry.js" 
                docker exec mongo-config-01 bash "/scripts/disableTelemetry.js"  
                docker exec mongo-config-02 bash "/scripts/disableTelemetry.js" 
                docker exec mongo-config-03 bash "/scripts/disableTelemetry.js"   
                docker exec router-01 bash "/scripts/disableTelemetry.js"  
                docker exec router-02 bash "/scripts/disableTelemetry.js"                                                                                         
        echo -e "${BOLD} ++++ ${NC} "      
        echo      
else
                echo
				echo -e "${ORANGE}Skipping action from the setting_mongodb function${NC}"
fi
}
#
function clean_mongodb  {

  read -p "
             Are you sure you want to trigger this action of ==> docker compose down --rmi all --remove-orphans  ?
             Please enter your response (Y/N) (default: [N]): " RESP

if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
    docker compose down --rmi all --remove-orphans
else
    echo 
    echo -e "${ORANGE}Skipping clean_mongodb function${NC}"
fi
}
#
function wait_with_message {
	echo -e "${ORANGE}waiting $wait_time seconds for next step ${NC}"
     i="0"
     while [ $i -lt $wait_time ]
      do
       sleep 1
       echo -n "."
       i=$[$i+1]
     done
    echo	 
}
#
#
# Main code area 
#
# let's make sure the /data folder exits else exit 
#
echo
echo -e "${GREEN}+++++++++++++${NC}"
echo
echo -e "${GREEN}$VERSION ${NC}"
echo
echo
echo -e "${GREEN}WARNING There is no warrantee on this script, use this script at your own risk${NC}"
echo
echo -e "${GREEN}This script has not been optimized${NC} ${BOLD}and should not be used in PRODUCTION${NC}"
echo
echo -e "${GREEN}This script is based on the content from - https://github.com/minhhungit/mongodb-cluster-docker-compose${NC}"
echo
echo -e "${GREEN}This script was adjusted for my personnel purpose, and feel free to make your own adjustments. ${NC}"
echo
#
get_mongodb_adm_user_password
#
echo " "
echo -e "${GREEN}++++++++++++++++++++++++${NC}"
echo " "
#
#
  read -p "
             Are you sure you want to continue with this script ?
             Please enter your response (Y/N) default: [N]: " RESP

if [ "$RESP" = "y" ] || [ "$RESP" = "Y" ] ; then

#
 if [ -d "$SOLUTION_HOME_DIR" ]; then
  echo " "  
  echo "The folder $SOLUTION_HOME_DIR exists, continuing ..."
	echo " "
	clean_mongodb

	clean_folder

  create_docker-compose_file

  create_docker_compose 

  create_setting_mongodb 
		
  echo 
	echo -e "${BOLD}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}"
	echo -e "${CYAN}There is a problem for the folder ownership if you do an ls -l${NC}"
  echo -e "${CYAN}based on mongodb user and group id return value within the container${NC}"
  echo -e "${CYAN}so you may need to change the mongodb id off the host running docker to match${NC}"
  echo -e "${CYAN}Or leave it as is , that's what I did${NC}"
	echo
	echo 
  echo -e "${CYAN}This is because when the container start the folder takes the owner of the ID of the account in the container running mongodb id${NC}"
  echo -e "${CYAN}you can confirm this by cat /etc/passwd off the host running docker${NC}"  	
  echo
	echo -e "${CYAN}Docker hostname:${NC} $(hostname) ${CYAN}mongodb id:${NC} $(id mongodb)"

	echo 
	echo -e "${CYAN}let go see the mongod id within the container${NC}"
	echo -e "${CYAN}Container hostname:${NC} $(docker exec -it router-01 sh -c "hostname")${NC}"
	echo -e "${CYAN}Container mongodb id:${NC} $(docker exec -it router-01 sh -c "/usr/bin/id mongodb")${NC}"
	echo -e "${CYAN}cat /etc/passwd | grep -i <the abobe uid> from the container to see which local account has it been assigned to already${NC}"
  echo -e "${CYAN}and it should match the folder $SOLUTION_HOME_DIR owner when doing ls -l${NC}"
	echo
  echo -e "${BOLD}++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++${NC}"
		
 else
  echo -e "${RED}This folder $SOLUTION_HOME_DIR was NOT found ${NC}"
	echo -e "${RED}It is imperative that this folder exist ${NC}"
  echo -e "${RED}Exiting the $0 script ${NC}"
	exit 0
 fi
fi
#
#
#
exit
