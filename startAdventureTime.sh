#!/usr/bin/env bash

# Insert Project Name here
# Copyright (c) 2021
# Author: Nico Schwarz
# Github Repository: ( tbd  )
#
# Text adventure execution based on bash.
#
# This file is copyright under the version 1.2 (only) of the EUPL.
# Please see the LICENSE file for your rights under this license.

#
#
#

################################################################################
# Help Section                                                                 #
################################################################################
showHelp() {
# Display Help
        echo
        echo "Usage: startAdventureTime.sh [OPTIONS]"
        echo
        echo "Have fun. Loremipsum."
}

printLine(){
        while IFS= read -rn 1;do 
                printf "${color}""$REPLY"; 
                sleep 0.07; 
        done <<< "$1"
        printf "\n" 
}

hideinput() {
        if [ -t 0 ]; then
                stty -echo -icanon time 0 min 0
        fi
}

cleanup() {
        while read none; do :; done 
        if [ -t 0 ]; then
                stty sane
        fi
}

setColor(){
        # Examples:
        #red='\033[0;31m'
        #nc='\033[0m'
        # First column is implemented. Second not yet.
        #Black        0;30     Dark Gray     1;30
        #Red          0;31     Light Red     1;31
        #Green        0;32     Light Green   1;32
        #Brown/Orange 0;33     Yellow        1;33
        #Blue         0;34     Light Blue    1;34
        #Purple       0;35     Light Purple  1;35
        #Cyan         0;36     Light Cyan    1;36
        #Light Gray   0;37     White         1;37
        case $1 in
        nc)
                color='\033[0m'
        ;;
        red)
                color='\033[0;31m'
        ;;
        black)
                color='\033[0;30m'
        ;;
        green)
                color='\033[0;32m'
        ;;
        brown)
                color='\033[0;33m'
        ;;
        blue)
                color='\033[0;34m'
        ;;
        purple)
                color='\033[0;35m'
        ;;
        cyan)
                color='\033[0;36m'
        ;;
        gray)
                color='\033[0;37m'
        ;;  
        *) # unknown option
                color='\033[0m'
        ;;
        esac
}

startAdventure() {

        while [ $seqNumber -ne 666 ]; do
                runSequence "$seqNumber"
                printf "seqNr is: $seqNumber"
                getInput
        done
        printLine ". - = # # # # # # # # # = - ."
        printLine "  - = T H E       E N D = -"
        printLine "###########################"
        trap -- EXIT
        exit
}


