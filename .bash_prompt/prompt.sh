
. ~/.bash_prompt/colors.sh
. ~/.bash_prompt/git.sh
. ~/.bash_prompt/separator.sh
. ~/.bash_prompt/newline-narrow-prompt.sh

function prompt_command {
	git_prompt_command
	separator_prompt_command
	newline_narrow_prompt_command
}

PROMPT_COMMAND=prompt_command
