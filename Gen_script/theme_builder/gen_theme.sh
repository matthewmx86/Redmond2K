#!/bin/bash
. theme.conf
code=""

#Build config file
function gen_config {
  touch $themes_dir/"$theme_name"/settings.conf
  echo "Theme_name=$theme_name" >> $themes_dir/"$theme_name"/settings.conf
  echo "Window_FG_color=$fgcolor" >> $themes_dir/"$theme_name"/settings.conf
  echo "Window_BG_color=$bgcolor" >> $themes_dir/"$theme_name"/settings.conf
  echo "Base_BG_color=$basecolor" >> $themes_dir/"$theme_name"/settings.conf
  echo "Base_FG_color=$basefg" >> $themes_dir/"$theme_name"/settings.conf
  echo "Highlight_BG_color=$highlight" >> $themes_dir/"$theme_name"/settings.conf
  echo "Selected_BG_color=$selectedbg" >> $themes_dir/"$theme_name"/settings.conf
  echo "Selected_FG_color=$selectedtext" >> $themes_dir/"$theme_name"/settings.conf
  echo "Active_titlebar_color=$activetitle" >> $themes_dir/"$theme_name"/settings.conf
  echo "Active_titlebar_text_color=$activetitletext" >> $themes_dir/"$theme_name"/settings.conf
  echo "Inactive__titlebar_color=$inactivetitle" >> $themes_dir/"$theme_name"/settings.conf
  echo "Inactive__titlebar_text_color=$inactivetitletext" >> $themes_dir/"$theme_name"/settings.conf
}

