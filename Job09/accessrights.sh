#!/bin/bash

# Définition des chemins des fichiers
CSV_FILE="./data/Shell_Userlist.csv"    # Chemin du fichier CSV contenant les informations sur les utilisateurs
LAST_MOD_FILE="./last_mod.txt"          # Chemin du fichier de suivi de la date de modification

# Vérification et installation d'inotify-tools si ce n'est pas déjà installé
if ! dpkg -l | grep -q "inotify-tools"; then
    sudo apt-get update
    sudo apt-get install -y inotify-tools
fi

# Fonction pour créer un utilisateur
create_user() {
    local id="$1"
    local prenom="$2"
    local nom="$3"
    local mdp="$4"
    local role="$5"
    
    # Vérifier si l'utilisateur existe déjà
    if id "$prenom$nom" &>/dev/null; then
        echo "L'utilisateur $prenom$nom existe déjà."
    else
        # Créer un utilisateur avec les informations spécifiées
        useradd -m -c "$prenom $nom" -p "$mdp" "$prenom$nom"
        
        # Si l'utilisateur est un administrateur, lui donner les permissions de super utilisateur
        if [ "$role" == "Admin" ]; then
            usermod -aG sudo "$prenom$nom"
        fi
        
        echo "Utilisateur $prenom$nom créé."
    fi
}

# Vérifier si le fichier de suivi de la date de modification existe
if [ -e "$LAST_MOD_FILE" ]; then
    last_mod=$(cat "$LAST_MOD_FILE")
else
    # Si le fichier de suivi n'existe pas, initialiser last_mod à 0
    last_mod=0
fi

# Créer une tâche cron pour surveiller les modifications du fichier CSV
(crontab -l 2>/dev/null; echo "* * * * * $(readlink -f "$0")") | crontab -

# Utiliser inotifywait pour surveiller les modifications du fichier CSV
while true; do
    inotifywait -e modify "$CSV_FILE"
    
    # Récupérer la date de modification actuelle du fichier CSV
    current_mod=$(stat -c %Y "$CSV_FILE")

    # Comparer la date de modification actuelle avec la date précédente
    if [ "$current_mod" -ne "$last_mod" ]; then
        echo "Le fichier CSV a été modifié. Relance du script..."
        
        # Mettre à jour la date de modification précédente avec la date actuelle
        echo "$current_mod" > "$LAST_MOD_FILE"
        
        # Lorsque le fichier CSV est modifié, relancer le script
        exec "$0"
    fi
done
