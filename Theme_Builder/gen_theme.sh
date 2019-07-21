#!/bin/bash
. theme.conf
code=""

#Limit RGB channel to 0-255
function cap_rgb {
  code=$1
  if [ $code -gt 255 ]; then
    code=255
  fi
  if [ $code -lt 1 ]; then
    code=0
  fi
  echo $code
}

#Filter out invalid hex codes and change 3 digit codes to 6 digit codes
function verify {
  verified="$(echo $1 | grep -io [a0-f9] | grep -io [a0-f9] | awk '{ print; count++; if (count==6) exit }' | tr -d "\n")"
  a=0
  code=$verified
  if [ $(echo $code | wc -c ) -lt 5 ]; then
    verified=""
    for i in $(echo $code | grep -o .); do
      a=$(($a+1))
      i=$i$i
      verified=$verified$i
    done
  fi
verified=$(echo $verified | grep -o [Aa0-Ff9].*)
echo "${verified^^}"
}

#Convert hex to decimal for calculations.
function hex2rgb {
  code=$1
  a=0
  for i in $(echo $code | grep -o ..); do
    a=$(($a+1))
    rgb[$a]=$(echo "ibase=16;obase=A; $i" | bc)
  done
}

#Convert rgb dec to hex
function rgb2hex {
code="$(echo "ibase=10;obase=16; ${1%.*}" | bc)"
if [ $(echo $code | wc -c ) -lt 3 ]; then
  code=$code$code
fi
if [ $(echo $code | grep -c "-") -gt 0 ]; then
  echo "("$code")"
else
  echo $code
fi
}

#Calculate shadow and highlight colors then convert decimal back to hex
function calc_colors {
a=0
#Calc boost color
boost[1]=$(echo "255*$hl_R" | bc) #Red
boost[2]=$(echo "255*$hl_G" | bc) #Green
boost[3]=$(echo "255*$hl_B" | bc) #Blue
boost1[1]=$(echo "255*$s_R" | bc) #Red
boost1[2]=$(echo "255*$s_G" | bc) #Green
boost1[3]=$(echo "255*$s_B" | bc) #Blue
for i in $(echo ${rgb[*]}); do
  a=$(($a+1))
  #Calculated shadow, highlight and disabled colors
  shadow[$a]=$(echo "${rgb[$a]}*$shadow_multiplier" | bc)
  highlight[$a]=$(echo "${rgb[$a]}*$highlight_multiplier" | bc)
  if [ $(echo $high_contrast | grep -ic "true") -gt 0 ]; then
    disabled[$a]=$(echo "${fgcolor_rgb[$a]}*$disabled_fg_multiplier" | bc)
  else
    disabled[$a]=$(echo "${rgb[$a]}*$disabled_fg_multiplier" | bc)
  fi
  #Color boost
  shadow[$a]=$(echo "$(cap_rgb ${shadow[$a]%.*})+${boost1[$a]%.*}" | bc)
  highlight[$a]=$(echo "$(cap_rgb ${highlight[$a]%.*})+${boost[$a]%.*}" | bc)

  #Cap at 255 and ignore negative values
  highlight[$a]=$(cap_rgb ${highlight[$a]%.*})
  shadow[$a]=$(cap_rgb ${shadow[$a]%.*})
  disabled[$a]=$(cap_rgb ${disabled[$a]%.*})

  #Convert DEC to HEX
  shadow_hex=$shadow_hex$(rgb2hex ${shadow[$a]%.*})
  highlight_hex=$highlight_hex$(rgb2hex ${highlight[$a]%.*})
  disabled_hex=$disabled_hex$(rgb2hex ${disabled[$a]%.*})
done

highlight="$highlight_hex"
shadow="$shadow_hex"
disabled_fgcolor="$disabled_hex"
}

