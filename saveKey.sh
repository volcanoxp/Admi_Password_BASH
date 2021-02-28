#!/bin/bash

#Author: Jose Galarza (aka Volcanoxp) 

#Colores
endColour='\033[0m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[1;32m'
WHITE='\033[0;37m'
YELLOW='\033[0;33m'

function ctrl_c(){
	echo -e "Saliendo"
	exit 1
}

trap ctrl_c SIGINT


########################################
#################TABLA##################

data=$(cat dato.txt 2> /dev/null ) 

#Función que devuele el máximo espaciado que ocupa una columna
function max_value_column(){
    local position=$1

    local max_value=0

    for line in $data; do

        #primer elemento de cada linea
        local column=$(echo $line | tr '_' ' ' | awk "{print \$$position}")

        local number_char=$(echo $column | wc -L)

        if (( number_char >= max_value )); then
            max_value=$number_char
        fi
    done

    get_max_value_column=$max_value

    return 0
}

#Función que indica cuantos elementos se tiene por fila
function number_elements(){
    local line_1=$(echo $data | awk '{print $1}' | head -n 1)
    get_number_elements=$(echo $line_1 | tr '_' '\n' | grep '' -c)
    return 0
}

#Función que genera el marco del ancho de la tabla
function generate_border_table(){
    number_elements
    for pos in $(seq 1 $get_number_elements); do
        max_value_column $pos
        largo=$(eval "printf "%0.s-" {1..$get_max_value_column}")
        largo_x="$largo_x+$largo"
    done
    largo_x="$largo_x+"
    return 0
}

#Función que devuelve el elemento tabulado
function espacios(){
    local num_Espacios=$1
    local letra=$2
    local sp=" "

    for number in $(seq 1 $num_Espacios); do
        letra="$letra$sp"
    done
    get_letra_sp=$(echo "$letra")
    return 0
}

#Función para generar la tabla
function make_table(){
    generate_border_table

    for row in $(seq 1 $(echo $data | tr ' ' '\n' | wc -l)); do

        echo -e "${GREEN}$largo_x${endColour}"

        for i in $(seq 1 $get_number_elements); do
            element=$(echo $data | awk "{print \$$row}" | tr '_' ' ' | awk "{print \$$i}")
            number_element=$(echo $element | wc -L)
            max_value_column $i

            if [ $number_element != $get_max_value_column ]; then
                diferencia=$(( $get_max_value_column - $number_element ))

                espacios $diferencia $element

                echo -e -n "${GREEN}|${endColour}$get_letra_sp"
            else
                echo -e -n "${GREEN}|${endColour}$element"
            fi
        done
        echo -e "${GREEN}|${endColour}"

    done
    echo -e "${GREEN}$largo_x${endColour}"
    return 0
}

#######################################


function helpPanel(){

	echo -e "\n\t${RED}Uso de ./saveKey${endColour}\n"
	echo -e "\t${WHITE}[-h]${endColour}\t\t${GREEN}Mostrar este panel de ayuda${endColour}"
	echo -e "\t${WHITE}[-s]${endColour}\t\t${GREEN}Estar en modo guardar${endColour}"
	echo -e "\t\t\tEjemplo:\t${BLUE}./saveKey -u Username -p 12345 -k gmail.com -s${endColour}"
	echo -e "\t\t\t\t\t${BLUE}./saveKey -u Username -g -k gmail.com -s${endColour}"
	echo -e "\t${WHITE}[-l]${endColour}\t\t${GREEN}Lista todos los usuarios guardados${endColour}"
	echo -e "\t\t\tEjemplo:\t${BLUE}./saveKey -l${endColour}"		
	echo -e "\t${WHITE}[-u]${endColour}\t\t${GREEN}Usuario${endColour}"
	echo -e "\t${WHITE}[-p]${endColour}\t\t${GREEN}Password${endColour}"
	echo -e "\t${WHITE}[-k]${endColour}\t\t${GREEN}Link${endColour}"
	echo -e "\t${WHITE}[-g]${endColour}\t\t${GREEN}Genera un password${endColour}\n"
	exit 1
}

function save(){

	if [ ! -f ./dato.txt ]; then
		touch dato.txt
		echo "Username_Password_Link" >> dato.txt
	fi

	if [[ $state_Password_G -eq 0 ]]; then
		PASSWORD=$PASSWORD_G
	fi
	echo -e ""$USERNAME"_"$PASSWORD"_"$LINK"" >> dato.txt
}

state_Password_G=1
function generatePassword(){
	PASSWORD_G=$(echo "`date`$RANDOM" | rev | base64)
	state_Password_G=0
}


parameter_counter=0; while getopts "shlu:p:k:g" arg; do
	case $arg in
		h) helpPanel;;
		s) save; let parameter_counter+=1;;
		l) make_table; let parameter_counter+=1;;
		u) USERNAME=$OPTARG; let parameter_counter+=1;;
		p) PASSWORD=$OPTARG; let parameter_counter+=1;;
		k) LINK=$OPTARG; let parameter_counter+=1;;
		g) generatePassword; let parameter_counter+=1;;
	esac
done

shift $((OPTIND-1))

if [ $parameter_counter -eq 0 ]; then
	helpPanel
fi

