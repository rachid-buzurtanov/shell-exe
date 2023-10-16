#!/bin/bash

CSV_FILE="./data/Shell_Userlist.csv"    
LAST_MOD_FILE="./last_mod.txt"          

if ! dpkg -l | grep -q "inotify-tools"; then
    sudo apt-get update
    sudo apt-get install -y inotify-tools
fi


create_user() {
    local id="$1"
    local prenom="$2"
    local nom="$3"
    local mdp="$4"
    local role="$5"
    

    if id "$prenom$nom" &>/dev/null; then
        echo "L'utilisateur $prenom$nom existe déjà."
    else
       
        useradd -m -c "$prenom $nom" -p "$mdp" "$prenom$nom"
        
        if [ "$role" == "Admin" ]; then
            usermod -aG sudo "$prenom$nom"
        fi
        
        echo "Utilisateur $prenom$nom créé."
    fi
}


if [ -e "$LAST_MOD_FILE" ]; then
    last_mod=$(cat "$LAST_MOD_FILE")
else

    last_mod=0
fi

(crontab -l 2>/dev/null; echo "* * * * * $(readlink -f "$0")") | crontab -


while true; do
    inotifywait -e modify "$CSV_FILE"
    
    current_mod=$(stat -c %Y "$CSV_FILE")

    if [ "$current_mod" -ne "$last_mod" ]; then
        echo "Le fichier CSV a été modifié. Relance du script..."
        
        echo "$current_mod" > "$LAST_MOD_FILE"
        
        exec "$0"
    fi
done
