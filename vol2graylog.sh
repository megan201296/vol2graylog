#!/bin/bash

###############################################################
#               _ ____    ___                 _               #
#   /\   /\___ | |___ \  / _ \_ __ __ _ _   _| | ___   __ _   #
#   \ \ / / _ \| | __) |/ /_\/ '__/ _` | | | | |/ _ \ / _` |  #
#    \ V / (_) | |/ __// /_\\| | | (_| | |_| | | (_) | (_| |  #
#     \_/ \___/|_|_____\____/|_|  \__,_|\__, |_|\___/ \__, |  #
#                                       |___/         |___/   #
###############################################################

# get command line options 

while getopts d:i:g:v:p: var; do
  case $var in
    d) homeDir=$OPTARG ;;
    i) memImage=$OPTARG ;;
    g) graylog=$OPTARG ;;
    p) port=$OPTARG ;;
    v) volhost=$OPTARG ;;
  esac
done
shift $(( $OPTIND - 1 ))

# set require variables

caseDate=$(date +%F)
outputDir="$homeDir/output/$caseDate"

# Create output directory and subdirectories, remove existing directory if present

if [ ! -d $outputDir ]
then
  echo "Creating output directory..."
  mkdir -p $outputDir
else
  echo "Clearing existing directory..."
  rm -rf $outputDir
  echo "Creating output directory..."
  mkdir -p $outputDir
fi

# Run imageinfo plugin

vol.py -f $memImage imageinfo > $outputDir/imageinfo

# extract profile and kdbg from imageinfo outputDir

cat $outputDir/imageinfo | grep "Suggested Profile(s)" | awk '{print "Identified Profile: " $4}' | sed 's/,//'
volProfile=$(cat $outputDir/imageinfo | grep "Suggested Profile(s)" | awk '{print $4}' | sed 's/,//')

cat $outputDir/imageinfo | grep "KDBG" | awk '{print "KDBG Address: " $3}' | sed 's/,//'
addrKDBG=$(cat $outputDir/imageinfo | grep "KDBG" | awk '{print $3}' | sed 's/,//')
volKDBG=${addrKDBG%L}

# set array of plugins to be run

declare -a plugins=("hashdump" "autoruns" "hivelist" "psscan" "handles" "netscan" "ldrmodules" "psxview" "modscan" "apihooks" "cmdscan" "consoles" "svcscan" "filescan")

# run all plugins listed in the plugins array and send results to graylogs

for pluginCommand in ${plugins[@]}; do
     echo "Running $pluginCommand..."
     vol.py -f $memImage --profile=$volProfile $pluginCommand --kdbg=$volKDBG --output=json --output-file="$outputDir/$pluginCommand.txt"
     python3 ./vol2log/vol2log.py -host $graylog -port $port -file="$outputDir/$pluginCommand.txt" -plugin $pluginCommand -volhost $volhost
done

echo "All plugins have finished processing and results have been sent to Graylog."
