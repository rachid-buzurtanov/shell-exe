date=$(date +%d-%m-%Y-%H:%M)

path=$(echo $0 | rev | cut -c 13- | rev)

last $1 | grep tty | wc -l > $path/number_connection-$date
tar -cf $path/Backup/number_connection-$date.tar $path/number_connection-$date --force-local
