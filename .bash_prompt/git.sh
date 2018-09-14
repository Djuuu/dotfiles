###################################################################################################
# https://raw.githubusercontent.com/matthewmccullough/dotfiles/master/bash_gitprompt

function parse_git_branch {
	# exit if not in a Git repository
	git rev-parse --git-dir &> /dev/null

	# patterns  
	branch_pattern="On branch ([^${IFS}]*)"
	branch_rebase_pattern="You are currently rebasing branch '([^${IFS}]*)'"
	remote_pattern="Your branch is (.*) '"
	diverge_pattern="Your branch and (.*) have diverged"
	clean_pattern="clean"
	changes_pattern="Changes "

	git_status="$(LANG=en git -c status.submoduleSummary=false status 2> /dev/null)"

	if [[ ! ${git_status} =~ ${clean_pattern} ]]; then
		if [[ ${git_status} =~ ${changes_pattern} ]]; then
			state="${redTxt} ✘"
		else
			state="${yellowTxt} ✔"
		fi
	else 
		state="${greenTxt} ✔"
	fi

	# add an else if or two here if you want to get more specific
	if [[ ${git_status} =~ ${remote_pattern} ]]; then
		if [[ ${BASH_REMATCH[1]} == "ahead of" ]]; then
			remote="${greenTxt} ↑"
		elif [[ ${BASH_REMATCH[1]} == "behind" ]]; then
			remote="${yellowTxt} ↓"
		else
			remote="${greenTxt} ↔"
		fi
	fi

	if [[ ${git_status} =~ ${diverge_pattern} ]]; then
		remote="${yellowTxt} ↕"
	fi

	if [[ ${git_status} =~ ${branch_pattern} ]]; then
		branch=${BASH_REMATCH[1]}
	fi

	if [[ ${git_status} =~ ${branch_rebase_pattern} ]]; then
		branch=${BASH_REMATCH[1]}
		state="${redTxt} ☈"
	fi

	if [[ ! -z ${branch} ]]; then
		echo " (${branch})${remote}${state} "
	fi
}

function git_dirty_flag {
	git status 2> /dev/null | grep -c : | awk '{if ($1 > 0) print " Z"}'
}

function git_prompt_command {

	defaultWindowTitle="${DEFAULT_WINDOW_TITLE:-\h - \W}"
	titlebar="\[\e]0;${FORCED_WINDOW_TITLE:-${defaultWindowTitle}}\a\]"

	userHost="${userHostPromptColor}\u@\h${whiteTxt}:"
	cwd="${dirPromptColor}\w"
	gitStatus="${purpleTxt}$(parse_git_branch)"

	promptEnd="${resetColor}${promptSign} "

	PS1="${titlebar}${userHost}${cwd}${gitStatus}${promptEnd}"
}
