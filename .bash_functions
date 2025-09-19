
set_window_title() {
    export FORCED_WINDOW_TITLE="$@"
    printf '\e]2;%s\a' "$@"
}

unset_window_title() {
    unset FORCED_WINDOW_TITLE
    printf '\e]2;%s\a' "${DEFAULT_WINDOW_TITLE:-${USERNAME}@${HOSTNAME} - $(pwd)}"
}

is_win() {
    case "$(uname -s)" in
        CYGWIN*|MINGW*) return 0 ;;
        *)              return 1 ;;
    esac
}

home_path() {
    is_win &&
        echo "$USERPROFILE\\${1//\//\\}" ||
        echo "$HOME/$1"
}

#<editor-fold desc="colors">
color() {
    local c

    # Base 8 colors
    case $1 in
        # normal             -- bold                     -- underline              -- background
        black)  c="\e[0;30m" ;; blackBold)  c="\e[1;30m" ;; blackUl)  c="\e[4;30m" ;; blackBg)  c="\e[40m" ;;
        red)    c="\e[0;31m" ;; redBold)    c="\e[1;31m" ;; redUl)    c="\e[4;31m" ;; redBg)    c="\e[41m" ;;
        green)  c="\e[0;32m" ;; greenBold)  c="\e[1;32m" ;; greenUl)  c="\e[4;32m" ;; greenBg)  c="\e[42m" ;;
        yellow) c="\e[0;33m" ;; yellowBold) c="\e[1;33m" ;; yellowUl) c="\e[4;33m" ;; yellowBg) c="\e[43m" ;;
        blue)   c="\e[0;34m" ;; blueBold)   c="\e[1;34m" ;; blueUl)   c="\e[4;34m" ;; blueBg)   c="\e[44m" ;;
        purple) c="\e[0;35m" ;; purpleBold) c="\e[1;35m" ;; purpleUl) c="\e[4;35m" ;; purpleBg) c="\e[45m" ;;
        cyan)   c="\e[0;36m" ;; cyanBold)   c="\e[1;36m" ;; cyanUl)   c="\e[4;36m" ;; cyanBg)   c="\e[46m" ;;
        white)  c="\e[0;37m" ;; whiteBold)  c="\e[1;37m" ;; whiteUl)  c="\e[4;37m" ;; whiteBg)  c="\e[47m" ;;

        reset)  c="\e[0m" ;;
    esac

    # 256 colors
    # https://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
    # https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim
    case $1 in
         16 | 000000 | x016_Grey0)             c="\e[38;5;016m" ;;
         17 | 00005f | x017_NavyBlue)          c="\e[38;5;017m" ;;
         18 | 000087 | x018_DarkBlue)          c="\e[38;5;018m" ;;
         19 | 0000af | x019_Blue3)             c="\e[38;5;019m" ;;
         20 | 0000d7 | x020_Blue3)             c="\e[38;5;020m" ;;
         21 | 0000ff | x021_Blue1)             c="\e[38;5;021m" ;;
         22 | 005f00 | x022_DarkGreen)         c="\e[38;5;022m" ;;
         23 | 005f5f | x023_DeepSkyBlue4)      c="\e[38;5;023m" ;;
         24 | 005f87 | x024_DeepSkyBlue4)      c="\e[38;5;024m" ;;
         25 | 005faf | x025_DeepSkyBlue4)      c="\e[38;5;025m" ;;
         26 | 005fd7 | x026_DodgerBlue3)       c="\e[38;5;026m" ;;
         27 | 005fff | x027_DodgerBlue2)       c="\e[38;5;027m" ;;
         28 | 008700 | x028_Green4)            c="\e[38;5;028m" ;;
         29 | 00875f | x029_SpringGreen4)      c="\e[38;5;029m" ;;
         30 | 008787 | x030_Turquoise4)        c="\e[38;5;030m" ;;
         31 | 0087af | x031_DeepSkyBlue3)      c="\e[38;5;031m" ;;
         32 | 0087d7 | x032_DeepSkyBlue3)      c="\e[38;5;032m" ;;
         33 | 0087ff | x033_DodgerBlue1)       c="\e[38;5;033m" ;;
         34 | 00af00 | x034_Green3)            c="\e[38;5;034m" ;;
         35 | 00af5f | x035_SpringGreen3)      c="\e[38;5;035m" ;;
         36 | 00af87 | x036_DarkCyan)          c="\e[38;5;036m" ;;
         37 | 00afaf | x037_LightSeaGreen)     c="\e[38;5;037m" ;;
         38 | 00afd7 | x038_DeepSkyBlue2)      c="\e[38;5;038m" ;;
         39 | 00afff | x039_DeepSkyBlue1)      c="\e[38;5;039m" ;;
         40 | 00d700 | x040_Green3)            c="\e[38;5;040m" ;;
         41 | 00d75f | x041_SpringGreen3)      c="\e[38;5;041m" ;;
         42 | 00d787 | x042_SpringGreen2)      c="\e[38;5;042m" ;;
         43 | 00d7af | x043_Cyan3)             c="\e[38;5;043m" ;;
         44 | 00d7d7 | x044_DarkTurquoise)     c="\e[38;5;044m" ;;
         45 | 00d7ff | x045_Turquoise2)        c="\e[38;5;045m" ;;
         46 | 00ff00 | x046_Green1)            c="\e[38;5;046m" ;;
         47 | 00ff5f | x047_SpringGreen2)      c="\e[38;5;047m" ;;
         48 | 00ff87 | x048_SpringGreen1)      c="\e[38;5;048m" ;;
         49 | 00ffaf | x049_MediumSpringGreen) c="\e[38;5;049m" ;;
         50 | 00ffd7 | x050_Cyan2)             c="\e[38;5;050m" ;;
         51 | 00ffff | x051_Cyan1)             c="\e[38;5;051m" ;;
         52 | 5f0000 | x052_DarkRed)           c="\e[38;5;052m" ;;
         53 | 5f005f | x053_DeepPink4)         c="\e[38;5;053m" ;;
         54 | 5f0087 | x054_Purple4)           c="\e[38;5;054m" ;;
         55 | 5f00af | x055_Purple4)           c="\e[38;5;055m" ;;
         56 | 5f00d7 | x056_Purple3)           c="\e[38;5;056m" ;;
         57 | 5f00ff | x057_BlueViolet)        c="\e[38;5;057m" ;;
         58 | 5f5f00 | x058_Orange4)           c="\e[38;5;058m" ;;
         59 | 5f5f5f | x059_Grey37)            c="\e[38;5;059m" ;;
         60 | 5f5f87 | x060_MediumPurple4)     c="\e[38;5;060m" ;;
         61 | 5f5faf | x061_SlateBlue3)        c="\e[38;5;061m" ;;
         62 | 5f5fd7 | x062_SlateBlue3)        c="\e[38;5;062m" ;;
         63 | 5f5fff | x063_RoyalBlue1)        c="\e[38;5;063m" ;;
         64 | 5f8700 | x064_Chartreuse4)       c="\e[38;5;064m" ;;
         65 | 5f875f | x065_DarkSeaGreen4)     c="\e[38;5;065m" ;;
         66 | 5f8787 | x066_PaleTurquoise4)    c="\e[38;5;066m" ;;
         67 | 5f87af | x067_SteelBlue)         c="\e[38;5;067m" ;;
         68 | 5f87d7 | x068_SteelBlue3)        c="\e[38;5;068m" ;;
         69 | 5f87ff | x069_CornflowerBlue)    c="\e[38;5;069m" ;;
         70 | 5faf00 | x070_Chartreuse3)       c="\e[38;5;070m" ;;
         71 | 5faf5f | x071_DarkSeaGreen4)     c="\e[38;5;071m" ;;
         72 | 5faf87 | x072_CadetBlue)         c="\e[38;5;072m" ;;
         73 | 5fafaf | x073_CadetBlue)         c="\e[38;5;073m" ;;
         74 | 5fafd7 | x074_SkyBlue3)          c="\e[38;5;074m" ;;
         75 | 5fafff | x075_SteelBlue1)        c="\e[38;5;075m" ;;
         76 | 5fd700 | x076_Chartreuse3)       c="\e[38;5;076m" ;;
         77 | 5fd75f | x077_PaleGreen3)        c="\e[38;5;077m" ;;
         78 | 5fd787 | x078_SeaGreen3)         c="\e[38;5;078m" ;;
         79 | 5fd7af | x079_Aquamarine3)       c="\e[38;5;079m" ;;
         80 | 5fd7d7 | x080_MediumTurquoise)   c="\e[38;5;080m" ;;
         81 | 5fd7ff | x081_SteelBlue1)        c="\e[38;5;081m" ;;
         82 | 5fff00 | x082_Chartreuse2)       c="\e[38;5;082m" ;;
         83 | 5fff5f | x083_SeaGreen2)         c="\e[38;5;083m" ;;
         84 | 5fff87 | x084_SeaGreen1)         c="\e[38;5;084m" ;;
         85 | 5fffaf | x085_SeaGreen1)         c="\e[38;5;085m" ;;
         86 | 5fffd7 | x086_Aquamarine1)       c="\e[38;5;086m" ;;
         87 | 5fffff | x087_DarkSlateGray2)    c="\e[38;5;087m" ;;
         88 | 870000 | x088_DarkRed)           c="\e[38;5;088m" ;;
         89 | 87005f | x089_DeepPink4)         c="\e[38;5;089m" ;;
         90 | 870087 | x090_DarkMagenta)       c="\e[38;5;090m" ;;
         91 | 8700af | x091_DarkMagenta)       c="\e[38;5;091m" ;;
         92 | 8700d7 | x092_DarkViolet)        c="\e[38;5;092m" ;;
         93 | 8700ff | x093_Purple)            c="\e[38;5;093m" ;;
         94 | 875f00 | x094_Orange4)           c="\e[38;5;094m" ;;
         95 | 875f5f | x095_LightPink4)        c="\e[38;5;095m" ;;
         96 | 875f87 | x096_Plum4)             c="\e[38;5;096m" ;;
         97 | 875faf | x097_MediumPurple3)     c="\e[38;5;097m" ;;
         98 | 875fd7 | x098_MediumPurple3)     c="\e[38;5;098m" ;;
         99 | 875fff | x099_SlateBlue1)        c="\e[38;5;099m" ;;
        100 | 878700 | x100_Yellow4)           c="\e[38;5;100m" ;;
        101 | 87875f | x101_Wheat4)            c="\e[38;5;101m" ;;
        102 | 878787 | x102_Grey53)            c="\e[38;5;102m" ;;
        103 | 8787af | x103_LightSlateGrey)    c="\e[38;5;103m" ;;
        104 | 8787d7 | x104_MediumPurple)      c="\e[38;5;104m" ;;
        105 | 8787ff | x105_LightSlateBlue)    c="\e[38;5;105m" ;;
        106 | 87af00 | x106_Yellow4)           c="\e[38;5;106m" ;;
        107 | 87af5f | x107_DarkOliveGreen3)   c="\e[38;5;107m" ;;
        108 | 87af87 | x108_DarkSeaGreen)      c="\e[38;5;108m" ;;
        109 | 87afaf | x109_LightSkyBlue3)     c="\e[38;5;109m" ;;
        110 | 87afd7 | x110_LightSkyBlue3)     c="\e[38;5;110m" ;;
        111 | 87afff | x111_SkyBlue2)          c="\e[38;5;111m" ;;
        112 | 87d700 | x112_Chartreuse2)       c="\e[38;5;112m" ;;
        113 | 87d75f | x113_DarkOliveGreen3)   c="\e[38;5;113m" ;;
        114 | 87d787 | x114_PaleGreen3)        c="\e[38;5;114m" ;;
        115 | 87d7af | x115_DarkSeaGreen3)     c="\e[38;5;115m" ;;
        116 | 87d7d7 | x116_DarkSlateGray3)    c="\e[38;5;116m" ;;
        117 | 87d7ff | x117_SkyBlue1)          c="\e[38;5;117m" ;;
        118 | 87ff00 | x118_Chartreuse1)       c="\e[38;5;118m" ;;
        119 | 87ff5f | x119_LightGreen)        c="\e[38;5;119m" ;;
        120 | 87ff87 | x120_LightGreen)        c="\e[38;5;120m" ;;
        121 | 87ffaf | x121_PaleGreen1)        c="\e[38;5;121m" ;;
        122 | 87ffd7 | x122_Aquamarine1)       c="\e[38;5;122m" ;;
        123 | 87ffff | x123_DarkSlateGray1)    c="\e[38;5;123m" ;;
        124 | af0000 | x124_Red3)              c="\e[38;5;124m" ;;
        125 | af005f | x125_DeepPink4)         c="\e[38;5;125m" ;;
        126 | af0087 | x126_MediumVioletRed)   c="\e[38;5;126m" ;;
        127 | af00af | x127_Magenta3)          c="\e[38;5;127m" ;;
        128 | af00d7 | x128_DarkViolet)        c="\e[38;5;128m" ;;
        129 | af00ff | x129_Purple)            c="\e[38;5;129m" ;;
        130 | af5f00 | x130_DarkOrange3)       c="\e[38;5;130m" ;;
        131 | af5f5f | x131_IndianRed)         c="\e[38;5;131m" ;;
        132 | af5f87 | x132_HotPink3)          c="\e[38;5;132m" ;;
        133 | af5faf | x133_MediumOrchid3)     c="\e[38;5;133m" ;;
        134 | af5fd7 | x134_MediumOrchid)      c="\e[38;5;134m" ;;
        135 | af5fff | x135_MediumPurple2)     c="\e[38;5;135m" ;;
        136 | af8700 | x136_DarkGoldenrod)     c="\e[38;5;136m" ;;
        137 | af875f | x137_LightSalmon3)      c="\e[38;5;137m" ;;
        138 | af8787 | x138_RosyBrown)         c="\e[38;5;138m" ;;
        139 | af87af | x139_Grey63)            c="\e[38;5;139m" ;;
        140 | af87d7 | x140_MediumPurple2)     c="\e[38;5;140m" ;;
        141 | af87ff | x141_MediumPurple1)     c="\e[38;5;141m" ;;
        142 | afaf00 | x142_Gold3)             c="\e[38;5;142m" ;;
        143 | afaf5f | x143_DarkKhaki)         c="\e[38;5;143m" ;;
        144 | afaf87 | x144_NavajoWhite3)      c="\e[38;5;144m" ;;
        145 | afafaf | x145_Grey69)            c="\e[38;5;145m" ;;
        146 | afafd7 | x146_LightSteelBlue3)   c="\e[38;5;146m" ;;
        147 | afafff | x147_LightSteelBlue)    c="\e[38;5;147m" ;;
        148 | afd700 | x148_Yellow3)           c="\e[38;5;148m" ;;
        149 | afd75f | x149_DarkOliveGreen3)   c="\e[38;5;149m" ;;
        150 | afd787 | x150_DarkSeaGreen3)     c="\e[38;5;150m" ;;
        151 | afd7af | x151_DarkSeaGreen2)     c="\e[38;5;151m" ;;
        152 | afd7d7 | x152_LightCyan3)        c="\e[38;5;152m" ;;
        153 | afd7ff | x153_LightSkyBlue1)     c="\e[38;5;153m" ;;
        154 | afff00 | x154_GreenYellow)       c="\e[38;5;154m" ;;
        155 | afff5f | x155_DarkOliveGreen2)   c="\e[38;5;155m" ;;
        156 | afff87 | x156_PaleGreen1)        c="\e[38;5;156m" ;;
        157 | afffaf | x157_DarkSeaGreen2)     c="\e[38;5;157m" ;;
        158 | afffd7 | x158_DarkSeaGreen1)     c="\e[38;5;158m" ;;
        159 | afffff | x159_PaleTurquoise1)    c="\e[38;5;159m" ;;
        160 | d70000 | x160_Red3)              c="\e[38;5;160m" ;;
        161 | d7005f | x161_DeepPink3)         c="\e[38;5;161m" ;;
        162 | d70087 | x162_DeepPink3)         c="\e[38;5;162m" ;;
        163 | d700af | x163_Magenta3)          c="\e[38;5;163m" ;;
        164 | d700d7 | x164_Magenta3)          c="\e[38;5;164m" ;;
        165 | d700ff | x165_Magenta2)          c="\e[38;5;165m" ;;
        166 | d75f00 | x166_DarkOrange3)       c="\e[38;5;166m" ;;
        167 | d75f5f | x167_IndianRed)         c="\e[38;5;167m" ;;
        168 | d75f87 | x168_HotPink3)          c="\e[38;5;168m" ;;
        169 | d75faf | x169_HotPink2)          c="\e[38;5;169m" ;;
        170 | d75fd7 | x170_Orchid)            c="\e[38;5;170m" ;;
        171 | d75fff | x171_MediumOrchid1)     c="\e[38;5;171m" ;;
        172 | d78700 | x172_Orange3)           c="\e[38;5;172m" ;;
        173 | d7875f | x173_LightSalmon3)      c="\e[38;5;173m" ;;
        174 | d78787 | x174_LightPink3)        c="\e[38;5;174m" ;;
        175 | d787af | x175_Pink3)             c="\e[38;5;175m" ;;
        176 | d787d7 | x176_Plum3)             c="\e[38;5;176m" ;;
        177 | d787ff | x177_Violet)            c="\e[38;5;177m" ;;
        178 | d7af00 | x178_Gold3)             c="\e[38;5;178m" ;;
        179 | d7af5f | x179_LightGoldenrod3)   c="\e[38;5;179m" ;;
        180 | d7af87 | x180_Tan)               c="\e[38;5;180m" ;;
        181 | d7afaf | x181_MistyRose3)        c="\e[38;5;181m" ;;
        182 | d7afd7 | x182_Thistle3)          c="\e[38;5;182m" ;;
        183 | d7afff | x183_Plum2)             c="\e[38;5;183m" ;;
        184 | d7d700 | x184_Yellow3)           c="\e[38;5;184m" ;;
        185 | d7d75f | x185_Khaki3)            c="\e[38;5;185m" ;;
        186 | d7d787 | x186_LightGoldenrod2)   c="\e[38;5;186m" ;;
        187 | d7d7af | x187_LightYellow3)      c="\e[38;5;187m" ;;
        188 | d7d7d7 | x188_Grey84)            c="\e[38;5;188m" ;;
        189 | d7d7ff | x189_LightSteelBlue1)   c="\e[38;5;189m" ;;
        190 | d7ff00 | x190_Yellow2)           c="\e[38;5;190m" ;;
        191 | d7ff5f | x191_DarkOliveGreen1)   c="\e[38;5;191m" ;;
        192 | d7ff87 | x192_DarkOliveGreen1)   c="\e[38;5;192m" ;;
        193 | d7ffaf | x193_DarkSeaGreen1)     c="\e[38;5;193m" ;;
        194 | d7ffd7 | x194_Honeydew2)         c="\e[38;5;194m" ;;
        195 | d7ffff | x195_LightCyan1)        c="\e[38;5;195m" ;;
        196 | ff0000 | x196_Red1)              c="\e[38;5;196m" ;;
        197 | ff005f | x197_DeepPink2)         c="\e[38;5;197m" ;;
        198 | ff0087 | x198_DeepPink1)         c="\e[38;5;198m" ;;
        199 | ff00af | x199_DeepPink1)         c="\e[38;5;199m" ;;
        200 | ff00d7 | x200_Magenta2)          c="\e[38;5;200m" ;;
        201 | ff00ff | x201_Magenta1)          c="\e[38;5;201m" ;;
        202 | ff5f00 | x202_OrangeRed1)        c="\e[38;5;202m" ;;
        203 | ff5f5f | x203_IndianRed1)        c="\e[38;5;203m" ;;
        204 | ff5f87 | x204_IndianRed1)        c="\e[38;5;204m" ;;
        205 | ff5faf | x205_HotPink)           c="\e[38;5;205m" ;;
        206 | ff5fd7 | x206_HotPink)           c="\e[38;5;206m" ;;
        207 | ff5fff | x207_MediumOrchid1)     c="\e[38;5;207m" ;;
        208 | ff8700 | x208_DarkOrange)        c="\e[38;5;208m" ;;
        209 | ff875f | x209_Salmon1)           c="\e[38;5;209m" ;;
        210 | ff8787 | x210_LightCoral)        c="\e[38;5;210m" ;;
        211 | ff87af | x211_PaleVioletRed1)    c="\e[38;5;211m" ;;
        212 | ff87d7 | x212_Orchid2)           c="\e[38;5;212m" ;;
        213 | ff87ff | x213_Orchid1)           c="\e[38;5;213m" ;;
        214 | ffaf00 | x214_Orange1)           c="\e[38;5;214m" ;;
        215 | ffaf5f | x215_SandyBrown)        c="\e[38;5;215m" ;;
        216 | ffaf87 | x216_LightSalmon1)      c="\e[38;5;216m" ;;
        217 | ffafaf | x217_LightPink1)        c="\e[38;5;217m" ;;
        218 | ffafd7 | x218_Pink1)             c="\e[38;5;218m" ;;
        219 | ffafff | x219_Plum1)             c="\e[38;5;219m" ;;
        220 | ffd700 | x220_Gold1)             c="\e[38;5;220m" ;;
        221 | ffd75f | x221_LightGoldenrod2)   c="\e[38;5;221m" ;;
        222 | ffd787 | x222_LightGoldenrod2)   c="\e[38;5;222m" ;;
        223 | ffd7af | x223_NavajoWhite1)      c="\e[38;5;223m" ;;
        224 | ffd7d7 | x224_MistyRose1)        c="\e[38;5;224m" ;;
        225 | ffd7ff | x225_Thistle1)          c="\e[38;5;225m" ;;
        226 | ffff00 | x226_Yellow1)           c="\e[38;5;226m" ;;
        227 | ffff5f | x227_LightGoldenrod1)   c="\e[38;5;227m" ;;
        228 | ffff87 | x228_Khaki1)            c="\e[38;5;228m" ;;
        229 | ffffaf | x229_Wheat1)            c="\e[38;5;229m" ;;
        230 | ffffd7 | x230_Cornsilk1)         c="\e[38;5;230m" ;;
        231 | ffffff | x231_Grey100)           c="\e[38;5;231m" ;;
        232 | 080808 | x232_Grey3)             c="\e[38;5;232m" ;;
        233 | 121212 | x233_Grey7)             c="\e[38;5;233m" ;;
        234 | 1c1c1c | x234_Grey11)            c="\e[38;5;234m" ;;
        235 | 262626 | x235_Grey15)            c="\e[38;5;235m" ;;
        236 | 303030 | x236_Grey19)            c="\e[38;5;236m" ;;
        237 | 3a3a3a | x237_Grey23)            c="\e[38;5;237m" ;;
        238 | 444444 | x238_Grey27)            c="\e[38;5;238m" ;;
        239 | 4e4e4e | x239_Grey30)            c="\e[38;5;239m" ;;
        240 | 585858 | x240_Grey35)            c="\e[38;5;240m" ;;
        241 | 626262 | x241_Grey39)            c="\e[38;5;241m" ;;
        242 | 6c6c6c | x242_Grey42)            c="\e[38;5;242m" ;;
        243 | 767676 | x243_Grey46)            c="\e[38;5;243m" ;;
        244 | 808080 | x244_Grey50)            c="\e[38;5;244m" ;;
        245 | 8a8a8a | x245_Grey54)            c="\e[38;5;245m" ;;
        246 | 949494 | x246_Grey58)            c="\e[38;5;246m" ;;
        247 | 9e9e9e | x247_Grey62)            c="\e[38;5;247m" ;;
        248 | a8a8a8 | x248_Grey66)            c="\e[38;5;248m" ;;
        249 | b2b2b2 | x249_Grey70)            c="\e[38;5;249m" ;;
        250 | bcbcbc | x250_Grey74)            c="\e[38;5;250m" ;;
        251 | c6c6c6 | x251_Grey78)            c="\e[38;5;251m" ;;
        252 | d0d0d0 | x252_Grey82)            c="\e[38;5;252m" ;;
        253 | dadada | x253_Grey85)            c="\e[38;5;253m" ;;
        254 | e4e4e4 | x254_Grey89)            c="\e[38;5;254m" ;;
        255 | eeeeee | x255_Grey93)            c="\e[38;5;255m" ;;
    esac

    echo -n "${c:-$1}"
}

