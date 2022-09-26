#!/bin/bash
PSQL="psql --username=freecodecamp dbname=salon --tuples-only -c";

echo -e "\n~~~~~ My Salon ~~~~~\n";


MAIN(){


if [[ $1 ]]
then
  echo -e "\n$1";
else
  echo -e "\nWelcome to my salone. How may I help you?"  
fi 
echo -e "\n1) Cut\n2) Color\n3) Style\n4) Exit";
read SERVICE_ID_SELECTED;

#if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
#then
#  echo "Not valid number"
#fi
case $SERVICE_ID_SELECTED in
1) CUT_MENU ;;
2) COLOR_MENU ;;
3) STYLE_MENU ;;
4) EXIT ;;
*) MAIN "I could not find that service. \nPlease pick a number from the list provided. \nWhat would you like today?" ;;
esac
}

VALIDATING(){
  ENTERED=0;
  SERVICE_TYPE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED");
  echo -e "What's your phone number?";
  read CUSTOMER_PHONE;
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' ")
  if [[ -z $CUSTOMER_NAME ]]
  then      
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      #echo -e "\nname: $CUSTOMER_PHONE"
      INSERT_NAME_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME' , '$CUSTOMER_PHONE')")          
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' ")  
  echo -e "What time would you like your $( echo $SERVICE_TYPE | sed -r 's/^ *//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g' )? example: 02:30 / 13:45 OR 5pm / 8am";
  read SERVICE_TIME;
  if [[ -z $SERVICE_TIME ]]
  then
    MAIN "Please suggest time for your $( echo $SERVICE_TYPE | sed -r 's/^ *//g')."
  else
    INSERT_APP_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')");
    ENTERED=1;
  fi
  
}


CUT_MENU(){

  VALIDATING ;
  if [ $ENTERED == 1 ]
  then 
    echo -e "\nI have put you down for a cut at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g' ).";
    EXIT
  fi  
}

COLOR_MENU(){

  VALIDATING ;
    if [ $ENTERED == 1 ]
  then 
    echo -e "\nI have put you down for a color at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g' )."
    EXIT
  fi  

}
STYLE_MENU(){

  VALIDATING ;
    if [ $ENTERED == 1 ]
  then 
    echo -e "\nI have put you down for a style at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g' )."
    EXIT
  fi  

}

EXIT(){
  echo -e "\nThank you for stopping by :)"
}

MAIN;