#!/usr/bin/env bash

## References:
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# https://github.com/magicmonty/bash-git-prompt

PROMPT_GIT_REMOTE_COUNTERS=${PROMPT_GIT_REMOTE_COUNTERS:-1}
PROMPT_GIT_STATE_COUNTERS=${PROMPT_GIT_STATE_COUNTERS:-0}
PROMPT_GIT_STATE_MODE=${PROMPT_GIT_STATE_MODE:-summary}

# Set the $promptGit variable
# Call in PROMPT_COMMAND and use $promptGit in PS1
prompt_git() {
    # Global variable, usable in PS1
    promptGit=""

    local gitDir
    gitDir="$(git rev-parse --git-dir 2>/dev/null)" || return # Not a git repository

    local branchLine
    local untracked=0 changed=0 deleted=0 staged=0 conflicts=0
    __prompt_git_extract_statuses

    local branch ahead=0 behind=0 detached=0
    __prompt_git_extract_branch_remote "$branchLine"

    # local promptGitRemote=""
    # __prompt_git_set_remote_icon $ahead $behind

    local promptGitBranchInfo
    __prompt_git_set_branch_info "$branch" $ahead $behind $detached

    local promptGitAction
    __prompt_git_set_action

    local promptGitState
    __prompt_git_set_state

    # __prompt_git_debug

    promptGit="${promptGitBranchInfo}${promptGitAction}${promptGitState}$(pResetColor) "
}

##
## Git prompt var helpers
##

# Store statuses in the following variables:
#  - $branchLine (first line of `git status -sb`)
#  - $untracked
#  - $changed
#  - $deleted
#  - $staged
#  - $conflicts
__prompt_git_extract_statuses() {
    # External affected vars
    branchLine=; untracked=; changed=; deleted=; staged=; conflicts=;

    local statusLine status

    while IFS='' read -r statusLine || [[ -n "${statusLine}" ]]; do
        status="${statusLine:0:2}"
        while [[ -n ${status} ]]; do
            case "${status}" in
                \#\#) branchLine="${statusLine/\.\.\./^}"; break ;;

                \?\?) ((untracked++)); break ;;
                U?)   ((conflicts++)); break ;;
                ?U)   ((conflicts++)); break ;;
                DD)   ((conflicts++)); break ;;
                AA)   ((conflicts++)); break ;;

                ?M) ((changed++)) ;;
                ?D) ((deleted++)) ;;
                ?\ ) ;;

                U) ((conflicts++)) ;;
                \ ) ;;

                *) ((staged++)) ;;
            esac
            status="${status:0:(${#status}-1)}"
        done
    done <<< "$(
        LANG=C git \
            --no-optional-locks \
            status \
            --ignore-submodules \
            --porcelain \
            --branch \
            2>/dev/null
    )"
}

# Store current branch & remote info in variables:
#  - $branch
#  - $ahead
#  - $behind
#  - $detached
__prompt_git_extract_branch_remote() {
    local branchLine=$1

    local branchFields fields

    IFS="^" read -ra branchFields <<< "${branchLine/\#\# }"
    branch="${branchFields[0]}"

    ahead=0
    behind=0
    detached=0

    if [[ "${branch}" == *"Initial commit on"* ]]; then
        IFS=" " read -ra fields <<< "${branch}"
        branch="${fields[3]}"
    elif [[ "${branch}" == *"No commits yet on"* ]]; then
        IFS=" " read -ra fields <<< "${branch}"
        branch="${fields[4]}"
    elif [[ "${branch}" == *"no branch"* ]]; then
        branch="$(git rev-parse --short HEAD)"
        detached=1
    else
        if [[ "${#branchFields[@]}" -ne 1 ]]; then
            IFS="[,]" read -ra fields <<< "${branchFields[1]}"

            local upstream
            upstream="${fields[0]}"
            upstream="${upstream% }"

            local remote_field
            for remote_field in "${fields[@]}"; do
                if [[ "${remote_field}" == "ahead "* ]]; then
                    ahead="${remote_field:6}"
                fi
                if [[ "${remote_field}" == "behind "* ]] || [[ "${remote_field}" == " behind "* ]]; then
                    behind="${remote_field:7}"
                    behind="${behind# }"
                fi
            done
        fi
    fi
}

