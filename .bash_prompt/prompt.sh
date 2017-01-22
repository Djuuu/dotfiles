
. ~/.bash_prompt/colors.sh
. ~/.bash_prompt/git.sh
. ~/.bash_prompt/separator.sh

function prompt_command {
	git_prompt_command
	separator_prompt_command
}

PROMPT_COMMAND=prompt_command
