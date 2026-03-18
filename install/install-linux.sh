#!/bin/bash
########## XAB-TEMPLATE: INSTALL SCRIPT FOR LINUX SYSTEMS ##########

########## FINISH ##########
echo "#################### STARTING INSTALL ####################"

########## VARIABLES ##########
LINK="https://github.com/koalition-xab/xab-template.git"
DESTINATION="/home/$USER/.local/share/typst/packages/local/xab-template/"
VERSION="1.0.0"


########## SCRIPT ##########
git clone $LINK $DESTINATION$VERSION
cd xab-template
git submodule init
git submodule update

########## FINISH ##########
echo "#################### All done :) ####################"
