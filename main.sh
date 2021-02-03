#!/bin/bash

source $HOME/.deploy/.env
source $HOME/.deploy/.formatting

source $HOME/.deploy/functions.sh

prod=""

clear

header

maestroInstall

menuProd