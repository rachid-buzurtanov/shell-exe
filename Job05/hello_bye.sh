
if [ $# -ne 1 ]; then
    echo "Usage: $0 <message>"
    exit 1
fi

message="$1"

if [ "$message" == "hello" ]; then
    echo "Bonjour, je suis un script !"
elif [ "$message" == "bye" ]; then
    echo "Au revoir et bonne journée !"
else
    echo "Message non reconnu : $message"
fi
