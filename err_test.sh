SUCCESS=${1:-none}

echo "This is running with input: \"$SUCCESS\"..."

if [ "$SUCCESS" = "success" ]; then
  echo "Success!"
else
  >&2 echo "Fail!"
  exit 1
fi
