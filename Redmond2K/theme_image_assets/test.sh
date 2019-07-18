#!/bin/bash
bgcolor="#d4d0c8"
highlight="#FFFFFF"
shadow="#808080"
border="#000"
base="#fff"
fg="#000"
text="#000"
disabled_fg="#808080"

orig=$(pwd)
#if [ $(echo "$1" | grep "/") -lt 1 ]; then
#  dir="$1/"
#else
#  dir="$1"
#fi 
#cd $dir

if [ -z "$1" ]; then

for i in $(ls -d */ | grep -o .*[Aa-Zz]); do

cd $i

#compile images
if [ $(pwd | grep -ci "ins") -gt 0 ]; then
  convert *base.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" base.png
else
  convert *base.png -fuzz 15% -fill "$base" -opaque "#ff00fa" base.png
fi
convert *border.png -fuzz 15% -fill "$border" -opaque "#ff00fa" border.png
convert *shadow.png -fuzz 15% -fill "$shadow" -opaque "#ff00fa" shadow.png
convert *highlight.png -fuzz 15% -fill "$highlight" -opaque "#ff00fa" highlight.png
convert *background.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" background.png
convert *check.png -fuzz 15% -fill "$text" -opaque "#ff00fa" check.png
convert *_aa.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" aa.png
convert *_text.png -fuzz 15% -fill "$fg" -opaque "#ff00fa" text.png
convert *_text_disabled.png -fuzz 15% -fill "$disabled_fg" -opaque "#ff00fa" text_disabled.png

convert -background none -page +0+0 background.png -page +0+0 highlight.png \
-page +0+0 shadow.png -page 0+0 border.png -page +0+0 base.png -page +0+0 check.png \
-page +0+0 aa.png -page +0+0 text.png -page +0+0 text_disabled.png -layers flatten $i.png
#remove work files
mv $i.png ../assets/
rm shadow.png border.png highlight.png background.png base.png check.png aa.png
#return to directory
cd ..
done
cd assets

#compile arrows
mv arrow.png arrow_up.png
convert -rotate "90" arrow_up.png arrow_right.png
convert -rotate "90" arrow_right.png arrow_down.png
convert -rotate "90" arrow_down.png arrow_left.png

#compile all scrollbar buttons

convert -page +0+0 scrollbar_button.png -page +0+0 arrow_up.png -layers flatten scroll_up_button.png
convert -page +0+0 scrollbar_button.png -page +0+0 arrow_right.png -layers flatten scroll_right_button.png
convert -page +0+0 scrollbar_button.png -page +0+0 arrow_down.png -layers flatten scroll_down_button.png
convert -page +0+0 scrollbar_button.png -page +0+0 arrow_left.png -layers flatten scroll_left_button.png
rm scrollbar_button.png
convert -page +0+0 scrollbar_button_active.png -page +0+0 arrow_up.png -layers flatten scroll_up_button_active.png
convert -page +0+0 scrollbar_button_active.png -page +0+0 arrow_right.png -layers flatten scroll_right_button_active.png
convert -page +0+0 scrollbar_button_active.png -page +0+0 arrow_down.png -layers flatten scroll_down_button_active.png
convert -page +0+0 scrollbar_button_active.png -page +0+0 arrow_left.png -layers flatten scroll_left_button_active.png
rm scrollbar_button.png

#compile tabs
convert -flip tab.png tab_left.png
convert -flip tab_checked.png tab_left_checked.png
convert -flip tab_gap.png tab_gap_left.png
convert -rotate "90" tab_left.png tab_left.png
convert -rotate "90" tab_left_checked.png tab_left_checked.png
convert -rotate "90" tab_gap_left.png tab_gap_left.png
cp tab_gap_left.png tab_gap_right.png
convert -flip tab_bottom.png tab_right.png
convert -flip tab_bottom_checked.png tab_right_checked.png
convert -rotate "90" tab_right.png tab_right.png
convert -rotate "90" tab_right_checked.png tab_right_checked.png
mv tab.png tab_top.png
mv tab_checked.png tab_top_checked.png
cp tab_gap.png tab_gap_top.png
mv tab_gap.png tab_gap_bottom.png

#compile switch button
convert -background none -page +0+0 switch_button.png -page +0+0 switch_off.png -layers flatten switch.png
convert -background none -page +0+0 switch_button_ins.png -page +0+0 switch_off.png -layers flatten switch_ins.png
convert -background none -page +0+0 switch_button.png -page +0+0 switch_on.png -layers flatten switch_checked.png
convert -background none -page +0+0 switch_button_ins.png -page +0+0 switch_on.png -layers flatten switch_ins_checked.png
rm switch_off.png switch_on.png switch_button.png switch_button_ins.png
cd ..

else
  if [ "$1" = "-c" ]; then
    for i in $(ls -d */ | grep -o .*[Aa-Zz]); do
      rm "$i/$i.png"
      rm "$i/"*[0-9].png
      rm -rf assets/*
    done
  else
cd $1
if [ $(pwd | grep -ci "ins") -gt 0 ]; then
  convert *base.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" base.png
else
  convert *base.png -fuzz 15% -fill "$base" -opaque "#ff00fa" base.png
fi
convert *border.png -fuzz 15% -fill "$border" -opaque "#ff00fa" border.png
convert *shadow.png -fuzz 15% -fill "$shadow" -opaque "#ff00fa" shadow.png
convert *highlight.png -fuzz 15% -fill "$highlight" -opaque "#ff00fa" highlight.png
convert *background.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" background.png
convert *check.png -fuzz 15% -fill "$fg" -opaque "#ff00fa" check.png
convert *_aa.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" aa.png

convert -background none -page +0+0 background.png -page +0+0 highlight.png \
-page +0+0 shadow.png -page 0+0 border.png -page +0+0 base.png -page +0+0 check.png \
-page +0+0 aa.png -layers flatten $1.png
#remove work files
rm shadow.png border.png highlight.png background.png base.png check.png aa.png
#return to directory
cd ..

fi
fi

#gtk3 assets

cd assets
gtk3="../../gtk-3.0/assets/"
cp tab*.png $gtk3
cp toolbar.png $gtk3
cp scrollbar_trough.png $gtk3
cp radio*.png $gtk3
cp c_box*.png $gtk3
cp arrow*.png $gtk3
cp switch*.png $gtk3
cd ..