#!/bin/sh

set -e

# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

# install hexo env
npm install hexo-cli -g
npm install hexo-deployer-git --save
npm install gulp-cli -g

# deployment
if [ "$INPUT_COMMIT_MSG" = "none" ]
then
    hexo clean
    hexo generate
    if [ -n "$INPUT_GULP" ] &&  [ "$INPUT_GULP" = "true" ]
    then
      gulp
    fi
    hexo deploy
elif [ "$INPUT_COMMIT_MSG" = "" ] || [ "$INPUT_COMMIT_MSG" = "default" ]
then
    # pull original publish repo
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo clean
    hexo generate
    if [ -n "$INPUT_GULP" ] &&  [ "$INPUT_GULP" = "true" ]
    then
      gulp
    fi
    hexo deploy
else
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo clean
    hexo generate
    if [ -n "$INPUT_GULP" ] &&  [ "$INPUT_GULP" = "true" ]
    then
      gulp
    fi
    hexo deploy -m "$INPUT_COMMIT_MSG"
fi

echo ::set-output name=notify::"Deploy complate."