# Set the following variable depending on ahead/behind status:
#  - $promptGitRemote
__prompt_git_set_remote_icon() {
    local ahead=${1:-0}
    local behind=${2:-0}

    # External affected vars
    promptGitRemote=""

    if [[ $ahead -gt 0 && $behind -eq 0 ]]; then
        promptGitRemote="${promptGitRemote}$(pColor greenBold)" # nf-fa-arrow_up

    elif [[ $ahead -eq 0 && $behind -gt 0 ]]; then
        promptGitRemote="${promptGitRemote}$(pColor yellowBold)" # nf-fa-arrow_down

    elif [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        promptGitRemote="${promptGitRemote}$(pColor yellowBold)" # nf-fa-arrows_up_down

    fi

    [[ -n $promptGitRemote ]] &&
        promptGitRemote=" ${promptGitRemote}$(pResetColor)"
}

# Set the following variable:
#  - $promptGitBranchInfo
__prompt_git_set_branch_info() {
    local branch=$1
    local ahead=$2
    local behind=$3
    local detached=$4

    # External affected vars
    promptGitBranchInfo=

    if [[ $detached -eq 1 ]]; then
        promptGitBranchInfo="$(pColor purple)(  ${branch})" # nf-fa-code_commit
        return
    fi

    local branchRemote
    branchRemote=$(git config --get "branch.${branch}.remote")

    local remoteUrl remoteIcon="" branchIcon=""
    if [[ -n $branchRemote ]]; then
        remoteUrl=$(git remote get-url "$branchRemote")
        if   [[ $remoteUrl == *"github.com"*    ]]; then remoteIcon="" # nf-dev-github
        elif [[ $remoteUrl == *"gitlab.com"*    ]]; then remoteIcon="" # nf-seti-gitlab
        elif [[ $remoteUrl == *"bitbucket.org"* ]]; then remoteIcon="" # nf-dev-bitbucket
        else                                             remoteIcon="" # nf-linux-forgejo
        fi
        branchIcon=${remoteIcon}
    else
        branchIcon="" # nf-dev-git_branch
    fi

    promptGitBranchInfo="$(pColor purple)(${branchIcon} ${branch}"

    local remoteStatus remoteStatusA=()

    local a b
    if [[ $PROMPT_GIT_REMOTE_COUNTERS -eq 1 ]]; then
        a=${ahead}
        b=${behind}
    fi

    [[ $ahead -gt 0  ]] && remoteStatusA+=("$(pColor green)↑${a}")
    [[ $behind -gt 0 ]] && remoteStatusA+=("$(pColor red  )↓${b}")

    if [[ $PROMPT_GIT_REMOTE_COUNTERS -eq 1 ]]; then
        remoteStatus=${remoteStatusA[*]} # Join with spaces
    else
        remoteStatus=$(IFS=; echo "${remoteStatusA[*]}") # Join without spaces
    fi

    [[ -n $remoteStatus ]] && remoteStatus=" $remoteStatus" # Add leading space

    promptGitBranchInfo="${promptGitBranchInfo}${remoteStatus}$(pColor purple))"
}

# Extract the following variables:
#  - $gitAction
#  - $rebaseStep
#  - $rebaseTotal
#  - $rebaseHeadName
#  - $rebaseOnto
#  - $rebaseOntoBranch
__prompt_git_extract_action_info() {
    # External affected vars
    gitAction=; rebaseStep=; rebaseTotal=; rebaseHeadName=; rebaseOnto=; rebaseOntoBranch=;

    if [[ -d "${gitDir}/rebase-merge" ]]; then
        gitAction="rebase"

        __git_prompt_readval "${gitDir}/rebase-merge/msgnum"    rebaseStep
        __git_prompt_readval "${gitDir}/rebase-merge/end"       rebaseTotal
        __git_prompt_readval "${gitDir}/rebase-merge/head-name" rebaseHeadName
        __git_prompt_readval "${gitDir}/rebase-merge/onto"      rebaseOnto

        rebaseHeadName=${rebaseHeadName#refs/heads/}
        rebaseOntoBranch=$(__git_prompt_get_commit_branch "${rebaseOnto}")
        [[ -z $rebaseOntoBranch ]] && rebaseOntoBranch=$(git rev-parse --short "${rebaseOnto}")
        return
    fi

    if [[ -d "${gitDir}/rebase-apply" ]]; then
        __git_prompt_readval "${gitDir}/rebase-apply/next" rebaseStep
        __git_prompt_readval "${gitDir}/rebase-apply/last" rebaseTotal

        if [[ -f "${gitDir}/rebase-apply/rebasing" ]]; then
            gitAction="rebase"
            __git_prompt_readval "${gitDir}/rebase-apply/head-name" rebaseHeadName
            __git_prompt_readval "${gitDir}/rebase-apply/onto"      rebaseOnto # TODO: check

            rebaseHeadName=${rebaseHeadName#refs/heads/}
            rebaseOntoBranch=$(__git_prompt_get_commit_branch "${rebaseOnto}")
            [[ -z $rebaseOntoBranch ]] && rebaseOntoBranch=$(git rev-parse --short "${rebaseOnto}")
        fi

        # TODO: am
        return
    fi

    if   [[ -f "${gitDir}/MERGE_HEAD"       ]]; then gitAction="merge"
    elif [[ -f "${gitDir}/CHERRY_PICK_HEAD" ]]; then gitAction="cherry-pick"
    elif [[ -f "${gitDir}/REVERT_HEAD"      ]]; then gitAction="revert"
    elif [[ -f "${gitDir}/BISECT_LOG"       ]]; then gitAction="bisect"
    fi
}

# Set the $promptGitAction variable
__prompt_git_set_action() {
    # External affected vars
    promptGitAction=

    local gitAction="" rebaseStep="" rebaseTotal="" rebaseHeadName="" rebaseOnto="" rebaseOntoBranch=""

    __prompt_git_extract_action_info

    case "${gitAction}" in
        rebase)
            local rebaseTarget rebaseProgress doneColor

            doneColor=$(pColor yellow)
            [[ $conflicts -gt 0 ]] && doneColor=$(pColor red)

            rebaseProgress="$(pColor white)(${doneColor}${rebaseStep}$(pColor white)/${rebaseTotal})"
            rebaseTarget="$(pColor blackBold)[$(pColor yellow)${rebaseHeadName}$(pColor blackBold) ↷ $(pColor cyan)${rebaseOntoBranch}$(pColor blackBold)]"

            promptGitAction="\n $(pColor redBold)☈ ${rebaseTarget} ${rebaseProgress}"
            ;;
        merge)       promptGitAction=" $(pColor red   )"  ;; # nf-oct-git_merge
        cherry-pick) promptGitAction=" $(pColor red   )"  ;; # nf-fae-cherry
        revert)      promptGitAction=" $(pColor red   ) " ;; # nf-fa-rotate_left
        bisect)      promptGitAction=" $(pColor yellow)?" ;; # nf-fa-arrows_up_down
        *)           promptGitAction="" ;;
    esac
}