function compile_assets {
cd images
for i in $(ls -d */ | grep -o .*[Aa-Zz]); do
cd $i
if [ $(pwd | grep -ci "ins") -gt 0 ]; then
  convert *base.png -fuzz 15% -fill "#$bgcolor" -opaque "#ff00fa" base.png
else
  convert *base.png -fuzz 15% -fill "#$basecolor" -opaque "#ff00fa" base.png
fi
convert *border.png -fuzz 15% -fill "#$border" -opaque "#ff00fa" border.png
convert *shadow.png -fuzz 15% -fill "#$shadow" -opaque "#ff00fa" shadow.png
convert *highlight.png -fuzz 15% -fill "#$highlight" -opaque "#ff00fa" highlight.png
convert *background.png -fuzz 15% -fill "#$bgcolor" -opaque "#ff00fa" background.png
convert *check.png -fuzz 15% -fill "#$basefg" -opaque "#ff00fa" check.png
convert *_aa.png -fuzz 15% -fill "#$bgcolor" -opaque "#ff00fa" aa.png
convert *_text.png -fuzz 15% -fill "#$fgcolor" -opaque "#ff00fa" text.png
convert *_text_disabled.png -fuzz 15% -fill "#$disabled_fgcolor" -opaque "#ff00fa" text_disabled.png
convert -background none -page +0+0 background.png -page +0+0 highlight.png \
-page +0+0 shadow.png -page 0+0 border.png -page +0+0 base.png -page +0+0 check.png \
-page +0+0 aa.png -page +0+0 text.png -page +0+0 text_disabled.png -layers flatten $i.png
#remove work files
mv $i.png ../assets/
rm shadow.png border.png highlight.png background.png base.png check.png aa.png
#return to directory
cd ../
done
cd assets

#compile arrows
mv arrow.png arrow_up.png
convert -rotate "90" arrow_up.png arrow_right.png
convert -rotate "90" arrow_right.png arrow_down.png
convert -rotate "90" arrow_down.png arrow_left.png
for i in $(ls arrow*.png); do
  convert "$i" -fuzz 15% -fill "#$disabled_fgcolor" -opaque "$fgcolor" ${i%.*}"_ins.png"
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
convert assets/menuitem.png -fuzz 15% -fill "#$selectedbg" -opaque "#ff00fa" assets/menuitem.png
convert assets/progressbar_horiz.png -fuzz 15% -fill "#$selectedbg" -opaque "#ff00fa" assets/progressbar_horiz.png
convert assets/progressbar_vert.png -fuzz 15% -fill "#$selectedbg" -opaque "#ff00fa" assets/progressbar_vert.png
cd assets

gtk3="../../gtk-3.0/assets/"
cp tab*.png $gtk3
cp menubar.png $gtk3/toolbar.png
cp scrollbar_trough.png $gtk3
cp radio*.png $gtk3
cp c_box*.png $gtk3
cp arrow*.png $gtk3
cp switch*.png $gtk3
mv *.png ../../gtk-2.0/assets/
cd ../../
}

function build_theme_config
{
echo "Generating rc and css config files..."

#GTK-2.0
sed -i 's/fg_color:#000/fg_color:'#$fgcolor'/g' base.rc
sed -i 's/bg_color:#c0c0c0/bg_color:'#$bgcolor'/g' base.rc
sed -i 's/base_color:#fff/base_color:'#$basecolor'/g' base.rc
sed -i 's/text_color:#000/text_color:'#$basefg'/g' base.rc
sed -i 's/selected_bg_color:#0000aa/selected_bg_color:'#$selectedbg'/g' base.rc
sed -i 's/selected_fg_color:#fff/selected_fg_color:'#$selectedtext'/g' base.rc
sed -i 's/disabled_fg_color:#e0e0e0/disabled_fg_color:'#$disabled_fgcolor'/g' base.rc

#GTK-3.0
sed -i 's/@define-color fg_color #000000/@define-color fg_color '#$fgcolor'/g' gtk-base.css
sed -i 's/@define-color bg_color #c0c0c0/@define-color bg_color '#$bgcolor'/g' gtk-base.css
sed -i 's/@define-color base_color #FFFFFF/@define-color base_color '#$basecolor'/g' gtk-base.css
sed -i 's/@define-color text_color #000000/@define-color text_color '#$basefg'/g' gtk-base.css
sed -i 's/@define-color selected_bg_color #0000aa/@define-color selected_bg_color '#$selectedbg'/g' gtk-base.css
sed -i 's/@define-color selected_fg_color #FFFFFF/@define-color selected_fg_color '#$selectedtext'/g' gtk-base.css
sed -i 's/@define-color light_shadow #FFFFFF/@define-color light_shadow '#$highlight'/g' gtk-base.css
sed -i 's/@define-color disabled_fg_color #EFEFEF/@define-color disabled_fg_color '#$disabled_fgcolor'/g' gtk-base.css
sed -i 's/@define-color borders #000/@define-color borders '#$border'/g' gtk-base.css
sed -i 's/@define-color dark_shadow shade(@bg_color, 0.7)/@define-color dark_shadow '#$shadow'/g' gtk-base.css

#XFCE4WM
sed -i 's/active_text_color=#FFFFFF/active_text_color='#$activetitletext'/g' themerc
sed -i 's/inactive_text_color=#c0c0c0/inactive_text_color='#$inactivetitletext'/g' themerc
sed -i 's/active_color_1=#6f99be/active_color_1='#$activetitle'/g' themerc
sed -i 's/inactive_color_1=#7d7a73/inactive_color_1='#$inactivetitle'/g' themerc
sed -i 's/active_border_color=#000000/active_border_color='#$border'/g' themerc
sed -i 's/inactive_border_color=#000000/inactive_border_color='#$border'/g' themerc
if [ $(echo "$high_contrast" | grep -ci "true") -gt 0 ]; then
  echo "active_border_color=#$border" >> themerc
  echo "inactive_border_color=#$border" >> themerc
  echo "active_hilight_2=#$border" >> themerc
  echo "inactive_hilight_2=#$border" >> themerc
fi

#Append changes
cat gtkrc >> base.rc
rm -rf gtkrc
mv base.rc gtk-2.0/gtkrc
cat gtk.css >> gtk-base.css
rm gtk.css
mv gtk-base.css gtk-3.0/gtk.css
mv themerc xfwm4/
}

