SUCCESS=${1:-none}

echo "Script stdout: Running with input \"$SUCCESS\"..."

if [ "$SUCCESS" = "success" ]; then
  echo "Script stdout: Success!"
else
  >&2 echo "Script stderr: Fail!"
  exit 1
fi