# Set the $promptGitState variable
__prompt_git_set_state() {
    # External affected vars
    promptGitState=

    local promptGitStateA=()

    if [[ $untracked -eq 0 && $changed -eq 0 && $deleted -eq 0 && $staged -eq 0 && $conflicts -eq 0 ]]; then
        promptGitState=" ${promptUserColor:-}" # nf-cod-sparkle
        return
    fi

    local ch dl ut md st cf
    if [[ $PROMPT_GIT_STATE_COUNTERS -eq 1 ]]; then
        ch="${changed}"
        dl="${deleted}"
        ut="${untracked}"
        md="$(( changed + deleted + untracked ))"
        st="${staged}"
        cf="${conflicts}"
    fi

    case "${PROMPT_GIT_STATE_MODE}" in
        detail*)
            [[ $changed   -gt 0 ]] && promptGitStateA+=("$(pColor yellow) ${ch}") # nf-cod-request_changes
            [[ $deleted   -gt 0 ]] && promptGitStateA+=("$(pColor red   )󰍴${dl}") # nf-md-minus
            [[ $untracked -gt 0 ]] && promptGitStateA+=("$(pColor green )${ut}") # nf-oct-plus
            [[ $staged    -gt 0 ]] && promptGitStateA+=("$(pColor green ) ${st}") # nf-cod-request_changes
            [[ $conflicts -gt 0 ]] && promptGitStateA+=("$(pColor red   ) ${cf}") # nf-fa-arrows_left_right
            ;;
        summary)
            if [[ $changed -gt 0 || $deleted -gt 0 ]]; then # Misc. changes
                promptGitStateA+=("$(pColor yellow) ${md}") # nf-cod-request_changes
            elif [[ $untracked -gt 0 ]] && [[ $changed -eq 0 || $deleted -eq 0 ]]; then # Only untracked
                [[ -z $ut ]] && ut=" "
                promptGitStateA+=("$(pColor green)${ut}") # nf-oct-plus
            fi
            [[ $staged    -gt 0 ]] && promptGitStateA+=("$(pColor green) ${st}") # nf-cod-request_changes
            [[ $conflicts -gt 0 ]] && promptGitStateA+=("$(pColor red  ) ${cf}") # nf-fa-arrows_left_right
            ;;
    esac

    if [[ $PROMPT_GIT_STATE_COUNTERS -eq 1 ]]; then
        promptGitState=${promptGitStateA[*]} # Join with spaces
    else
        promptGitState=$(IFS=; echo "${promptGitStateA[*]}") # Join without spaces
    fi

    [[ -n $promptGitState ]] && promptGitState=" ${promptGitState% }"
}

