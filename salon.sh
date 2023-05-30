#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

PRINT_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  SERVICE_PROCESS

}

SERVICE_PROCESS() {

  read SERVICE_ID_SELECTED

  # if not a valid choice
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send user back to PRINT_MENU
    PRINT_MENU "That's not a valid choice."
  else
    # Find the service id
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # If service doesn't exist
    if [[ -z $SERVICE_ID_SELECTED ]]
    then
      # send user back to PRINT_MENU
      PRINT_MENU "I could not find that service. What would you like today?"
    else
      
      echo -e "\nWhat's your phone number?"

      # Read customer's phone number
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # If it doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # Ask the user for a name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        
        read CUSTOMER_NAME

        RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      # Ask the user for a service time
      echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed 's/ //')?"

      read SERVICE_TIME
      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # Register the appointment.
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a cut at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //')."
    fi
  fi

}

PRINT_MENU
