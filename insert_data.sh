#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n~~ Insert data from csv file~~\n"
echo "$($PSQL "truncate table teams, games")"
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if (( YEAR == 'year' ))
  then
    continue
  fi

  # Get team_id for WINNER
  WINNER_TEAM_ID="$($PSQL "select team_id from teams where name='$WINNER'")"
  # If not found
  if [[ -z $WINNER_TEAM_ID ]]
  then
    # Create new team
    INSERT_WINNER_TEAM_RESULT="$($PSQL "insert into teams(name) values('$WINNER')")"
    echo $INSERT_WINNER_TEAM_RESULT
    # Get team_id for newly created team
    WINNER_TEAM_ID="$($PSQL "select team_id from teams where name='$WINNER'")"
  fi  

  # Get team_id for OPPONENT
  OPPONENT_TEAM_ID="$($PSQL "select team_id from teams where name='$OPPONENT'")"
  if [[ -z $OPPONENT_TEAM_ID ]]
  then
    # Create new team
    INSERT_OPPONENT_TEAM_RESULT="$($PSQL "insert into teams(name) values('$OPPONENT')")"
    echo $INSERT_OPPONENT_TEAM_RESULT
    # Get team_id for newly created team
    OPPONENT_TEAM_ID="$($PSQL "select team_id from teams where name='$OPPONENT'")"
  fi

  INSERT_GAME_RESULT="$($PSQL "insert into games(
      year, round, winner_id, opponent_id, winner_goals, opponent_goals
    ) VALUES (
      $YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS
    )
  ")"
  echo INSERT_GAME_RESULT
done < games.csv