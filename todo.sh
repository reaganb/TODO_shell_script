#!/bin/bash

# variable definitions
USER_DIR="users"
INFOBOX=${INFOBOX=dialog}
TITLE="TODO LIST MANAGER"
X="10"
Y="20"
trap 'echo -e $"\nPlease exit the program properly..\n"' SIGINT SIGTERM

 
# function definitions - start

# Display an info box
funcDisplayInfoBox(){
	$INFOBOX --title "$1" --infobox "$2" "$3" "$4"
	sleep "$5"
	clear
}

# Displa a dialog menu
funcDisplayDialogMenu(){
	$INFOBOX --title "$1" --menu "$2" 15 45 4 1 "Yes" 2 "No" 2>choice.txt

}

# Update function
funcUpdateTODO(){
	UPDATE_NAME=$1
	FILE_NAME="${UPDATE_NAME}_TODO.txt"
	if [ ! -f "$USER_DIR/$FILE_NAME" ]; then
		echo "No record found for $UPDATE_NAME"
		sleep 2
	else
		TEMP_FILE="$USER_DIR/${FILE_NAME}.temp"
		if [ -f $TEMP_FILE ]; then
			rm $TEMP_FILE 
			touch $TEMP_FILE
		else
			touch $TEMP_FILE
		fi

		while read -r TODOS; do
			echo $TODOS | grep "DONE" > /dev/null
			if [ `echo $?` != "0" ]; then
				sleep 1.5
				funcDisplayDialogMenu "$TITLE" "$TODOS DONE?"
				case "`cat choice.txt`" in
				1)
					echo "${TODOS} DONE" >> $TEMP_FILE
					sleep 1.5
					;;
					
				*)
					echo "${TODOS}" >> $TEMP_FILE
					sleep 1.5 
					;;
					
				esac
			else
				echo "$TODOS" >> $TEMP_FILE 
			fi
		done < "$USER_DIR/$FILE_NAME"
		mv $TEMP_FILE "$USER_DIR/$FILE_NAME"
		if [ -f choice.txt ]; then
			rm choice.txt 
		fi
		sleep 1.5
	fi
}

# View function
funcViewTODO(){
	VIEW_NAME=$1
	FILE_NAME="${VIEW_NAME}_TODO.txt"
	if [ ! -f "$USER_DIR/$FILE_NAME" ]; then
		echo "No record found for $VIEW_NAME"
		sleep 2
	else
		echo "Viewing $VIEW_NAME record..."
		less "$USER_DIR/$FILE_NAME"
	fi
}

# Create and write function
funcCreateAndWriteTODO(){
	FILE_NAME=$1
	END=0
	COUNT=1
	while [ $END -eq 0 ]; do
		touch "$USER_DIR/$FILE_NAME"
		read -p "TODO $COUNT: " OUT
		echo "$COUNT $OUT" >> "$USER_DIR/$FILE_NAME"
		COUNT=`expr $COUNT + 1`
		echo ""
		read -p "ADD ANOTHER? [Y/N]: " ADD
		echo ""	
		if [ "$ADD" == "Y" ] || [ "$ADD" == "y" ]; then
			END=0
		else
			END=1
			echo "Going back to main menu..."	
			sleep 2
		fi
	done
}

# Create function
funcCreateTODO(){
	clear
	CREATE_NAME=$1
	FILE_NAME="${CREATE_NAME}_TODO.txt"
	if [ -f "$USER_DIR/$FILE_NAME" ]; then
		echo "Record already exist for $NAME"
		read -p "Overwrite? [Y/N]: " OVER_WRITE
		if [ $OVER_WRITE == "Y" ] || [ $OVER_WRITE == "y" ]; then
			echo "Overwriting record.."
			sleep 1
			rm "$USER_DIR/$FILE_NAME"
			funcCreateAndWriteTODO $FILE_NAME
		fi
			
	else
		echo "Creating record for $NAME.."
		sleep 1.5
		funcCreateAndWriteTODO $FILE_NAME
	fi
}

# Main function to call
funcMain(){
	clear

	rpm -q dialog &> /dev/null
	PKG_CHECK=`echo $?`

	if [ $PKG_CHECK != "0" ]; then
		echo "Dialog package is missing." 
		echo "Install it first before using the script."
		sleep 1.5

		funcDisplayInfoBox $TITLE "GOODBYE!!!" $X $Y "3"
		return 1
	fi

	if [ ! -d $USER_DIR ]; then
	mkdir $USER_DIR
	fi

	echo "TODO list manager program made using BASH scripting"
	echo "by Reagan Balongcas"
	echo ""
	echo "1. View your TODO list"
	echo "2. Create a new TODO list"
	echo "3. Update status of TODO list"
	echo "4. Exit"
	echo ""
	read -p "CHOICE: " CHOICE

	case $CHOICE in
	1)
		read -p "Your name: " NAME
		funcViewTODO $NAME
		;;
	2)
		read -p "Your name: " NAME
		funcCreateTODO $NAME
		;;
	3) 
		read -p "Your name: " NAME
		funcUpdateTODO $NAME
		;;
	4)

		funcDisplayInfoBox "$TITLE" "GOODBYE!!!" "$X" "$Y" "2"
		clear
		return 1
		;;	
	*)
		;;
	esac
}

# function definitions - end

# beginning of the script
funcDisplayInfoBox "$TITLE" "WELCOME!!!" "$X" "$Y" "2"
RUN_SCRIPT=0
while [ $RUN_SCRIPT -eq 0 ];
do
	funcMain
	RUN_SCRIPT=$?
done
