if [ -z "$1" ]; then
  dir="$(pwd)"
else
  dir="$1"
fi

for i in $(ls $dir/*.png); do
convert $i -fuzz 15% -fill "#d4d0c8" -opaque "#cdcac1" $i
done