##
## Git prompt general helpers
##

# Get branch name attached to given commit
__git_prompt_get_commit_branch() {
    local commit=$1

    git log \
        --oneline \
        --no-abbrev-commit \
        --decorate \
        --simplify-by-decoration \
        --decorate-refs='refs/heads/*' \
        --decorate-refs='refs/remotes/*' "$commit" | # select only commits with a branch
        head -n1 | grep "$commit"                  | # keep only current commit, if it actually has a branch
        sed 's/[a-f0-9]\+ (\([^)]*\)) .*/\1/'      | # filter out everything but decorations
        sed -e 's/, /\n/g'                         | # splits decorations
        tail -n1                                     # keep only last decoration
}

# Read first line of file into variable
__git_prompt_readval() {
    local file=$1
    local varName=$2

    [[ -r "$file" ]] && IFS=$'\r\n' read -r "${varName?}" <"$file"
}

# Debug intermediary vars
__prompt_git_debug() {
    echo
    echo "branch:   $branch"
    echo "detached: $detached"
    echo "ahead:    $ahead"
    echo "behind:   $behind"
    echo
    echo "untracked: $untracked"
    echo "changed:   $changed"
    echo "deleted:   $deleted"
    echo "staged:    $staged"
    echo "conflicts: $conflicts"
    echo
}

## Nerd font icon reference:

# nf-dev-github             \ue709        
# nf-seti-gitlab            \ue65c        
# nf-dev-bitbucket          \ue703        
# nf-linux-forgejo          \uf335        

# nf-dev-git_branch         \ue725        
# nf-fa-code_commit         \uf172        

# nf-fa-arrow_down          \uf063        
# nf-fa-arrow_up            \uf062        
# nf-fa-arrows_up_down      \uf07d        

# nf-oct-git_merge          \uf419        
# nf-fa-rotate_left         \uf2ea        
# nf-fae-cherry             \ue29b        

# nf-oct-plus               \uf44d        
# nf-md-minus               \udb80\udf74  󰍴
# nf-cod-request_changes    \ueb43        
# nf-fa-arrows_left_right   \uf07e        
# nf-cod-sparkle            \uec10        