#Regenerate theme from exisiting config file.
function theme_regen {
#Check if config file was specified
if [ -z "$config_file" ]; then
  echo "Error: No config file specified."
  echo "Now exiting."
  exit
fi
#If config file exists continue with operation.
if [ -e "$config_file" ]; then
theme_name=$(cat "$config_file" | grep -io Theme_name=.*[a0-z9] | grep -io =[a0-z9].* | grep -io [a-z0123456789].*)
fgcolor=$(cat "$config_file" | grep -io Window_FG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
bgcolor=$(cat "$config_file" | grep -io Window_BG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
basecolor=$(cat "$config_file" | grep -io Base_BG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
basefg=$(cat "$config_file" | grep -io Base_FG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
highlightcolor=$(cat "$config_file" | grep -io Highlight_BG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
selectedbg=$(cat "$config_file" | grep -io Selected_BG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
selectedtext=$(cat "$config_file" | grep -io Selected_FG_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
activetitle=$(cat "$config_file" | grep -io Active_titlebar_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
activetitletext=$(cat "$config_file" | grep -io Active_titlebar_text_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
inactivetitle=$(cat "$config_file" | grep -io Inactive__titlebar_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
inactivetitletext=$(cat "$config_file" | grep -io Inactive__titlebar_text_color="#".*[a0-f9] | grep -io "#"[a0-f9].*)
else
  echo "Error: Config file not found and '-r' option selected. Make sure you type the full path of the config file and use quotes."
  echo "Now exiting."
  exit
fi
}

#Convert hex to decimal for calculations.
function hex2rgb {
  a=0
  #strip "#" from hex code and change case.
  input=$(echo "${1^^}" | grep -o [Aa0-Ff9].*)
  a=0
  #Convert 3 didgit haxe codes to 6 digit codes.
  if [ $(echo "$input" | wc -c) -lt 5 ]; then
    for i in $(echo $input | grep -o .); do
      a=$(($a+1))
      code=$code$i$i
    done
  else
    code="$input"
  fi
  #Change HEX to DEC and group for r,g,b channels
  a=0
  for i in $(echo $code | grep -o ..); do
    a=$(($a+1))
    rgb[$a]=$(echo "ibase=16;obase=A; $i" | bc)
  done
}

#Calculate shadow and highlight colors then convert decimal back to hex
function calc_colors {
a=0
for i in $(echo ${rgb[*]}); do
  a=$(($a+1))
  shadow[$a]=$(echo "${rgb[$a]}*$shadow_multiplier" | bc)
  highlight[$a]=$(echo "${rgb[$a]}*$highlight_multiplier" | bc)
  disabled[$a]=$(echo "${rgb[$a]}*$disabled_fg_multiplier" | bc)
  #Cap at 255
  if [ ${highlight[$a]%.*} -gt 255 ]; then
    highlight[$a]=255
  fi
  shadow_hex=$shadow_hex$(echo "ibase=10;obase=16; ${shadow[$a]%.*}" | bc)
  if [ $(echo "ibase=10;obase=16; ${shadow[$a]%.*}" | bc | wc -c) -lt 3 ]; then
    shadow_hex=$shadow_hex$(echo "ibase=10;obase=16; ${shadow[$a]%.*}" | bc)
  fi
  highlight_hex=$highlight_hex$(echo "ibase=10;obase=16; ${highlight[$a]%.*}" | bc)
  if [ $(echo "ibase=10;obase=16; ${highlight[$a]%.*}" | bc | wc -c) -lt 3 ]; then
    highlight_hex=$highlight_hex$(echo "ibase=10;obase=16; ${highlight[$a]%.*}" | bc)
  fi
  disabled_hex=$disabled_hex$(echo "ibase=10;obase=16; ${disabled[$a]%.*}" | bc)
  if [ $(echo "ibase=10;obase=16; ${disabled[$a]%.*}" | bc | wc -c) -lt 3 ]; then
    disabled_hex=$disabled_hex$(echo "ibase=10;obase=16; ${disabled[$a]%.*}" | bc)
  fi
done
highlight="#$highlight_hex"
shadow="#$shadow_hex"
disabled_fgcolor="#$disabled_hex"
border="#000000"
}

function compile_assets {
#Clean incomplete builds, compile images
for i in $(ls -d */ | grep -o .*[Aa-Zz]); do
  rm "$i/$i.png"
  rm "$i/"*[0-9].png
  rm -rf assets/*
done

for i in $(ls -d */ | grep -o .*[Aa-Zz]); do
cd $i

if [ $(pwd | grep -ci "ins") -gt 0 ]; then
  convert *base.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" base.png
else
  convert *base.png -fuzz 15% -fill "$basecolor" -opaque "#ff00fa" base.png
fi
convert *border.png -fuzz 15% -fill "$border" -opaque "#ff00fa" border.png
convert *shadow.png -fuzz 15% -fill "$shadow" -opaque "#ff00fa" shadow.png
convert *highlight.png -fuzz 15% -fill "$highlight" -opaque "#ff00fa" highlight.png
convert *background.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" background.png
convert *check.png -fuzz 15% -fill "$basefg" -opaque "#ff00fa" check.png
convert *_aa.png -fuzz 15% -fill "$bgcolor" -opaque "#ff00fa" aa.png
convert *_text.png -fuzz 15% -fill "$fgcolor" -opaque "#ff00fa" text.png
convert *_text_disabled.png -fuzz 15% -fill "$disabled_fgcolor" -opaque "#ff00fa" text_disabled.png
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
for i in $(ls arrow*.png); do
  convert "$i" -fuzz 15% -fill "$disabled_fgcolor" -opaque "$fgcolor" ${i%.*}"_ins.png"
done

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

cp progressbar/*.png assets/
cp assets/progressbar_horiz.png assets/menuitem.png
cp null/null_image.png assets/null.png
#colorize extra widgets
convert assets/menuitem.png -fuzz 15% -fill "$selectedbg" -opaque "#ff00fa" assets/menuitem.png
convert assets/progressbar_horiz.png -fuzz 15% -fill "$selectedbg" -opaque "#ff00fa" assets/progressbar_horiz.png
convert assets/progressbar_vert.png -fuzz 15% -fill "$selectedbg" -opaque "#ff00fa" assets/progressbar_vert.png
cd assets
pwd

gtk3="../../gtk-3.0/assets/"
cp tab*.png $gtk3
cp menubar.png $gtk3/toolbar.png
cp scrollbar_trough.png $gtk3
cp radio*.png $gtk3
cp c_box*.png $gtk3
cp arrow*.png $gtk3
cp switch*.png $gtk3
mv *.png ../../gtk-2.0/assets/
cd ..
}

function build_theme_config
{
tar -xvzf theme_config.tar.gz

echo "Generating rc and css config files..."

#GTK-2.0
sed -i 's/fg_color:#000/fg_color:'$fgcolor'/g' base.rc
sed -i 's/bg_color:#c0c0c0/bg_color:'$bgcolor'/g' base.rc
sed -i 's/base_color:#fff/base_color:'$basecolor'/g' base.rc
sed -i 's/text_color:#000/text_color:'$basefg'/g' base.rc
sed -i 's/selected_bg_color:#0000aa/selected_bg_color:'$selectedbg'/g' base.rc
sed -i 's/selected_fg_color:#fff/selected_fg_color:'$selectedtext'/g' base.rc
sed -i 's/disabled_fg_color:#e0e0e0/disabled_fg_color:'$disabled_fgcolor'/g' base.rc

#GTK-3.0
sed -i 's/@define-color fg_color #000000/@define-color fg_color '$fgcolor'/g' gtk-base.css
sed -i 's/@define-color bg_color #c0c0c0/@define-color bg_color '$bgcolor'/g' gtk-base.css
sed -i 's/@define-color base_color #FFFFFF/@define-color base_color '$basecolor'/g' gtk-base.css
sed -i 's/@define-color text_color #000000/@define-color text_color '$basefg'/g' gtk-base.css
sed -i 's/@define-color selected_bg_color #0000aa/@define-color selected_bg_color '$selectedbg'/g' gtk-base.css
sed -i 's/@define-color selected_fg_color #FFFFFF/@define-color selected_fg_color '$selectedtext'/g' gtk-base.css
sed -i 's/@define-color light_shadow #FFFFFF/@define-color light_shadow '$highlight'/g' gtk-base.css
sed -i 's/@define-color disabled_fg_color #EFEFEF/@define-color disabled_fg_color '$disabled_fgcolor'/g' gtk-base.css

#XFCE4WM
sed -i 's/active_text_color=#FFFFFF/active_text_color='$activetitletext'/g' themerc
sed -i 's/inactive_text_color=#c0c0c0/inactive_text_color='$inactivetitletext'/g' themerc
sed -i 's/active_color_1=#6f99be/active_color_1='$activetitle'/g' themerc
sed -i 's/inactive_color_1=#7d7a73/inactive_color_1='$inactivetitle'/g' themerc

#Append changes
cat gtkrc >> base.rc
rm -rf gtkrc
mv base.rc ../gtk-2.0/gtkrc
cat gtk.css >> gtk-base.css
rm gtk.css
mv gtk-base.css ../gtk-3.0/gtk.css
mv themerc ../xfwm4/
}

hex2rgb "$bgcolor"
calc_colors

echo ${rgb[*]}
echo "Shadow color: $shadow"
echo "Highlight color: $highlight"
echo "Border color: $border"
echo "Disabled FG color: $disabled_fgcolor"

sleep 2
echo "Compiling theme images please wait..."
compile_assets $2 2>>/dev/null
build_theme_config

theme_name="Redmond2K $Theme_name"
mkdir ~/.themes/"$theme_name"
cp -aR ../gtk-2.0 ~/.themes/"$theme_name"/
cp -aR ../gtk-3.0 ~/.themes/"$theme_name"/
cp -aR ../xfwm4 ~/.themes/"$theme_name"/
cp theme.conf ~/.themes/"$theme_name"/
echo "GTK2, GTK3 and XFWM4 themes configured and installed."
echo "Theme '$theme_name' installed in ~/.themes/$theme_name. You may now select and use your theme."