runSequence() {
        # We disable the Keyboard input now. If we get accidental input while we are processing a sequence, 
        # it will end up in the input section below, and cause a load of error messages
        seqFlag="#$1:"
        hideinput
        # Finding the room $room and saving everything until the endFlag to variable roomContent
        # The awk defines the endFlag and seqFlag vars. Then iterates. If the first pattern match for roomFlag is found, it starts printing with the next line
        # when the endFlag is found, it sets found to 0 and stops printing, as 0 is equal to null in awk. By this it can print multiple occurences of the found blocks.
        # So be careful and use unique room numbers.
        sequenceContent=$(awk -v end="$endFlag" -v seq="$seqFlag" '$0 ~ end{found=0} {if(found) print} $0 ~ seq{found=1}' "$adventureFile")
        #awk -v a="$var1" -v b="$var2" 'BEGIN {print a,b}'
        printf "\n"
        printf "###########################\n"
        printf "\n"
        ((counter=0))
        while IFS= read -r line; do
                setColor "nc"
                #options="$line "
                # check if line starts with a trigger word for function calls or options
                #if [[ "$line" = \#Option* ]]; then
                 #       echo "Option is $line"
                #fi
                case $line in
                \#Option*)
                        echo "Found Option $line"
                        # Do not print options. Just save them for decision about what room to call next.
                        # The order of your options is important. It must always be a series from 1 to 9 in correct numerical order, starting with 1.
                        # as the number of your option adresses the field in an array which stores the corresponding next room number.
                        # fieldsArray=$(awk '{split($0,a,"-"); for (i=1; i<=NF; i++print a[1]; print $i}' <<< $line) does not work
                        # We define - as the Separator with FS=. After that we iterate over all elements of the input string, taking NF (number of fields) as the max
                        fieldsArray=($(awk 'BEGIN{FS="-"}{for (i=1; i<=NF; i++) print $i}' <<< "$line")) 
                        #echo "array is: ${fieldsArray[@]}"
                        if [ ${#fieldsArray[@]} -ne 3 ]; then
                                # If the Option line does not contain the three parts: #Option Keyword, Option Number, and target room Number, we have malformed input.
                                #log "$logRegularExecFileName" "ERROR" "Invalid format of input file content. Every line needs to contain a pair of folders, separated by one blank. Example: /home/myUser/myFolder /mnt/myTargetMount/targetFolder"
                                echo "Malformed option input found!."
                                exit 1
                        fi
                        # Filling the optionArray, which will be used to find the correct next room according to the given input.
                        optionArray[$counter]="${fieldsArray[2]}"
                        optionInputArray[$counter]="${fieldsArray[1]}"
                        ((++counter))
                ;;
                \#{*) # Handling any color flags which start with #${
                        # Using bash parameter extension here to cut the color name from the brackets.
                        # Might switch to a different implementation to be more portable
                        # Examples:
                        # ${MYVAR#pattern}      # delete shortest match of pattern from the beginning
                        # ${MYVAR##pattern}     # delete longest match of pattern from the beginning
                        # ${MYVAR%pattern}      # delete shortest match of pattern from the end
                        # ${MYVAR%%pattern}     # delete longest match of pattern from the end
                        # ${MYVAR:3}            # Remove the first three chars (leaving 4..end)
                        # ${MYVAR::3}           # Return the first three characters
                        # ${MYVAR:3:5}          # The next five characters after removing the first 3 (chars 4-9)

                        colorInput=${line%\}*}
                        colorInput=${colorInput#\#\{}
                        #echo "color is: $colorInput"
                        setColor "$colorInput"
                        # Removing color code from line
                        line=$(sed 's/^.*}//' <<< "$line")
                        printLine "$line"
                ;;
                \#wait*) # Handling any wait flags
                        echo "Found wait flag" 
                        # example: #wait-9
                        # We split the input line at the - delimiter again
                        waitArray=($(awk 'BEGIN{FS="-"}{for (i=1; i<=NF; i++) print $i}' <<< "$line")) 
                        # now we check if the second array field is an integer. It must be an integer and it must be at the second field of the array.
                        regex='^[0-9]+$'
                        if [[ ${waitArray[1]} =~ $regex ]] ; then
                                # If we confirmed that the field contains an integer, we wait for this time in seconds.
                               sleep "${waitArray[1]}"
                        fi
                ;;
                *) # unknown option
                        printLine "$line"
                ;;
                esac
        done < <(printf "%s\n" "$sequenceContent")
        # Now we enable the keyboard input again, as we are asking for user input next.
        #read buf
        #read -t .1 -n 1000 buf
       # stty sane
        # OK. output is completely finished now and options are loaded. We wait for user input now.
        # Flag which will switch to true later, if the input validation is passed
        correctInput="false"
        # optionNumberInput stores the input of the user. It is reset to "" here.
        optionNumberInput=""
        # The regular expression that defines the first check for valid input. We accept Integer values 1-9 with 1 character length to adress the given options.
        re='^[1-9]+$'
        while [[ "$correctInput" != "true" ]]; do
                # Waiting for user input
                cleanup
                read -n 1 -p "Respond: " optionNumberInput
                printf "\n" 
                hideinput
                # Check if input var is a valid option. Integer between 0-9. All other inputs are invalid.
                if [[ "$optionNumberInput" =~ $re ]] ; then
                        #echo "got integer"
                        # Next we check if the number is less or equal the array size of possible options. 
                        # If it is less or equal, that means we have a corresponding field in the array. 
                        # If it is bigger, it means there is no option in the array for the given optionInput.
                        if [ "$optionNumberInput" -le  "${#optionArray[@]}" ]; then
                                # as bash arrays are zero indexed, we need to lower the number by 1
                                echo "got less than array fields"
                                compareInput=$optionNumberInput
                                ((--optionNumberInput))
                                # check if the input corresponds to a field in the option array, which has the same content (must exist and not be null)
                                # We verify that there is a correct option really present at the given number in the array. 
                                # E.g. if the convention about option ordering has been violated, there might be a 3 in the field at position 1. 
                                # If this happens we have a malformed option dialog, and the logic will not work out.
                                if [ "${optionInputArray[$optionNumberInput]}" -eq "$compareInput" ]; then
                                        # check if the input has a corresponding sequence in the adventure file.
                                        # The target sequence number must exist in the adventure file.
                                        # For Debugging purpose: echo "GOT: ${optionArray[$optionNumberInput]} \n"
                                        grep "^#${optionArray[$optionNumberInput]}:" "$adventureFile" > /dev/null
                                        rc=${PIPESTATUS[0]}
                                        if [ "$rc" -eq "0" ]; then
                                                correctInput="true"
                                                echo "Input is: $optionNumberInput"
                                        else
                                                printf "The chosen option does not exist in the adventure input file, even though it is a correct formatted option. Exiting."
                                                exit 1
                                        fi 
                                else 
                                        # In this case the optionInput and the Option number in the array at the corresponding array position do not match.
                                        # That means the option which will take effect for the given input will be a wrong one. We must exit, as this seems to be an error in the input file.
                                        printf "Malformed Option Input found! Input does not match Option ID. Game logic violation. Exiting."
                                        exit 1
                                fi
                        fi
                fi
                # If all checks have been passed, and we did not exit 1 here, the correctInput flag should be true.
                # If it is not true, one of the above checks for valid input have been failed, and the user is asked again to enter a valid input.
                if [[ "$correctInput" != "true" ]]; then
                        printLine  "I do not understand. Please tell me which option number you mean."
                fi
        done
        cleanup
        seqNumber=${optionArray[$optionNumberInput]}
}

getInput() {
        echo "testInput"
}
checkFileContent() {
        # Checking and validating input
        # Now checking if the source paths exist
        # We only check the source paths. Non existant target paths will be created later anyway.
        #for i in "${sourceDirectoryArray[@]}"; do
        #        timestamp=$(date +%Y%m%d-%H:%M:%S)
                # echo "i is $i"
        #        if [ -d "$i" ]; then
        #                log "$logRegularExecFileName" "INFO" "Successfully checked existence of input folder: $i."
        #        else
        #                log "$logRegularExecFileName" "ERROR" "Directory $i does not exist. Please check your input file. Specifying an input file with correct source and target folders is mandatory."
        #                exit 1
        #        fi
        #done
        echo "test"
}
# Starting to parse input parameters and performing input validation
# Reading and parsing the arguments and setting flags to influence the script behaviour later.
while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h | --help)
                showHelp
                exit 0
                ;;
        -p | --path) # specifies input file path
                filepath="$2"

                # First we check if the file exists
                if [[ -f "$filepath" ]]; then
                        # If the file exists, we read its contents.
                        #getFileContent
                        echo "test"
                else
                        #log "$logRegularExecFileName" "ERROR" "The filepath '$filepath' specified with the -p|--path parameter does not exist."
                        #exit 1
                        echo "test"
                fi
                shift # past argument
                shift # past value
                ;;
        *) # unknown option
                printf "Unknown input parameter %s. \nUsage: \n" "$1" >&2
                showHelp
                exit 1
                ;;
        esac
done

trap cleanup EXIT
trap hideinput CONT
trap '' INT TERM
hideinput
# Initializing room number 1 as starting point at the beginning.
endFlag="#:"
adventureFile="/home/code/dev/textAdventure/adventure.txt"
declare -a optionArray
# initializing color variable with code for "no color"
color='\033[0m'
# Initializing sequence Number, as this is a global variable in this script.
seqNumber="1"
#log "$logRegularExecFileName" "INFO" "Input filepath validated: $filepath and successfully extracted data."
# Now we validate the content and checking for the existance of the source folders
#checkFileContent
startAdventure
