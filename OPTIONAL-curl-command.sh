#!/bin/bash
#
# Global variables 
#
VERSION="BETA 1.0, this script is an OPTIONAL way to create GitLab CE CI/CD protected variables for this application"
#
WARNING_MESSAGE="WARNING There is no warrantee on this script, use this script at your own risk"
# 
GITLAB_HOST="http://maingitlab.pilon.org"
#
INFORMATION_MESSAGE="This script has not been optimized"
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
# ++++
#
# ---- start of function (s) section -----
#
# script_introduction
#
function script_introduction {
   echo "++++++++++++++++++++++++"
   echo 
   echo "This script reflects a way to create GitLab CI/CD protected variables"
   echo "in a semi-autmated fashion, when dealing with user and password "
   echo "in the main GitLab pipeline file (.gitlab-ci.yml)"
   echo 
   echo  "GitLab documenation that maybe of some interest"
   echo  "https://docs.gitlab.com/ee/api/project_level_variables.html"
   echo 
   echo "The private & protected variables are defined within "\""settings"\"" , "\""CI/CD"\"", "\""variables"\""" 
   echo  "on the left hand side of the GitLab GUI for the specific project." 
   echo 
   echo  "Project ID is ia available by this GitLab internal variable \$CI_PROJECT_ID = <PROJECT ID> below" 
   echo  "of by looking at the project itself (3 square dots on the top left cornner of the project)"
   echo 
   echo "The key here is the project id of the project that needs to be identified prior to performing this post command"
   echo  "curl --request POST "\""http://maingitlab.pilon.org/api/v4/projects/<PROJECT ID>/variables"\""" 
   echo 
   echo  "-------- test 1 account / user specific , since he is the owner of this repo and solution -------------------"
   echo  "The private GitLab token is the one generate within the specific account in GitLab , under user "\""Edit profile"\""" 
   echo  "and "\""Access tokens"\"".  When add new token, select the api option" 
   echo 
   #echo  "An easy what to find the project id, execute the curl command below and replace the <user_id> with the user GitLab short account name"
   #echo  "curl --header "\""PRIVATE-TOKEN: <your-access-token>"\"" "\""http://maingitlab.pilon.org/api/v4/users/<user_id>/projects"\"" | jq '.[] | {id, name, path_with_namespace, web_url}'"
   #echo 
   #echo "Example and replacing the <user_id> with account short name test3"
   #echo  "curl --header "\""PRIVATE-TOKEN: <TOKEN> \"" "\""http://maingitlab.pilon.org/api/v4/users/test3/projects"\"" | jq '.[] | {id, name, path_with_namespace, web_url}'"
   echo 
   echo -e "${BOLD}${CYAN} $VERSION ${NC}"
   echo 
   echo -e "${BOLD}${CYAN} $WARNING_MESSAGE ${NC}"
   echo
   echo -e "${BOLD}${CYAN} $INFORMATION_MESSAGE ${NC}"
   echo 
}
#
#
# ************************************************************
# get_jfrog_registry_info
#
function get_frog_registry_info {
# 
  echo 
  echo -e "${CYAN} Before we start to do anything ...  ${NC}"  
  echo -e "${CYAN} We need to collect username / password to be able pull down the docker image needed from JFROG CONTAINER registry ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"

  read -p "
             JFROG Container Registry username to be used  ?
             Please enter your response " RESP_JFROG_CONTAINER_REGISTRY_USERNAME

 if [ "$RESP_JFROG_CONTAINER_REGISTRY_USERNAME" ==  "" ] ; then
    echo -e "${RED} main mongodb instance administrator username value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0
 else
    JFROG_CONTAINER_REGISTRY_USERNAME=$RESP_JFROG_CONTAINER_REGISTRY_USERNAME
 fi 
 
  read -s -p "
             JFROG Container Registry password to be used  ?
             (Password characters will not be displayed) 
             Please enter your response  " RESP_JFROG_CONTAINER_REGISTRY_PASSWORD

 if [ "$RESP_JFROG_CONTAINER_REGISTRY_PASSWORD" == "" ] ; then
    echo -e "${RED} main mongodb instance administrator password value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0    
 else
    JFROG_CONTAINER_REGISTRY_PASSWORD=$RESP_JFROG_CONTAINER_REGISTRY_PASSWORD
 fi 

 echo -e "${CYAN}"
 read -s -p "             Please RE-Enter the passsord " PASSW1CHECK
 echo -e "${NC}"

 if [[ $PASSW1CHECK = "" ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi

 if [[ $RESP_JFROG_CONTAINER_REGISTRY_PASSWORD != $PASSW1CHECK ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi
}
#
# ************************************************************
# get_mongodb_adm_info
#
function get_mongodb_adm_info {
#
  echo ""
  echo -e "${CYAN} We need to collect the main mongodb username and password for the mongodb instance ${NC}"
  echo -e "${CYAN} Consult with your mongodb ${BOLD}administrator${NC}${CYAN} for this information ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
#
  read -p "
             main mongodb administrator username to be used  ?
             Please enter your response " RESP_MONGODB_ADM_USERNAME

 if [ "$RESP_MONGODB_ADM_USERNAME" ==  "" ] ; then
    echo -e "${RED} main mongodb instance administrator username value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0
 else
    MONGODB_ADM_USER=$RESP_MONGODB_ADM_USERNAME
 fi 
# 
  read -s -p "
             main mongodb instance administrator password ?
             (Password characters will not be displayed) 
             Please enter your response  " RESP_MONGODB_ADM_PASSW

 if [ "$RESP_MONGODB_ADM_PASSW" == "" ] ; then
    echo -e "${RED} main mongodb instance administrator password value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0    
 else
    MONGODB_ADM_PASSWORD=$RESP_MONGODB_ADM_PASSW
 fi 

 echo -e "${CYAN}"
 read -s -p "             Please RE-Enter the passsord " PASSW1CHECK
 echo -e "${NC}"

 if [[ $PASSW1CHECK = "" ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi

 if [[ $RESP_MONGODB_ADM_PASSW != $PASSW1CHECK ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi
}
#
# ************************************************************
# get_mongodb_app_info
#
function get_mongodb_app_info {
#
  echo ""
  echo -e "${CYAN} We need to collect the  mongodb username and password for the application will be using ${NC}"
  echo -e "${CYAN}${BOLD} for user / account X , note about user test1 as there is "DEV" and "PROD" application references ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
#
  read -p "
             mongodb application username  ?
             Please enter your response " RESP_MONGODB_APP_USERNAME

 if [ "$RESP_MONGODB_APP_USERNAME" ==  "" ] ; then
    echo -e "${RED} mongodb Development application username value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0
 else
    MONGODB_APP_USERNAME=$RESP_MONGODB_APP_USERNAME
 fi 
# 
  read -s -p "
             mongodb Development application password?
             (Password characters will not be displayed)  
             Please enter your response  " RESP_MONGODB_APP_PASSW

 if [ "$RESP_MONGODB_APP_PASSW" == "" ] ; then
    echo -e "${RED} mongodb DEvelopment application password value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0    
 else
    MONGODB_APP_PASSWORD=$RESP_MONGODB_APP_PASSW
 fi 

 echo -e "${CYAN}"
 read -s -p "             Please RE-Enter the passsord " PASSW1CHECK
 echo -e "${NC}"

# echo "$RESP_MONGODB_APP_PASSW, $PASSW1CHECK"

 if [[ $PASSW1CHECK = "" ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi

 if [[ $RESP_MONGODB_APP_PASSW != $PASSW1CHECK ]]; then
     echo

     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi
}
#
# ************************************************************
# get_mongodb_prod_app_info
#
function get_mongodb_prod_app_info {
#
  echo ""
  echo -e "${CYAN} We need to collect the  mongodb username and password for the PRODUCTION application will be using ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
#
  read -p "
             mongodb PRODUCTION application username  ?
             Please enter your response " RESP_MONGODB_PROD_APP_USERNAME

 if [ "$RESP_MONGODB_PROD_APP_USERNAME" ==  "" ] ; then
    echo -e "${RED} mongodb PRODUCTION application username value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0
 else
    MONGODB_PROD_APP_USERNAME=$RESP_MONGODB_PROD_APP_USERNAME
 fi 
# 
  read -s -p "
             mongodb PRODUCTION application password?
             (Password characters will not be displayed)  
             Please enter your response  " RESP_MONGODB_PROD_APP_PASSW

 if [ "$RESP_MONGODB_PROD_APP_PASSW" == "" ] ; then
    echo -e "${RED} mongodb PRODUCTION application password value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0    
 else
    MONGODB_PROD_APP_PASSWORD=$RESP_MONGODB_PROD_APP_PASSW
 fi 

 echo -e "${CYAN}"
 read -s -p "             Please RE-Enter the passsord " PASSW1CHECK
 echo -e "${NC}"

 # echo "$RESP_MONGODB_PROD_APP_PASSW, $PASSW1CHECK"

 if [[ $PASSW1CHECK = "" ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi

 if [[ $RESP_MONGODB_PROD_APP_PASSW != $PASSW1CHECK ]]; then
     echo

     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi
}
#
# ************************************************************
# get_mongodb_staging_info
#
function get_mongodb_staging_info {
#
  echo ""
  echo -e "${CYAN} We need to collect the mongodb username and password the application will be using in staging ${NC}"
  echo -e "${CYAN} Consult with your mongodb ${BOLD}administrator${NC}${CYAN} for this information ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
#
  read -p "
             mongodb staging application username  ?
             Please enter your response " RESP_MONGODB_STAGING_APP_USERNAME

 if [ "$RESP_MONGODB_STAGING_APP_USERNAME" ==  "" ] ; then
    echo -e "${RED} mongodb staging application username  value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0
 else
    MONGODB_STAGING_APP_USERNAME=$RESP_MONGODB_STAGING_APP_USERNAME
 fi 
# 
  read -s -p "
             mongodb staging application password ?
             (Password characters will not be displayed)
             Please enter your response  " RESP_MONGODB_STAGING_APP_PASSW

 if [ "$RESP_MONGODB_STAGING_APP_PASSW" == "" ] ; then
    echo -e "${RED} mongodb application password value can not be empty ${NC}"
    echo ""
    echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
    echo ""
    exit 0    
 else
    MONGODB_STAGING_APP_PASSWORD=$RESP_MONGODB_STAGING_APP_PASSW
 fi 

 echo -e "${CYAN}"
 read -s -p "            Please RE-Enter the passsord " PASSW1CHECK
 echo -e "${NC}"

 if [[ $PASSW1CHECK = "" ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi

 if [[ $RESP_MONGODB_STAGING_APP_PASSW != $PASSW1CHECK ]]; then
     echo
     echo -e "${NC}${BOLD}Password don't match exiting the script ${NC}" 
     exit 1
 fi
}
#
# ************************************************************
# get_gitlab_user_token
#
function get_gitlab_user_token {
#
#
  echo ""
  echo -e "${CYAN} We need to collect the GitLab TOKEN for the targeted user / account ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"

#
  read -p "
             GitLab TOKEN for the targeted account 
             Please enter your response " RESP_GITLAB_TOKEN

 if [ "$RESP_GITLAB_TOKEN" ==  "" ] ; then
   echo -e "${RED} GitLab TOKEN value can not be empty ${NC}"
   echo ""
   echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
   echo ""
   exit 0
 else
    GITLAB_TOKEN=$RESP_GITLAB_TOKEN
 fi 
}
#
# ************************************************************
# get_gitlab_project_id 
#
function get_gitlab_project_id {
#
#
  echo ""
  echo -e "${CYAN} We need to collect the GitLab project ID for this project ${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
#
  read -p "
             GitLab Project ID for this project 
             Please enter your response " RESP_GITLAB_PROJECT_ID

 if [ "$RESP_GITLAB_PROJECT_ID" ==  "" ] ; then
   echo -e "${RED} GitLab Project ID value can not be empty ${NC}"
   echo ""
   echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
   echo ""
   exit 0
 else
    PROJECT_ID=$RESP_GITLAB_PROJECT_ID
 fi 
}
#
# ************************************************************
# get_microk8s_jfrog_token
#
function get_microk8s_jfrog_token {
#
#
  echo ""
  echo -e "${CYAN} In support of Microk8s pulling the docker image directly from JFROG Registry${NC}"
  echo -e "${CYAN} we need to collect the JFROG TOKEN to be authorized to pull down the docker image${NC}"
  echo -e "${CYAN} that will be required latter in this script ${NC}"
#
  read -p "
             JFROG TOKEN for this project 
             Please enter your response " RESP_JFROG_REGISTRY_TOKEN

 if [ "$RESP_JFROG_REGISTRY_TOKEN" ==  "" ] ; then
   echo -e "${RED} JFROG Registry TOKEN value can not be empty ${NC}"
   echo ""
   echo -e "${CYAN} Please re-execute this script: $0 ${NC}"
   echo ""
   exit 0
 else
    JFROG_REGISTRY_TOKEN=$RESP_JFROG_REGISTRY_TOKEN
 fi 
}
#
# ************************************************************
# Activities for user test1
#
function action_for_account_user_test1 {

     echo 
     echo -e "${CYAN} Need to collect information for the account / user "\""test1"\"", and there should be 11 variables ${NC}"
     echo -e "${CYAN} And since this the primary user / account owner of the solution ${NC}"
     echo -e "${CYAN} more variables are need to support development, staging and production activities ${NC}"
     
     get_frog_registry_info 
     get_mongodb_adm_info
     get_mongodb_prod_app_info
     get_mongodb_app_info
     get_gitlab_user_token
     get_gitlab_project_id
     get_mongodb_staging_info
     get_microk8s_jfrog_token
#
#set -o xtrace
#
# -------- account / user test1 specific -------------------
#  the private token is the one generate within the this specific GitLab account 
#
# troubleshooting section
# set -o xtrace
#
#echo "PROJECT_ID ==> $PROJECT_ID"
#echo "GITLAB_TOKEN ==> $GITLAB_TOKEN"
#echo "JFROG_CONTAINER_REGISTRY_USERNAME ==> $JFROG_CONTAINER_REGISTRY_USERNAME" 
#echo "JFROG_CONTAINER_REGISTRY_PASSWORD ==> $JFROG_CONTAINER_REGISTRY_PASSWORD" 
#echo "MONGODB_ADM_USER for the mongodb instance  ==> $MONGODB_ADM_USER"
#echo "MONGODB_ADM_PASSWORD for the mongodb instance ==> $MONGODB_ADM_PASSWORD"
#echo "MONGODB_APP_USERNAME for the application ==> $MONGODB_APP_USERNAME"
#echo "MONGODB_APP_PASSWORD for the application ==> $MONGODB_APP_PASSWORD"
#echo "MONGODB_STAGING_APP_USERNAME ==> $MONGODB_STAGING_APP_USERNAME"
#echo "MONGODB_STAGING_APP_PASSWORD for the staging application ==> $MONGODB_STAGING_APP_PASSWORD"
#echo "JFROG_REGISTRY_TOKEN ==> $JFROG_REGISTRY_TOKEN" 
#echo
#
 read -p "
             All the information required has been collected for the account / user test1, do you want to continue ?
             Please enter your response (Y/N) default: [N] " RESP
 if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo " "
                echo -e "${CYAN} Continuing ... with this script: $0 ${NC}"  
 else
                echo ""
                echo -e "${CYAN} Answer was $RESP, please re-execute this script: $0 ${NC}"
                echo ""
                exit 0
 fi 

echo 
echo "Variables that should be pushed to GitLab for the user "\""test1"\"" and targeted project" 
#
#
# Common for all in order to pull down docker images from JFROG Container Registry
#
echo 
echo -e "${BOLD}Variable 1 -  JFROG_REGISTRY_USER${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_USER" \
  --data "value=$JFROG_CONTAINER_REGISTRY_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_USER" | jq 

echo 
echo -e "${BOLD}Variable 2 - JFROG_REGISTRY_PASSWORD${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_PASSWORD" \
  --data "value=$JFROG_CONTAINER_REGISTRY_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_PASSWORD" | jq 
echo
echo -e "${BOLD}Variable 3 - TEST1_MONGO_APP_DB_USER${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST1_MONGO_APP_DB_USER" \
  --data "value=$MONGODB_APP_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST1_MONGO_APP_DB_USER" | jq 

echo
echo -e "${BOLD}Variable 4 - TEST1_MONGO_APP_DB_PASS${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST1_MONGO_APP_DB_PASS" \
  --data "value=$MONGODB_APP_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST1_MONGO_APP_DB_PASS" | jq 
#
echo
echo -e "${BOLD}Variable 5 - PRODUCTION_MONGO_APP_DB_USER${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=PRODUCTION_MONGO_APP_DB_USER" \
  --data "value=$MONGODB_PROD_APP_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=PRODUCTION_MONGO_APP_DB_USER" | jq 

echo
echo -e "${BOLD}Variable 6 - PRODUCTION_MONGO_APP_DB_PASS${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=PRODUCTION_MONGO_APP_DB_PASS" \
  --data "value=$MONGODB_PROD_APP_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=PRODUCTION_MONGO_APP_DB_PASS" | jq 
#
# Given test1 is the repo owner, and the only one that staging should be run against
#
echo
echo -e "${BOLD}Variable 7 - STAGING_MONGO_APP_DB_USER{NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=STAGING_MONGO_APP_DB_USER" \
  --data "value=$MONGODB_STAGING_APP_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=STAGING_MONGO_APP_DB_USER" | jq 

echo
echo -e "${BOLD}Variable 8 - STAGING_MONGO_APP_DB_PASS{NC}"   

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=STAGING_MONGO_APP_DB_PASS" \
  --data "value=$MONGODB_STAGING_APP_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=STAGING_MONGO_APP_DB_PASS" | jq 

# -------- common for all accounts given we are creating separate databases off the same mongodb instance  -------------------
#  the private token is the one generate within the this specific GitLab account 

echo
echo -e "${BOLD}Variable 9 - MONGO_ADMIN_DB_USER${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_USER" \
  --data "value=$MONGODB_ADM_USER" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_USER"  | jq 

echo
echo -e "${BOLD}Variable 10 - MONGO_ADMIN_DB_PASS${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_PASS" \
  --data "value=$MONGODB_ADM_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_PASS" | jq 

#  Requirement for Microk8s, to directly pull the docker image from JFROG Registry 

echo
echo -e "${BOLD}Variable 11 - PRODUCTION_MICROK8S_JFROG_TOKEN${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=PRODUCTION_MICROK8S_JFROG_TOKEN" \
  --data "value=$JFROG_REGISTRY_TOKEN" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=PRODUCTION_MICROK8S_JFROG_TOKEN" | jq

  echo
  echo 
  echo 
  echo -e " ${CYAN}Confirm the required variables are now in the GitLAb specific project for account / user ${BOLD}test1${NC}"
  echo -e " ${CYAN} user "\""Settings"\"", "\""CI/CD"\"" and "\""Variables"\"" on the left hand side of the GitLab GUI for the specific project.${NC}"
  echo
}
#
# ************************************************************
# Activities for user test2
#
function action_for_account_user_test2 {

     echo -e "${CYAN} Need to collect information for the account / user "\""test2"\"", and there should be 6 variables ${NC}"

     get_frog_registry_info 
     get_mongodb_adm_info
     get_mongodb_app_info
     get_gitlab_user_token
     get_gitlab_project_id
#
#set -o xtrace
#
# -------- account / user test2 specific -------------------
#  the private token is the one generate within the this specific GitLab account 

read -p "
             All the information required has been collected for account / user test2, do you want to continue ?
             Please enter your response (Y/N) default: [N] " RESP
 if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo " "
                echo -e "${CYAN} Continuing ... with this script: $0 ${NC}"  
 else
                echo ""
                echo -e "${CYAN} Answer was $RESP, please re-execute this script: $0 ${NC}"
                echo ""
                exit 0
 fi 
echo 
echo "Variables that should be pushed to GitLab for the user "\""test2"\"" and targeted project"
#
#
# Common for all in order to pull down docker images from JFROG Container Registry
#
echo 
echo -e "${BOLD}Variable 1 -  JFROG_REGISTRY_USER${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_USER" \
  --data "value=$JFROG_CONTAINER_REGISTRY_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_USER" | jq

echo 
echo -e "${BOLD}Variable 2 - JFROG_REGISTRY_PASSWORD${NC}"   

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_PASSWORD" \
  --data "value=$JFROG_CONTAINER_REGISTRY_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_PASSWORD" | jq

echo
echo -e "${BOLD}Variable 3 - TEST2_MONGO_APP_DB_USER${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST2_MONGO_APP_DB_USER" \
  --data "value=$MONGODB_APP_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST2_MONGO_APP_DB_USER" | jq

echo
echo -e "${BOLD}Variable 4 - TEST2_MONGO_APP_DB_PASS${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST2_MONGO_APP_DB_PASS" \
  --data "value=$MONGODB_APP_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST2_MONGO_APP_DB_PASS" | jq

# -------- common for all accounts given we are creating separate databases  -------------------
#  the private token is the one generate within the this specific GitLab account 

echo
echo -e "${BOLD}Variable 5 - MONGO_ADMIN_DB_USER${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_USER" \
  --data "value=$MONGODB_ADM_USER" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_USER" | jq

echo
echo -e "${BOLD}Variable 6 - MONGO_ADMIN_DB_PASS${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_PASS" \
  --data "value=$MONGODB_ADM_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_PASS" | jq
  echo
  echo 
  echo 
  echo -e " ${CYAN}Confirm the required variables are now in the GitLAb specific project for account / user ${BOLD}test2${NC}"
  echo -e " ${CYAN} user "\""Settings"\"", "\""CI/CD"\"" and "\""Variables"\"" on the left hand side of the GitLab GUI for the specific project.${NC}"
  echo
}
#
# ************************************************************
# Activities for user test3
#
function action_for_account_user_test3 {

     echo -e "${CYAN} Need to collect information for the account / user "\""test3"\"", and there should be 4 variables ${NC}"   

     get_frog_registry_info      
     get_mongodb_adm_info
     get_mongodb_app_info
     get_gitlab_user_token
     get_gitlab_project_id
#
#set -o xtrace
#
# -------- account / user test3 specific -------------------
#  the private token is the one generate within the this specific GitLab account 
 read -p "
             All the information required has been collected for account / user test3, do you want to continue ?
             Please enter your response (Y/N) default: [N] " RESP
 if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo " "
                echo -e "${CYAN} Continuing ... with this script: $0 ${NC}"  
 else
                echo ""
                echo -e "${CYAN} Answer was $RESP, please re-execute this script: $0 ${NC}"
                echo ""
                exit 0
 fi 

echo 
echo "Variables that should be pushed to GitLab for the user "\""test3"\"" and targeted project"
#
echo 
echo -e "${BOLD}Variable 1 -  CI_JFROG_REGISTRY_USER${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_USER" \
  --data "value=$JFROG_CONTAINER_REGISTRY_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_USER" | jq

echo 
echo -e "${BOLD}Variable 2 - CI_FROG_REGISTRY_PASSWORD${NC}"   

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_PASSWORD" \
  --data "value=$JFROG_CONTAINER_REGISTRY_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_PASSWORD" | jq

echo
echo -e "${BOLD}Variable 3 - TEST3_MONGO_APP_DB_USER${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST3_MONGO_APP_DB_USER" \
  --data "value=$MONGODB_APP_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST3_MONGO_APP_DB_USER" | jq

echo
echo -e "${BOLD}Variable 4 - TEST3_MONGO_APP_DB_PASS${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST3_MONGO_APP_DB_PASS" \
  --data "value=$MONGODB_APP_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST3_MONGO_APP_DB_PASS" | jq 

# -------- common for all accounts given we are creating separate databases  -------------------
#  the private token is the one generate within the this specific GitLab account 

echo
echo -e "${BOLD}Variable 5 - MONGO_ADMIN_DB_USER${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_USER" \
  --data "value=$MONGODB_ADM_USER" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_USER" | jq

echo
echo -e "${BOLD}Variable 6 - MONGO_ADMIN_DB_PASS${NC}"  

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_PASS" \
  --data "value=$MONGODB_ADM_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_PASS" | jq
  echo
  echo 
  echo 
  echo -e " ${CYAN}Confirm the required variables are now in the GitLAb specific project for account / user ${BOLD}test3${NC}"
  echo -e " ${CYAN} user "\""Settings"\"", "\""CI/CD"\"" and "\""Variables"\"" on the left hand side of the GitLab GUI for the specific project.${NC}"
  echo
}
#
# ************************************************************
# Activities for user test4
#
function action_for_account_user_test4 {     
   
     echo -e "${CYAN} Need to collect information for the account / user "\""test4"\"", and there should be 4 variables ${NC}"

     get_frog_registry_info 
     get_mongodb_adm_info
     get_mongodb_app_info
     get_gitlab_user_token
     get_gitlab_project_id
#
#set -o xtrace
#
# -------- account / user test4 specific -------------------
#  the private token is the one generate within the this specific GitLab account 
#
# troubleshooting 
# set -o xtrace
#
 read -p "
             All the information required has been collected for account / user test4, do you want to continue ?
             Please enter your response (Y/N) default: [N] " RESP
 if [ "$RESP" = "Y" ] || [ "$RESP" = "y" ] ; then
                echo " "
                echo -e "${CYAN} Continuing ... with this script: $0 ${NC}"  
 else
                echo ""
                echo -e "${CYAN} Answer was $RESP, please re-execute this script: $0 ${NC}"
                echo ""
                exit 0
 fi 

echo 
echo "Variables that should be pushed to GitLab for the user "\""test3"\"" and targeted project"

#
echo 
echo -e "${BOLD}Variable 1 -  JFROG_REGISTRY_USER${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_USER" \
  --data "value=$JFROG_CONTAINER_REGISTRY_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_USER" | jq

echo 
echo -e "${BOLD}Variable 2 - JFROG_REGISTRY_PASSWORD${NC}" 

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=CI_JFROG_REGISTRY_PASSWORD" \
  --data "value=$JFROG_CONTAINER_REGISTRY_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=CI_JFROG_REGISTRY_PASSWORD"  | jq

echo
echo -e "${BOLD}Variable 3 - TEST4_MONGO_APP_DB_USER${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST4_MONGO_APP_DB_USER" \
  --data "value=$MONGODB_APP_USERNAME" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST4_MONGO_APP_DB_USER" | jq

echo
echo -e "${BOLD}Variable 4 - TEST4_MONGO_APP_DB_PASS${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=TEST4_MONGO_APP_DB_PASS" \
  --data "value=$MONGODB_APP_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=TEST4_MONGO_APP_DB_PASS" | jq

# -------- common for all accounts given we are creating separate databases  -------------------
#  the private token is the one generate within the this specific GitLab account 
echo
echo -e "${BOLD}Variable 5 - MONGO_ADMIN_DB_USER${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_USER" \
  --data "value=$MONGODB_ADM_USER" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_USER"  | jq

echo
echo -e "${BOLD}Variable 6 - MONGO_ADMIN_DB_PASS${NC}"

curl --request POST "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/variables" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "key=MONGO_ADMIN_DB_PASS" \
  --data "value=$MONGODB_ADM_PASSWORD" \
  --data "protected=false" \
  --data "masked=false" \
  --data "environment_scope=*" \
  --data "description=MONGO_ADMIN_DB_PASS" | jq
  echo
  echo 
  echo 
  echo -e " ${CYAN}Confirm the required variables are now in the GitLAb specific project for account / user ${BOLD}test4${NC}"
  echo -e " ${CYAN} user "\""Settings"\"", "\""CI/CD"\"" and "\""Variables"\"" on the left hand side of the GitLab GUI for the specific project.${NC}"
  echo
}
#
# help_menu_function
#
function help_menu_function() {
echo
echo -e "${BOLD}Please select one of the options as outlined below:${NC}"
echo
echo -e "      ${CYAN}${BOLD} It's important that the information entered matches what you previouly configured ${NC}"
echo -e "      ${CYAN}${BOLD} on the mongodb side and JFROG Registry side ${NC}"
echo -e "      ${CYAN}${BOLD} You may need to modify this script \$GITLAB_HOST global variable as it is hard-coded to $GITLAB_HOST${NC}"
echo
echo -e "      ${CYAN}option 1 - Create all required CI/CD variables needed by account / user "\""test1"\"" being the main repo owner ${NC}"
echo -e "      ${CYAN}option 2 - Create all required CI/CD variables needed by account / user "\""test2"\""${NC}"
echo -e "      ${CYAN}option 3 - Create all required CI/CD variables needed by account / user "\""test3"\""${NC}"
echo -e "      ${CYAN}option 4 - Create all required CI/CD variables needed by account / user "\""test4"\""${NC}"
echo -e "      ${CYAN}option 5 - Help ${NC}"
echo -e "      ${CYAN}option 6 - Exit this script ${NC}"
echo
}
#
function function_select_options {
   local PS3="What option to execute ([1-4] | [5 for help} | [6 to exit]) ? :  " 

   select choice_main_menu in action_for_account_user_test1  action_for_account_user_test2  action_for_account_user_test3  action_for_account_user_test4 help exit

   do  case  $choice_main_menu in
    action_for_account_user_test1) 
            action_for_account_user_test1
    			echo
			   read -p "[Hit Return] to return to the main menu option: " DUMMY_RESP
			   help_menu_function
            ;;
    action_for_account_user_test2) 
            action_for_account_user_test2
    			echo
			   read -p "[Hit Return] to return to the main menu option: " DUMMY_RESP
			   help_menu_function
            ;;
    action_for_account_user_test3) 
            action_for_account_user_test3
    			echo
			   read -p "[Hit Return] to return to the main menu option: " DUMMY_RESP
			   help_menu_function
            ;;                           
    action_for_account_user_test4) 
            action_for_account_user_test4
    			echo
			   read -p "[Hit Return] to return to the main menu option: " DUMMY_RESP
			   help_menu_function
            ;;
	 help) echo list of Options 
	       clear
		    script_introduction
          help_menu_function
          ;;
    exit) 	      
          break
          ;;
    esac
	PS3="What option to execute ([1-4] | [5 for help} | [6 to exit]) ? :  " 
done
}
#
# ---- end of function (s) section -----
#
#
# ++++
#
# main code section 
#
# ++++
#
clear
#
script_introduction
help_menu_function
function_select_options 
#
exit 
#



