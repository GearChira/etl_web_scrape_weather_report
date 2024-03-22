#! /bin/bash

# create a datestamped filename for the raw weather data:
today=$(date +%Y%m%d)
weather_report=raw_data_$today

# download today's weather report from wttr.in:
city=Bangkok
curl wttr.in/$city --output $weather_report

# extract all lines containing temperatures from the weather report and write to file
grep °C $weather_report>temperatures.txt

# extract the current temperature 
obs_tmp=$(head -1 temperatures.txt | tr -s " " | xargs | rev | cut -d " " -f2 | rev)

# extract the forecast for noon tomorrow
fc_tmp=$(head -3 temperatures.txt | tail -1 | tr -s " " | xargs | cut -d "C" -f2 | rev | cut -d " " -f2 | rev)

# use command substitution to store the current day, month, and year in corresponding shell variables:
hour=$(TZ='Asia/Bangkok' date +%H)
day=$(TZ='Asia/Bangkok' date +%d)
month=$(TZ='Asia/Bangkok' date +%m)
year=$(TZ='Asia/Bangkok' date +%Y)

# create a tab-delimited record
record=$(echo -e "$year\t$month\t$day\t$hour\t$obs_tmp\t$fc_tmp")

# append the record to rx_poc.log to keep track of the scheduled cron job
echo $record>>rx_poc.log

# crontab setting to perform daily ETL at noon
# crontab -e
# 0 12 * * * /dirname/rx_poc.sh