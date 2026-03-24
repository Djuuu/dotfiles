#!/usr/bin/env bash

###############################################################################
# Git prompt functions
#
# References:
# - https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# - https://github.com/magicmonty/bash-git-prompt
#

# Configuration
PROMPT_GIT_REMOTE_COUNTERS=${PROMPT_GIT_REMOTE_COUNTERS:-1}
PROMPT_GIT_STATE_COUNTERS=${PROMPT_GIT_STATE_COUNTERS:-0}
PROMPT_GIT_STATE_MODE=${PROMPT_GIT_STATE_MODE:-summary}
PROMPT_GIT_DISABLE_IN_TMUX=${PROMPT_GIT_DISABLE_IN_TMUX:-0}

# Icons
_g_ico_github=''     # nf-dev-github             \ue709
_g_ico_gitlab=''     # nf-seti-gitlab            \ue65c
_g_ico_bitbucket=''  # nf-dev-bitbucket          \ue703
_g_ico_forgejo=''    # nf-linux-forgejo          \uf335

_g_ico_branch=''     # nf-dev-git_branch         \ue725
_g_ico_commit=' '    # nf-fa-code_commit         \uf172

_g_ico_down=''       # nf-fa-arrow_down          \uf063
_g_ico_up=''         # nf-fa-arrow_up            \uf062
_g_ico_updown=''     # nf-fa-arrows_up_down      \uf07d

_g_ico_merge=''      # nf-oct-git_merge          \uf419
_g_ico_revert=' '    # nf-fa-rotate_left         \uf2ea
_g_ico_cherry=''     # nf-fae-cherry             \ue29b
_g_ico_rebase='☈'     #                           \u2608
_g_ico_onto='↷'       #                           \u21b7
_g_ico_bisect='?'    # nf-fa-arrows_up_down      \uf07d ?

_g_ico_plus=''       # nf-oct-plus               \uf44d
_g_ico_minus='󰍴'      # nf-md-minus               \udb80\udf74
_g_ico_chng=' '      # nf-cod-request_changes    \ueb43
_g_ico_lr=' '        # nf-fa-arrows_left_right   \uf07e
_g_ico_clean=' '     # nf-cod-sparkle            \uec10


