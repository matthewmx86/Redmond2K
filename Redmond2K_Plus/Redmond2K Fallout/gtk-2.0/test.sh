if [ -z "$1" ]; then
  dir="$(pwd)"
else
  dir="$1"
fi

for i in $(ls $dir/*.png); do
convert $i -fuzz 15% -fill "#1e6019" -opaque "#808080" $i
done
