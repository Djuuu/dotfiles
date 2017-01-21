###################################################################################################
# https://github.com/emilis/emilis-config/blob/master/.bash_ps1

# Fill with minuses (this is recalculated every time the prompt is shown in function prompt_command)
promptFill="--- "
# resetColor='\[\033[00m\]'
if [ -z "$VIM" ];
then status_style=$resetColor'\[\033[0;90m\]' # gray color; use 0;37m for lighter color
else status_style=$resetColor'\[\033[0;90;107m\]'
fi


# Reset color for command output (this one is invoked every time before a command is executed):
#trap 'echo -ne "\e[0m"' DEBUG
function separator_prompt_command {
    # create a $promptFill of all screen width minus the time string and a space:
    let promptFillSize=${COLUMNS}-9
    promptFill=""
    while [ "$promptFillSize" -gt "0" ]
    do
        promptFill="-${promptFill}" # fill with underscores to work on
        let promptFillSize=${promptFillSize}-1
    done

    OLD_PS1="$PS1"
    PS1="$status_style"'$promptFill \t\n'"${resetColor}$OLD_PS1"
}