# Set the $pt_git variable
# Call in PROMPT_COMMAND and use $pt_git in PS1
prompt_git() {
    # Global variables, usable in PS1
    pt_git=""
    pt_gitRemoteSt=""
    pt_gitBranchInfo=""
    pt_gitAction=""
    pt_gitState=""

    [[ -n $TMUX ]] && [[ $PROMPT_GIT_DISABLE_IN_TMUX -eq 1 ]] && return

    local gitDir
    gitDir="$(git rev-parse --git-dir 2>/dev/null)" || return # Not a git repository

    local branchLine
    local untracked=0 changed=0 deleted=0 staged=0 conflicts=0
    __prompt_git_extract_statuses

    local branch ahead=0 behind=0 detached=0
    __prompt_git_extract_branch_remote "$branchLine"

    __prompt_git_set_remote_status_icon $ahead $behind

    __prompt_git_set_branch_info "$branch" $ahead $behind $detached

    __prompt_git_set_action

    __prompt_git_set_state

    # __prompt_git_debug

    pt_git="${pt_gitBranchInfo}${pt_gitAction}${pt_gitState}${pt_reset}"
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
#  - $pt_gitRemoteSt
__prompt_git_set_remote_status_icon() {
    local ahead=${1:-0}
    local behind=${2:-0}

    # External affected vars
    pt_gitRemoteSt=""

    if [[ $ahead -gt 0 && $behind -eq 0 ]]; then
        pt_gitRemoteSt="${pt_gitRemoteSt}${pt_greenBold}${_g_ico_up}"

    elif [[ $ahead -eq 0 && $behind -gt 0 ]]; then
        pt_gitRemoteSt="${pt_gitRemoteSt}${pt_yellowBold}${_g_ico_down}"

    elif [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        pt_gitRemoteSt="${pt_gitRemoteSt}${pt_yellowBold}${_g_ico_updown}"
    fi

    [[ -n $pt_gitRemoteSt ]] &&
        pt_gitRemoteSt=" ${pt_gitRemoteSt}${pt_reset}"
}

# Set the following variable:
#  - $pt_gitBranchInfo
__prompt_git_set_branch_info() {
    local branch=$1
    local ahead=$2
    local behind=$3
    local detached=$4

    # External affected vars
    pt_gitBranchInfo=

    if [[ $detached -eq 1 ]]; then
        pt_gitBranchInfo="${pt_purple}(${_g_ico_commit} ${branch}) "
        return
    fi

    local branchRemote
    branchRemote=$(git config --get "branch.${branch}.remote")

    local remoteUrl remoteIcon="" branchIcon=""
    if [[ -n $branchRemote ]]; then
        remoteUrl=$(git remote get-url "$branchRemote")
        if   [[ $remoteUrl == *"github.com"*    ]]; then remoteIcon="${_g_ico_github}"
        elif [[ $remoteUrl == *"gitlab.com"*    ]]; then remoteIcon="${_g_ico_gitlab}"
        elif [[ $remoteUrl == *"bitbucket.org"* ]]; then remoteIcon="${_g_ico_bitbucket}"
        else                                             remoteIcon="${_g_ico_forgejo}"
        fi
        branchIcon=${remoteIcon}
    else
        branchIcon="${_g_ico_branch}"
    fi

    pt_gitBranchInfo="${pt_purple}(${branchIcon} ${branch}"

    ## single icon remote status
    #pt_gitBranchInfo="${pt_gitBranchInfo}${pt_gitRemoteSt}${pt_purple}) "
    #return

    local remoteStatus remoteStatusA=()

    local a b
    if [[ $PROMPT_GIT_REMOTE_COUNTERS -eq 1 ]]; then
        a=${ahead}
        b=${behind}
    fi

    [[ $ahead -gt 0  ]] && remoteStatusA+=("${pt_green}↑${a}")
    [[ $behind -gt 0 ]] && remoteStatusA+=("${pt_red}↓${b}")

    if [[ $PROMPT_GIT_REMOTE_COUNTERS -eq 1 ]]; then
        remoteStatus=${remoteStatusA[*]} # Join with spaces
    else
        remoteStatus=$(IFS=; echo "${remoteStatusA[*]}") # Join without spaces
    fi

    [[ -n $remoteStatus ]] && remoteStatus=" $remoteStatus" # Add leading space

    pt_gitBranchInfo="${pt_gitBranchInfo}${remoteStatus}${pt_purple}) "
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

# Set the $pt_gitAction variable
__prompt_git_set_action() {
    # External affected vars
    pt_gitAction=

    local gitAction="" rebaseStep="" rebaseTotal="" rebaseHeadName="" rebaseOnto="" rebaseOntoBranch=""

    __prompt_git_extract_action_info

    case "${gitAction}" in
        rebase)
            local rebaseTarget rebaseProgress doneColor

            doneColor=${pt_yellow}
            [[ $conflicts -gt 0 ]] && doneColor=${pt_red}

            rebaseProgress="${pt_white}(${doneColor}${rebaseStep}${pt_white}/${rebaseTotal})"
            rebaseTarget="${pt_blackBold}[${pt_yellow}${rebaseHeadName}${pt_blackBold} ${_g_ico_onto} ${pt_cyan}${rebaseOntoBranch}${pt_blackBold}]"

            pt_gitAction="\n${pt_redBold}${_g_ico_rebase} ${rebaseTarget} ${rebaseProgress} "
            ;;
        merge)       pt_gitAction="${pt_red}${_g_ico_merge} " ;;
        cherry-pick) pt_gitAction="${pt_red}${_g_ico_cherry} " ;;
        revert)      pt_gitAction="${pt_red}${_g_ico_revert} " ;;
        bisect)      pt_gitAction="${pt_yellow}${_g_ico_bisect} " ;;
        *)           pt_gitAction="" ;;
    esac
}

# Set the $pt_gitState variable
__prompt_git_set_state() {
    # External affected vars
    pt_gitState=

    local promptGitStateA=()

    if [[ $untracked -eq 0 && $changed -eq 0 && $deleted -eq 0 && $staged -eq 0 && $conflicts -eq 0 ]]; then
        pt_gitState="${promptUserColor:-${pt_color}}${_g_ico_clean}"
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
            [[ $changed   -gt 0 ]] && promptGitStateA+=("${pt_yellow}${_g_ico_chng}${ch}")
            [[ $deleted   -gt 0 ]] && promptGitStateA+=("${pt_red}${_g_ico_minus}${dl}")
            [[ $untracked -gt 0 ]] && promptGitStateA+=("${pt_green}${_g_ico_plus}${ut}")
            [[ $staged    -gt 0 ]] && promptGitStateA+=("${pt_green}${_g_ico_chng}${st}")
            [[ $conflicts -gt 0 ]] && promptGitStateA+=("${pt_red}${_g_ico_lr}${cf}")
            ;;
        summary)
            if [[ $changed -gt 0 || $deleted -gt 0 ]]; then # Misc. changes
                promptGitStateA+=("${pt_yellow}${_g_ico_chng}${md}")
            elif [[ $untracked -gt 0 ]] && [[ $changed -eq 0 || $deleted -eq 0 ]]; then # Only untracked
                [[ -z $ut ]] && ut=" "
                promptGitStateA+=("${pt_green}${_g_ico_plus}${ut}")
            fi
            [[ $staged    -gt 0 ]] && promptGitStateA+=("${pt_green}${_g_ico_chng}${st}")
            [[ $conflicts -gt 0 ]] && promptGitStateA+=("${pt_red}${_g_ico_lr}${cf}")
            ;;
    esac

    if [[ $PROMPT_GIT_STATE_COUNTERS -eq 1 ]]; then
        pt_gitState=${promptGitStateA[*]} # Join with spaces
    else
        pt_gitState=$(IFS=; echo "${promptGitStateA[*]}") # Join without spaces
    fi

    [[ -n $pt_gitState ]] && pt_gitState="${pt_gitState% } "
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
