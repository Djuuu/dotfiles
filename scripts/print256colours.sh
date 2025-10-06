#!/bin/bash

# https://gist.github.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263

# Tom Hale, 2016. MIT Licence.
# Print out 256 colours, with each number printed in its corresponding colour
# See http://askubuntu.com/questions/821157/print-a-256-color-test-pattern-in-the-terminal/821163#821163

set -eu # Fail on errors or undeclared variables

printable_colours=256

# Return a colour that contrasts with the given colour
# Bash only does integer division, so keep it integral
function contrast_colour {
    local r g b luminance
    local colour="$1"

    if (( colour < 16 )); then # Initial 16 ANSI colours
        (( colour == 0 )) && printf "15" || printf "0"
        return
    fi

    # Greyscale # rgb_R = rgb_G = rgb_B = (number - 232) * 10 + 8
    if (( colour > 231 )); then # Greyscale ramp
        (( colour < 244 )) && printf "15" || printf "0"
        return
    fi

    # All other colours:
    # 6x6x6 colour cube = 16 + 36*R + 6*G + B  # Where RGB are [0..5]
    # See http://stackoverflow.com/a/27165165/5353461

    r=$(( (colour-16) / 36 ))
    g=$(( ((colour-16) % 36) / 6 ))
    b=$(( (colour-16) % 6 ))

    # If luminance is bright, print number in black, white otherwise.
    # Green contributes 587/1000 to human perceived luminance - ITU R-REC-BT.601
    (( g > 2)) && printf "0" || printf "15"
    return

    # Uncomment the below for more precise luminance calculations

    # Calculate percieved brightness
    # See https://www.w3.org/TR/AERT#color-contrast
    # and http://www.itu.int/rec/R-REC-BT.601
    # Luminance is in range 0..5000 as each value is 0..5
    luminance=$(( (r * 299) + (g * 587) + (b * 114) ))
    (( luminance > 2500 )) && printf "0" || printf "15"
}

# Print a coloured block with the number of that colour
function print_colour {
    local colour="$1" contrast label
    contrast=$(contrast_colour "$1")

    case ${printMode:-number} in
        name)     label=" $(color_name "$colour") " ;;
        code)     label=" $(color_code "$colour") " ;;
        number|*) label=" $(printf '%3d' "$colour") ";;
    esac

    printf "\e[48;5;%sm"   "$colour"            # Start block of colour
    printf "\e[38;5;%sm%s" "$contrast" "$label" # In contrast, print number
    printf "\e[0m "                             # Reset colour
}

# Starting at $1, print a run of $2 colours
function print_run {
    local i
    for (( i = "$1"; i < "$1" + "$2" && i < printable_colours; i++ )) do
        print_colour "$i"
    done
    printf "  "
}

# Print blocks of colours
function print_blocks {
    local start="$1" i
    local end="$2" # inclusive
    local block_cols="$3"
    local block_rows="$4"
    local blocks_per_line="$5"
    local block_length=$((block_cols * block_rows))

    local row block
    # Print sets of blocks
    for (( i = start; i <= end; i += (blocks_per_line-1) * block_length )) do
        printf "\n" # Space before each set of blocks
        # For each block row
        for (( row = 0; row < block_rows; row++ )) do
            # Print block columns for all blocks on the line
            for (( block = 0; block < blocks_per_line; block++ )) do
                print_run $(( i + (block * block_length) )) "$block_cols"
            done
            (( i += block_cols )) # Prepare to print the next row
            printf "\n"
        done
    done
}

