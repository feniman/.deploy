#!/bin/bash

source $HOME/.deploy/.env
source $HOME/.deploy/.formatting

source $HOME/.deploy/functions.sh

setMysqlParams

prod=""

clear

header

maestroInstall

menuProd