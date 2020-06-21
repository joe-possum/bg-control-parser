#! /bin/bash

function parser_completion
{
    COMMANDS="ota average-rssi get set gpio-disabled gpio-pushpull"
    PARAMETERS="pa-mode pa-input tx-power em2-debug sleep-clock-accuracy connection-interval adv-interval adv-length"
    COUNT=${#COMP_WORDS[@]}
#    echo COUNT=${COUNT}
#    for (( i=0 ; i < ${COUNT} ; i++ ))
#    do
#	echo "COMP_WORDS["${i}"] = '"${COMP_WORDS[${i}]}
#    done
    CURRENT=${COMP_WORDS[$[COUNT - 1]]}
    PREV=${COMP_WORDS[$[COUNT - 2]]}
    #echo "CURRENT: '"${CURRENT}"'"
    #echo "PREV: '"${PREV}"'"
    case ${PREV} in
	average-rssi)
	    COMPREPLY=(15)
	    ;;
	get)
	    COMPREPLY=($(compgen -W "DCDC EMU GPIO" ${CURRENT}))
	    ;;
	set)
	    COMPREPLY=($(compgen -W "${PARAMETERS}" ${CURRENT}))
	    ;;
	*)
	    COMPREPLY=($(compgen -W "${COMMANDS}" ${CURRENT}))
	    ;;
    esac
    #echo "COMPREPLY='"${COMPREPLY}"'"
}

complete -F parser_completion parser.exe