function color_name {
    # 256 colors
    # https://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
    # https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
    case $1 in
          0) echo "black        " ;;   8) echo "brightBlack  " ;;
          1) echo "red          " ;;   9) echo "brightRed    " ;;
          2) echo "green        " ;;  10) echo "brightGreen  " ;;
          3) echo "yellow       " ;;  11) echo "brightYellow " ;;
          4) echo "blue         " ;;  12) echo "brightBlue   " ;;
          5) echo "magenta      " ;;  13) echo "brightMagenta" ;;
          6) echo "cyan         " ;;  14) echo "brightCyan   " ;;
          7) echo "white        " ;;  15) echo "brightWhite  " ;;

         16) echo "x016_Grey0            " ;;
         17) echo "x017_NavyBlue         " ;;
         18) echo "x018_DarkBlue         " ;;
         19) echo "x019_Blue3            " ;;
         20) echo "x020_Blue3            " ;;
         21) echo "x021_Blue1            " ;;
         22) echo "x022_DarkGreen        " ;;
         23) echo "x023_DeepSkyBlue4     " ;;
         24) echo "x024_DeepSkyBlue4     " ;;
         25) echo "x025_DeepSkyBlue4     " ;;
         26) echo "x026_DodgerBlue3      " ;;
         27) echo "x027_DodgerBlue2      " ;;
         28) echo "x028_Green4           " ;;
         29) echo "x029_SpringGreen4     " ;;
         30) echo "x030_Turquoise4       " ;;
         31) echo "x031_DeepSkyBlue3     " ;;
         32) echo "x032_DeepSkyBlue3     " ;;
         33) echo "x033_DodgerBlue1      " ;;
         34) echo "x034_Green3           " ;;
         35) echo "x035_SpringGreen3     " ;;
         36) echo "x036_DarkCyan         " ;;
         37) echo "x037_LightSeaGreen    " ;;
         38) echo "x038_DeepSkyBlue2     " ;;
         39) echo "x039_DeepSkyBlue1     " ;;
         40) echo "x040_Green3           " ;;
         41) echo "x041_SpringGreen3     " ;;
         42) echo "x042_SpringGreen2     " ;;
         43) echo "x043_Cyan3            " ;;
         44) echo "x044_DarkTurquoise    " ;;
         45) echo "x045_Turquoise2       " ;;
         46) echo "x046_Green1           " ;;
         47) echo "x047_SpringGreen2     " ;;
         48) echo "x048_SpringGreen1     " ;;
         49) echo "x049_MediumSpringGreen" ;;
         50) echo "x050_Cyan2            " ;;
         51) echo "x051_Cyan1            " ;;

         52) echo "x052_DarkRed          " ;;
         53) echo "x053_DeepPink4        " ;;
         54) echo "x054_Purple4          " ;;
         55) echo "x055_Purple4          " ;;
         56) echo "x056_Purple3          " ;;
         57) echo "x057_BlueViolet       " ;;
         58) echo "x058_Orange4          " ;;
         59) echo "x059_Grey37           " ;;
         60) echo "x060_MediumPurple4    " ;;
         61) echo "x061_SlateBlue3       " ;;
         62) echo "x062_SlateBlue3       " ;;
         63) echo "x063_RoyalBlue1       " ;;
         64) echo "x064_Chartreuse4      " ;;
         65) echo "x065_DarkSeaGreen4    " ;;
         66) echo "x066_PaleTurquoise4   " ;;
         67) echo "x067_SteelBlue        " ;;
         68) echo "x068_SteelBlue3       " ;;
         69) echo "x069_CornflowerBlue   " ;;
         70) echo "x070_Chartreuse3      " ;;
         71) echo "x071_DarkSeaGreen4    " ;;
         72) echo "x072_CadetBlue        " ;;
         73) echo "x073_CadetBlue        " ;;
         74) echo "x074_SkyBlue3         " ;;
         75) echo "x075_SteelBlue1       " ;;
         76) echo "x076_Chartreuse3      " ;;
         77) echo "x077_PaleGreen3       " ;;
         78) echo "x078_SeaGreen3        " ;;
         79) echo "x079_Aquamarine3      " ;;
         80) echo "x080_MediumTurquoise  " ;;
         81) echo "x081_SteelBlue1       " ;;
         82) echo "x082_Chartreuse2      " ;;
         83) echo "x083_SeaGreen2        " ;;
         84) echo "x084_SeaGreen1        " ;;
         85) echo "x085_SeaGreen1        " ;;
         86) echo "x086_Aquamarine1      " ;;
         87) echo "x087_DarkSlateGray2   " ;;

         88) echo "x088_DarkRed          " ;;
         89) echo "x089_DeepPink4        " ;;
         90) echo "x090_DarkMagenta      " ;;
         91) echo "x091_DarkMagenta      " ;;
         92) echo "x092_DarkViolet       " ;;
         93) echo "x093_Purple           " ;;
         94) echo "x094_Orange4          " ;;
         95) echo "x095_LightPink4       " ;;
         96) echo "x096_Plum4            " ;;
         97) echo "x097_MediumPurple3    " ;;
         98) echo "x098_MediumPurple3    " ;;
         99) echo "x099_SlateBlue1       " ;;
        100) echo "x100_Yellow4          " ;;
        101) echo "x101_Wheat4           " ;;
        102) echo "x102_Grey53           " ;;
        103) echo "x103_LightSlateGrey   " ;;
        104) echo "x104_MediumPurple     " ;;
        105) echo "x105_LightSlateBlue   " ;;
        106) echo "x106_Yellow4          " ;;
        107) echo "x107_DarkOliveGreen3  " ;;
        108) echo "x108_DarkSeaGreen     " ;;
        109) echo "x109_LightSkyBlue3    " ;;
        110) echo "x110_LightSkyBlue3    " ;;
        111) echo "x111_SkyBlue2         " ;;
        112) echo "x112_Chartreuse2      " ;;
        113) echo "x113_DarkOliveGreen3  " ;;
        114) echo "x114_PaleGreen3       " ;;
        115) echo "x115_DarkSeaGreen3    " ;;
        116) echo "x116_DarkSlateGray3   " ;;
        117) echo "x117_SkyBlue1         " ;;
        118) echo "x118_Chartreuse1      " ;;
        119) echo "x119_LightGreen       " ;;
        120) echo "x120_LightGreen       " ;;
        121) echo "x121_PaleGreen1       " ;;
        122) echo "x122_Aquamarine1      " ;;
        123) echo "x123_DarkSlateGray1   " ;;

        124) echo "x124_Red3             " ;;
        125) echo "x125_DeepPink4        " ;;
        126) echo "x126_MediumVioletRed  " ;;
        127) echo "x127_Magenta3         " ;;
        128) echo "x128_DarkViolet       " ;;
        129) echo "x129_Purple           " ;;
        130) echo "x130_DarkOrange3      " ;;
        131) echo "x131_IndianRed        " ;;
        132) echo "x132_HotPink3         " ;;
        133) echo "x133_MediumOrchid3    " ;;
        134) echo "x134_MediumOrchid     " ;;
        135) echo "x135_MediumPurple2    " ;;
        136) echo "x136_DarkGoldenrod    " ;;
        137) echo "x137_LightSalmon3     " ;;
        138) echo "x138_RosyBrown        " ;;
        139) echo "x139_Grey63           " ;;
        140) echo "x140_MediumPurple2    " ;;
        141) echo "x141_MediumPurple1    " ;;
        142) echo "x142_Gold3            " ;;
        143) echo "x143_DarkKhaki        " ;;
        144) echo "x144_NavajoWhite3     " ;;
        145) echo "x145_Grey69           " ;;
        146) echo "x146_LightSteelBlue3  " ;;
        147) echo "x147_LightSteelBlue   " ;;
        148) echo "x148_Yellow3          " ;;
        149) echo "x149_DarkOliveGreen3  " ;;
        150) echo "x150_DarkSeaGreen3    " ;;
        151) echo "x151_DarkSeaGreen2    " ;;
        152) echo "x152_LightCyan3       " ;;
        153) echo "x153_LightSkyBlue1    " ;;
        154) echo "x154_GreenYellow      " ;;
        155) echo "x155_DarkOliveGreen2  " ;;
        156) echo "x156_PaleGreen1       " ;;
        157) echo "x157_DarkSeaGreen2    " ;;
        158) echo "x158_DarkSeaGreen1    " ;;
        159) echo "x159_PaleTurquoise1   " ;;

        160) echo "x160_Red3             " ;;
        161) echo "x161_DeepPink3        " ;;
        162) echo "x162_DeepPink3        " ;;
        163) echo "x163_Magenta3         " ;;
        164) echo "x164_Magenta3         " ;;
        165) echo "x165_Magenta2         " ;;
        166) echo "x166_DarkOrange3      " ;;
        167) echo "x167_IndianRed        " ;;
        168) echo "x168_HotPink3         " ;;
        169) echo "x169_HotPink2         " ;;
        170) echo "x170_Orchid           " ;;
        171) echo "x171_MediumOrchid1    " ;;
        172) echo "x172_Orange3          " ;;
        173) echo "x173_LightSalmon3     " ;;
        174) echo "x174_LightPink3       " ;;
        175) echo "x175_Pink3            " ;;
        176) echo "x176_Plum3            " ;;
        177) echo "x177_Violet           " ;;
        178) echo "x178_Gold3            " ;;
        179) echo "x179_LightGoldenrod3  " ;;
        180) echo "x180_Tan              " ;;
        181) echo "x181_MistyRose3       " ;;
        182) echo "x182_Thistle3         " ;;
        183) echo "x183_Plum2            " ;;
        184) echo "x184_Yellow3          " ;;
        185) echo "x185_Khaki3           " ;;
        186) echo "x186_LightGoldenrod2  " ;;
        187) echo "x187_LightYellow3     " ;;
        188) echo "x188_Grey84           " ;;
        189) echo "x189_LightSteelBlue1  " ;;
        190) echo "x190_Yellow2          " ;;
        191) echo "x191_DarkOliveGreen1  " ;;
        192) echo "x192_DarkOliveGreen1  " ;;
        193) echo "x193_DarkSeaGreen1    " ;;
        194) echo "x194_Honeydew2        " ;;
        195) echo "x195_LightCyan1       " ;;

        196) echo "x196_Red1             " ;;
        197) echo "x197_DeepPink2        " ;;
        198) echo "x198_DeepPink1        " ;;
        199) echo "x199_DeepPink1        " ;;
        200) echo "x200_Magenta2         " ;;
        201) echo "x201_Magenta1         " ;;
        202) echo "x202_OrangeRed1       " ;;
        203) echo "x203_IndianRed1       " ;;
        204) echo "x204_IndianRed1       " ;;
        205) echo "x205_HotPink          " ;;
        206) echo "x206_HotPink          " ;;
        207) echo "x207_MediumOrchid1    " ;;
        208) echo "x208_DarkOrange       " ;;
        209) echo "x209_Salmon1          " ;;
        210) echo "x210_LightCoral       " ;;
        211) echo "x211_PaleVioletRed1   " ;;
        212) echo "x212_Orchid2          " ;;
        213) echo "x213_Orchid1          " ;;
        214) echo "x214_Orange1          " ;;
        215) echo "x215_SandyBrown       " ;;
        216) echo "x216_LightSalmon1     " ;;
        217) echo "x217_LightPink1       " ;;
        218) echo "x218_Pink1            " ;;
        219) echo "x219_Plum1            " ;;
        220) echo "x220_Gold1            " ;;
        221) echo "x221_LightGoldenrod2  " ;;
        222) echo "x222_LightGoldenrod2  " ;;
        223) echo "x223_NavajoWhite1     " ;;
        224) echo "x224_MistyRose1       " ;;
        225) echo "x225_Thistle1         " ;;
        226) echo "x226_Yellow1          " ;;
        227) echo "x227_LightGoldenrod1  " ;;
        228) echo "x228_Khaki1           " ;;
        229) echo "x229_Wheat1           " ;;
        230) echo "x230_Cornsilk1        " ;;
        231) echo "x231_Grey100          " ;;

        232) echo "x232_Grey3 " ;;
        233) echo "x233_Grey7 " ;;
        234) echo "x234_Grey11" ;;
        235) echo "x235_Grey15" ;;
        236) echo "x236_Grey19" ;;
        237) echo "x237_Grey23" ;;
        238) echo "x238_Grey27" ;;
        239) echo "x239_Grey30" ;;
        240) echo "x240_Grey35" ;;
        241) echo "x241_Grey39" ;;
        242) echo "x242_Grey42" ;;
        243) echo "x243_Grey46" ;;
        244) echo "x244_Grey50" ;;
        245) echo "x245_Grey54" ;;
        246) echo "x246_Grey58" ;;
        247) echo "x247_Grey62" ;;
        248) echo "x248_Grey66" ;;
        249) echo "x249_Grey70" ;;
        250) echo "x250_Grey74" ;;
        251) echo "x251_Grey78" ;;
        252) echo "x252_Grey82" ;;
        253) echo "x253_Grey85" ;;
        254) echo "x254_Grey89" ;;
        255) echo "x255_Grey93" ;;
    esac
}

