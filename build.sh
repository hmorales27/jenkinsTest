#!/bin/bash

##############################
# VARIABLES                  #
##############################

BUILDS_PATH="./Builds/"


GIT_BASE_URL="https://github.com/ElsevierTechnologyServices/"
GIT_PROJECT_NAME="JBSM-IOS-SWIFT"

GIT_LOCAL_PATH="$BUILDS_PATH$GIT_PROJECT_NAME"

GIT_PRODUCTION_BRANCH="master"
GIT_CERTIFICATION_BRANCH="certification"
GIT_DEVELOPMENT_BRANCH="development"

GIT_URL=$GIT_BASE_URL$GIT_PROJECT_NAME".git"
GIT_BRANCH=""

##############################
# SETUP                      #
##############################

mkdir $BUILDS_PATH

##############################
# ENVIRONMENT                #
##############################

echo "Which Environment Would You Like to Build?"
echo "(1) Development"
read ENVIRONMENT

if [ $ENVIRONMENT -eq 1 ] #Development
then
  GIT_BRANCH=$GIT_DEVELOPMENT_BRANCH
fi

##############################
# GITHUB                     #
##############################

echo "Do you want to clone the project? (if it doesn't already exist)"
echo "(1) Yes"
echo "(2) No"
read CLONE_PROJECT

cd ./Builds
pwd

if [ $CLONE_PROJECT -eq 1 ]
then
	rm -rf $GIT_PROJECT_NAME
	git clone $GIT_URL
fi

cd $GIT_PROJECT_NAME

git pull origin $GIT_BRANCH
git checkout $GIT_BRANCH

#fastlane beta