function prompt {
echo "Theme name: $Theme_name"
echo "Selected colors:"
hex2rgb $bgcolor
echo "Window BG color: #$bgcolor, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $fgcolor
echo "Window FG color: #$fgcolor, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $basecolor
echo "Base BG color: #$basecolor, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $basefg
echo "Base text color: #$basefg, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $selectedbg
echo "Selected BG color: #$selectedbg, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $selectedtext
echo "Selected FG color: #$selectedtext, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $activetitle
echo "Active titlebar color: #$activetitle, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $activetitletext
echo "Active title text: #$activetitletext, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $inactivetitle
echo "Inactive titlebar color: #$inactivetitle, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $inactivetitletext
echo "Inactive title text: #$inactivetitletext, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $border
echo "Border color: #$border, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
echo ""
echo "3D highlight color boost: #$(rgb2hex ${boost[1]})$(rgb2hex ${boost[2]})$(rgb2hex ${boost[3]}), RGB: ${boost[1]%.*},${boost[2]%.*},${boost[3]%.*}"
echo "3D shadow color boost: #$(rgb2hex ${boost1[1]})$(rgb2hex ${boost1[2]})$(rgb2hex ${boost1[3]}), RGB: ${boost1[1]%.*},${boost1[2]%.*},${boost1[3]%.*}"
echo ""
echo "Calculated colors:"
hex2rgb $highlight
echo "Highlight color: #$highlight, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $shadow
echo "Shadow color: #$shadow, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
hex2rgb $disabled_fgcolor
echo "Disabled FG color: #$disabled_fgcolor, RGB: ${rgb[1]%.*},${rgb[2]%.*},${rgb[3]%.*}"
echo "Press enter to continue or ctrl+c to cancel..."
read $entry
build
}

function build {
echo "Cleaning any previous orphaned files..."
#Clean incomplete or interupted builds, compile images
cleanup  2>>/dev/null
echo "extracting base files please wait..."
tar -xvzf base.tar.gz 2>>/dev/null
echo "Compiling theme images please wait..."
compile_assets $2 2>>/dev/null
build_theme_config

theme_name="Redmond2K $Theme_name"
mkdir ~/.themes/"$theme_name"
mv gtk-2.0 ~/.themes/"$theme_name"/
mv gtk-3.0 ~/.themes/"$theme_name"/
mv xfwm4 ~/.themes/"$theme_name"/
cp theme.conf ~/.themes/"$theme_name"/
version ~/.themes/"$theme_name"/
echo "GTK2, GTK3 and XFWM4 themes configured and installed."
echo "Theme '$theme_name' installed in ~/.themes/$theme_name. You may now select and use your theme."
}

function cleanup {
#Clean incomplete or interupted builds, compile images
rm -rf gtk-2.0 gtk-3.0 images xfwm4
rm rm base.rc gtk.css gtk-base.css gtkrc themerc version
}

#Verify config file hex codes
fgcolor=$(verify $fgcolor)
fgcolor_rgb[1]=${rgb[1]%.*}
fgcolor_rgb[2]=${rgb[2]%.*}
fgcolor_rgb[3]=${rgb[3]%.*}
bgcolor=$(verify $bgcolor)
basecolor=$(verify $basecolor)
basefg=$(verify $basefg)
selectedbg=$(verify $selectedbg)
selectedtext=$(verify $selectedtext)
activetitletext=$(verify $activetitletext)
inactivetitletext=$(verify $inactivetitletext)
activetitle=$(verify $activetitle)
inactivetitle=$(verify $inactivetitle)
border=$(verify $border)
#Convert to rgb for calculations
hex2rgb $fgcolor
fgcolor_rgb[1]=${rgb[1]%.*}
fgcolor_rgb[2]=${rgb[2]%.*}
fgcolor_rgb[3]=${rgb[3]%.*}

#main functions
hex2rgb "$bgcolor"
calc_colors
prompt
cleanup  2>>/dev/null