function color_code {
    # 256 colors
    # https://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
    case $1 in
          0) echo "black        " ;;   8) echo "brightBlack  " ;;
          1) echo "red          " ;;   9) echo "brightRed    " ;;
          2) echo "green        " ;;  10) echo "brightGreen  " ;;
          3) echo "yellow       " ;;  11) echo "brightYellow " ;;
          4) echo "blue         " ;;  12) echo "brightBlue   " ;;
          5) echo "magenta      " ;;  13) echo "brightMagenta" ;;
          6) echo "cyan         " ;;  14) echo "brightCyan   " ;;
          7) echo "white        " ;;  15) echo "brightWhite  " ;;

         16) echo "#000000" ;;
         17) echo "#00005F" ;;
         18) echo "#000087" ;;
         19) echo "#0000AF" ;;
         20) echo "#0000D7" ;;
         21) echo "#0000FF" ;;
         22) echo "#005F00" ;;
         23) echo "#005F5F" ;;
         24) echo "#005F87" ;;
         25) echo "#005FAF" ;;
         26) echo "#005FD7" ;;
         27) echo "#005FFF" ;;
         28) echo "#008700" ;;
         29) echo "#00875F" ;;
         30) echo "#008787" ;;
         31) echo "#0087AF" ;;
         32) echo "#0087D7" ;;
         33) echo "#0087FF" ;;
         34) echo "#00AF00" ;;
         35) echo "#00AF5F" ;;
         36) echo "#00AF87" ;;
         37) echo "#00AFAF" ;;
         38) echo "#00AFD7" ;;
         39) echo "#00AFFF" ;;
         40) echo "#00D700" ;;
         41) echo "#00D75F" ;;
         42) echo "#00D787" ;;
         43) echo "#00D7AF" ;;
         44) echo "#00D7D7" ;;
         45) echo "#00D7FF" ;;
         46) echo "#00FF00" ;;
         47) echo "#00FF5F" ;;
         48) echo "#00FF87" ;;
         49) echo "#00FFAF" ;;
         50) echo "#00FFD7" ;;
         51) echo "#00FFFF" ;;

         52) echo "#5F0000" ;;
         53) echo "#5F005F" ;;
         54) echo "#5F0087" ;;
         55) echo "#5F00AF" ;;
         56) echo "#5F00D7" ;;
         57) echo "#5F00FF" ;;
         58) echo "#5F5F00" ;;
         59) echo "#5F5F5F" ;;
         60) echo "#5F5F87" ;;
         61) echo "#5F5FAF" ;;
         62) echo "#5F5FD7" ;;
         63) echo "#5F5FFF" ;;
         64) echo "#5F8700" ;;
         65) echo "#5F875F" ;;
         66) echo "#5F8787" ;;
         67) echo "#5F87AF" ;;
         68) echo "#5F87D7" ;;
         69) echo "#5F87FF" ;;
         70) echo "#5FAF00" ;;
         71) echo "#5FAF5F" ;;
         72) echo "#5FAF87" ;;
         73) echo "#5FAFAF" ;;
         74) echo "#5FAFD7" ;;
         75) echo "#5FAFFF" ;;
         76) echo "#5FD700" ;;
         77) echo "#5FD75F" ;;
         78) echo "#5FD787" ;;
         79) echo "#5FD7AF" ;;
         80) echo "#5FD7D7" ;;
         81) echo "#5FD7FF" ;;
         82) echo "#5FFF00" ;;
         83) echo "#5FFF5F" ;;
         84) echo "#5FFF87" ;;
         85) echo "#5FFFAF" ;;
         86) echo "#5FFFD7" ;;
         87) echo "#5FFFFF" ;;

         88) echo "#870000" ;;
         89) echo "#87005F" ;;
         90) echo "#870087" ;;
         91) echo "#8700AF" ;;
         92) echo "#8700D7" ;;
         93) echo "#8700FF" ;;
         94) echo "#875F00" ;;
         95) echo "#875F5F" ;;
         96) echo "#875F87" ;;
         97) echo "#875FAF" ;;
         98) echo "#875FD7" ;;
         99) echo "#875FFF" ;;
        100) echo "#878700" ;;
        101) echo "#87875F" ;;
        102) echo "#878787" ;;
        103) echo "#8787AF" ;;
        104) echo "#8787D7" ;;
        105) echo "#8787FF" ;;
        106) echo "#87AF00" ;;
        107) echo "#87AF5F" ;;
        108) echo "#87AF87" ;;
        109) echo "#87AFAF" ;;
        110) echo "#87AFD7" ;;
        111) echo "#87AFFF" ;;
        112) echo "#87D700" ;;
        113) echo "#87D75F" ;;
        114) echo "#87D787" ;;
        115) echo "#87D7AF" ;;
        116) echo "#87D7D7" ;;
        117) echo "#87D7FF" ;;
        118) echo "#87FF00" ;;
        119) echo "#87FF5F" ;;
        120) echo "#87FF87" ;;
        121) echo "#87FFAF" ;;
        122) echo "#87FFD7" ;;
        123) echo "#87FFFF" ;;

        124) echo "#AF0000" ;;
        125) echo "#AF005F" ;;
        126) echo "#AF0087" ;;
        127) echo "#AF00AF" ;;
        128) echo "#AF00D7" ;;
        129) echo "#AF00FF" ;;
        130) echo "#AF5F00" ;;
        131) echo "#AF5F5F" ;;
        132) echo "#AF5F87" ;;
        133) echo "#AF5FAF" ;;
        134) echo "#AF5FD7" ;;
        135) echo "#AF5FFF" ;;
        136) echo "#AF8700" ;;
        137) echo "#AF875F" ;;
        138) echo "#AF8787" ;;
        139) echo "#AF87AF" ;;
        140) echo "#AF87D7" ;;
        141) echo "#AF87FF" ;;
        142) echo "#AFAF00" ;;
        143) echo "#AFAF5F" ;;
        144) echo "#AFAF87" ;;
        145) echo "#AFAFAF" ;;
        146) echo "#AFAFD7" ;;
        147) echo "#AFAFFF" ;;
        148) echo "#AFD700" ;;
        149) echo "#AFD75F" ;;
        150) echo "#AFD787" ;;
        151) echo "#AFD7AF" ;;
        152) echo "#AFD7D7" ;;
        153) echo "#AFD7FF" ;;
        154) echo "#AFFF00" ;;
        155) echo "#AFFF5F" ;;
        156) echo "#AFFF87" ;;
        157) echo "#AFFFAF" ;;
        158) echo "#AFFFD7" ;;
        159) echo "#AFFFFF" ;;

        160) echo "#D70000" ;;
        161) echo "#D7005F" ;;
        162) echo "#D70087" ;;
        163) echo "#D700AF" ;;
        164) echo "#D700D7" ;;
        165) echo "#D700FF" ;;
        166) echo "#D75F00" ;;
        167) echo "#D75F5F" ;;
        168) echo "#D75F87" ;;
        169) echo "#D75FAF" ;;
        170) echo "#D75FD7" ;;
        171) echo "#D75FFF" ;;
        172) echo "#D78700" ;;
        173) echo "#D7875F" ;;
        174) echo "#D78787" ;;
        175) echo "#D787AF" ;;
        176) echo "#D787D7" ;;
        177) echo "#D787FF" ;;
        178) echo "#D7AF00" ;;
        179) echo "#D7AF5F" ;;
        180) echo "#D7AF87" ;;
        181) echo "#D7AFAF" ;;
        182) echo "#D7AFD7" ;;
        183) echo "#D7AFFF" ;;
        184) echo "#D7D700" ;;
        185) echo "#D7D75F" ;;
        186) echo "#D7D787" ;;
        187) echo "#D7D7AF" ;;
        188) echo "#D7D7D7" ;;
        189) echo "#D7D7FF" ;;
        190) echo "#D7FF00" ;;
        191) echo "#D7FF5F" ;;
        192) echo "#D7FF87" ;;
        193) echo "#D7FFAF" ;;
        194) echo "#D7FFD7" ;;
        195) echo "#D7FFFF" ;;

        196) echo "#FF0000" ;;
        197) echo "#FF005F" ;;
        198) echo "#FF0087" ;;
        199) echo "#FF00AF" ;;
        200) echo "#FF00D7" ;;
        201) echo "#FF00FF" ;;
        202) echo "#FF5F00" ;;
        203) echo "#FF5F5F" ;;
        204) echo "#FF5F87" ;;
        205) echo "#FF5FAF" ;;
        206) echo "#FF5FD7" ;;
        207) echo "#FF5FFF" ;;
        208) echo "#FF8700" ;;
        209) echo "#FF875F" ;;
        210) echo "#FF8787" ;;
        211) echo "#FF87AF" ;;
        212) echo "#FF87D7" ;;
        213) echo "#FF87FF" ;;
        214) echo "#FFAF00" ;;
        215) echo "#FFAF5F" ;;
        216) echo "#FFAF87" ;;
        217) echo "#FFAFAF" ;;
        218) echo "#FFAFD7" ;;
        219) echo "#FFAFFF" ;;
        220) echo "#FFD700" ;;
        221) echo "#FFD75F" ;;
        222) echo "#FFD787" ;;
        223) echo "#FFD7AF" ;;
        224) echo "#FFD7D7" ;;
        225) echo "#FFD7FF" ;;
        226) echo "#FFFF00" ;;
        227) echo "#FFFF5F" ;;
        228) echo "#FFFF87" ;;
        229) echo "#FFFFAF" ;;
        230) echo "#FFFFD7" ;;
        231) echo "#FFFFFF" ;;

        232) echo "#080808" ;;
        233) echo "#121212" ;;
        234) echo "#1C1C1C" ;;
        235) echo "#262626" ;;
        236) echo "#303030" ;;
        237) echo "#3A3A3A" ;;
        238) echo "#444444" ;;
        239) echo "#4E4E4E" ;;
        240) echo "#585858" ;;
        241) echo "#626262" ;;
        242) echo "#6C6C6C" ;;
        243) echo "#767676" ;;
        244) echo "#808080" ;;
        245) echo "#8A8A8A" ;;
        246) echo "#949494" ;;
        247) echo "#9E9E9E" ;;
        248) echo "#A8A8A8" ;;
        249) echo "#B2B2B2" ;;
        250) echo "#BCBCBC" ;;
        251) echo "#C6C6C6" ;;
        252) echo "#D0D0D0" ;;
        253) echo "#DADADA" ;;
        254) echo "#E4E4E4" ;;
        255) echo "#EEEEEE" ;;
    esac
}


# Parse options

printMode=number
output=normal

args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--name*|name*) printMode=name   ;;
        -c|--code|code)   printMode=code   ;;
        --number|number)  printMode=number ;;
        -s|--short|short) output=short     ;;
        *)                args+=("${1}")   ;;
    esac
    shift
done
set -- "${args[@]}"


# Execute

bold="\e[1m"
normal="\e[0m"
dim="\e[2m"
italic="\e[3m"
underline="\e[4m"
blink="\e[5m"
reverse="\e[7m"

printf "\nThe ${bold}quick brown fox${normal} jumps ${italic}over${normal} ${dim}the${normal} ${reverse}lazy dog${normal}.\n\n"

# The first 16 colours are spread over the whole spectrum
#print_run 0 16
print_run 0 8; printf "\n"
print_run 8 8; printf "\n"

[[ $output == "short" ]] && exit 1

#print_blocks 16 231 6 6 3 # 6x6x6 colour cube between 16 and 231 inclusive
print_blocks 16 231 6 6 1

print_blocks 232 255 12 2 1 # Not 50, but 24 Shades of Grey
