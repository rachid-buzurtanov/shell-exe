if [ $# -ne 3 ]; then
    echo "Usage: $0 <nombre1> <opération> <nombre2>"
    exit 1
fi

nombre1="$1"
operation="$2"
nombre2="$3"

if [ "$operation" != "+" ] && [ "$operation" != "-" ] && [ "$operation" != "/" ]; then
    echo "Opération non valide : $operation"
    exit 1
fi

resultat=$(bc -l <<< "$nombre1 $operation $nombre2")

echo "$resultat"