resetColor() {
    echo "\e[0m"
}

pColor() {
    echo -n "\["; color $1; echo -n "\]"
}

pResetColor() {
    echo "\[\e[0m\]"
}
#</editor-fold>

dotfiles-update() {
    (cd ~/.dotfiles && git update)
    ~/.dotfiles/install
}

dotfiles-diff-local() {
    BASEDIR=~/.dotfiles

    while IFS= read -r -d '' srcFilePath
    do
        dstFilePath="${srcFilePath%.example}"
        [[ -f "${dstFilePath}" ]] || dstFilePath=/dev/null

        git diff --no-index "${srcFilePath}" "${dstFilePath}"

        has_diff=$?
        echo
        [[ $has_diff -eq 0 ]] && {
            local silver="\e[38;5;7m"
            local grey="\e[38;5;8m"
            local reset="\e[0m"
            local dstSize=${#dstFilePath}

            echo -en "${grey}"; for ((i=1; i<=((dstSize + 2)); i++)); do echo -n '─'; done; echo "┐"
            echo -e "${silver}${dstFilePath}: ${grey}│"
            for ((i=1; i<=((dstSize + 2)); i++)); do echo -n '─'; done
            echo -n "┴"
            for ((i=1; i<=((COLUMNS - dstSize - 3)); i++)); do echo -n '─'; done; echo
            echo -e "\n      ${silver}\e[3munchanged${reset}\n"
        }
    done < <(find "$BASEDIR" -iname "*.local.example" -print0)
}

ssh-list-tunnels() {
    # -a       This option causes list selection options to be ANDed.
    # -b       Causes lsof to avoid kernel functions that might block (lstat, readlink, stat).
    # -l       This option inhibits the conversion of user ID numbers to login names.
    # -n       This option inhibits the conversion of network numbers to host names for network files.
    # -P       This option inhibits the conversion of port numbers to port names for network files.
    # +|-w     Enables (+) or disables (-) the suppression of warning messages.
    # -T [t]   This option controls the reporting of some TCP/TPI information
    #          -T with no following key characters disables TCP/TPI information reporting.
    # -i [i]   This option selects the listing of files any of whose Internet address matches the address specified in i.
    # -c c     This option selects the listing of files for processes executing the command that begins with the characters of c.
    #          If c begins and ends with a slash ('/'), the characters between the slashes are interpreted as a regular expression.
    # -u s     This option selects the listing of files for the user whose login names or user ID numbers are in the comma-separated set s
    # -s [p:s] The optional -s p:s form is available only for selected dialects, and only when the -h or -? help output lists it.
    #          When the optional form is available, the s may be followed by a protocol name (p), either TCP or UDP, a colon (`:') and a
    #          comma-separated protocol state name list, the option causes open TCP and UDP files to be excluded if their state name(s) are
    #          in the list (s) preceded by a `^'; or included if their name(s) are not preceded by a `^'.
    lsof -ablnPw -T -i4  -c '/^ssh$/' -u$USER -s TCP:LISTEN
}

ssh-list-tunnel-ports() {
    local sshTunnels
    sshTunnels="$(ssh-list-tunnels | tail -n +2 | cut -d: -f2 | tr '\n' ',')"
    sshTunnels=${sshTunnels%,}
    [[ -n $sshTunnels ]] && echo $sshTunnels
}

git-context-graph-page() {
    local margin=8
    local lines=$((LINES - margin))
    git context-graph --first-parent "-n${lines}" "$@" | head -n $lines
}

# shellcheck disable=SC2086
git-graph-status-page() {
    local margin=12
    local reset="\e[0m"
    local grey="\033[0;90m"

    local COLUMNS=${COLUMNS:-$(tput cols 2>/dev/null)}
    local LINES=${LINES:-$(tput lines 2>/dev/null)}

    #local status_options=""
    local status_options="-s -b"
    local status; status=$(git -c color.status=always status ${status_options})

    local slines; slines=$(wc -l <<< "$status")
    local minlines=10
    local lines=$((LINES - slines - margin))
    lines=$((lines < minlines ? minlines : lines))

    local separator; separator="${grey}$(eval "printf -- '-%.s' {1..${COLUMNS}}")${reset}"

    # clear -x
    #echo -e "$separator"
    echo
    git context-graph --first-parent "-n${lines}" "$@" | head -n ${lines}
    echo
    echo -e "$separator"
    echo
    echo "$status"
    echo
}

## Launch a program and monitor it
# https://stackoverflow.com/a/40576129
#   %cpu
#   %mem
#   VSZ: Virtual Memory Size (includes all memory that the process can access (inc. swapped, allocated but unused, shared libs)
#   RSS: Resident Set Size (show how much memory is allocated to that process and is in RAM)
topp() (
    if [ -n "$O" ]; then
        $* &
    else
        $* &>/dev/null &
    fi
    pid="$!"
    trap "kill $pid" SIGINT
    o='%cpu,%mem,vsz,rss'
    printf '%s\n' "$o"
    i=0
    while s="$(ps --no-headers -o "$o" -p "$pid")"; do
        printf "$i $s\n"
        i=$(($i + 1))
        sleep "${T:-0.1}"
    done
)

################################################################################
# tmux

# https://morsecodist.io/blog/tmac

tmac() {
    local name=${1:-${TMUX_DEFAULT_SESSION:-$(hostname)}}

    if [[ $name = '-' ]]; then
        tmux attach 2>/dev/null || tmux new-session -s ${TMUX_DEFAULT_SESSION:-$(hostname)}
        return
    fi

    tmux has-session -t "$name" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        tmux attach -t "$name"
        return
    fi

    tmux new-session -s "$name"
}

_tmac_complete() {
    local word=${COMP_WORDS[COMP_CWORD]}
    local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
    COMPREPLY=( $(compgen -W "$sessions" -- "$word") )
}

complete -F _tmac_complete tmac

################################################################################
# Docker

source ~/.dotfiles/dockerize-clis/dockerize-clis.sh
