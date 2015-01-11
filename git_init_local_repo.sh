#!/bin/bash

git init
git config --local user.name "rawmind"
git config --local user.email git.feedback.rawmind@gmail.com
git remote add origin https://rawmind@github.com/rawmind/${PWD##*/}
touch .gitignore
git add .gitignore
