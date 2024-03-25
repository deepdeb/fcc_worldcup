#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Function to execute SQL commands using PSQL
execute_sql() {
  $PSQL "$1"
}

# Truncate games and teams tables
echo $(execute_sql "TRUNCATE TABLE games, teams")

# Read CSV file and process each line
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  # Check if the line is not a header
  if [[ $winner != "winner" ]]; then
    # Check if the winner team exists in the database
    team_a=$(execute_sql "SELECT name FROM teams WHERE name = '$winner'")
    if [[ -z $team_a ]]; then
      # If winner team doesn't exist, insert it into the teams table
      insert_team_a=$(execute_sql "INSERT INTO teams (name) VALUES ('$winner')")
      if [[ $insert_team_a == "insert 0 1" ]]; then
        echo "Inserted team $winner"
      fi
    fi
  fi

  # Similar operations for the opponent team
  if [[ $opponent != "opponent" ]]; then
    team_b=$(execute_sql "SELECT name FROM teams WHERE name = '$opponent'")
    if [[ -z $team_b ]]; then
      insert_team_b=$(execute_sql "INSERT INTO teams (name) VALUES ('$opponent')")
      if [[ $insert_team_b == "insert 0 1" ]]; then
        echo "Inserted team $opponent"
      fi
    fi
  fi

  # Insert game details into the games table
  if [[ $year != "year" ]]; then
    winner_id=$(execute_sql "SELECT team_id FROM teams WHERE name = '$winner'")
    opponent_id=$(execute_sql "SELECT team_id FROM teams WHERE name= '$opponent'")
    insert_game=$(execute_sql "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', '$winner_id', '$opponent_id', '$winner_goals', '$opponent_goals')")
    if [[ $insert_game == "insert 0 1" ]]; then
      echo "New game added: $year, $round, $winner_id vs $opponent_id, score $winner_goals : $opponent_goals"
    fi
  fi
done < games.csv