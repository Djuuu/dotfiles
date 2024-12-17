#!/usr/bin/env bash

prompt_git() {
  promptGit=

  promptGitBranch=$(_git_prompt_branch) >/dev/null 2>&1 ||
    return # exit if not in a Git repository

  #promptGitBranchInfo="${purpleTxt}( ${promptGitBranch})" # \ue0a0 nf-pl-branch (nerd font)
  promptGitBranchInfo="${purpleTxt}( ${promptGitBranch})" # \ue725 nf-dev-git_branch (nerd font)

  local git_status; git_status=$(_git_prompt_get_status)
  promptGitRemote=$(_git_prompt_remote "$git_status")
  promptGitState=$(_git_prompt_state "$git_status")

  promptGit="${promptGitBranchInfo}${promptGitRemote}${promptGitState}${resetColor} "
}

_git_prompt_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

_git_prompt_get_status() {
  LANG=C git -c status.submoduleSummary=false status 2>/dev/null
}

_git_prompt_remote() {
  local git_status=${1}

  local remote_pattern="Your branch is (.*) '"
  local diverge_pattern="Your branch and (.*) have diverged"

  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead of" ]]; then
      #echo " ${greenBold}↑"
      echo " ${greenBold}" # \uf062 nf-fa-arrow_up (nerd font)
      return
    fi
    if [[ ${BASH_REMATCH[1]} == "behind" ]]; then
      #echo " ${yellowBold}↓"
      echo " ${yellowBold}" # \uf063 nf-fa-arrow_down (nerd font)
      return
    fi

    #echo " ${greenBold}⇋"
    #echo " ${greenBold}" # \uf0ec nf-fa-arrow_right_arrow_left (nerd font)
    #echo " ${greenBold}" # \uf07e nf-fa-arrows_left_right (nerd font)
    #echo " ${greenBold}" # \uf416 nf-oct-arrow_both (nerd font)
    return
  fi

  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    #echo " ${yellowBold}⇅"
    #echo " ${yellowBold}󰹹" # \udb83\ude79 nf-md-arrow_up_down (nerd font)
    echo " ${yellowBold}" # \uf07d nf-fa-arrows_up_down (nerd font)
  fi
}

_git_prompt_get_commit_branch() {
  local commit=${1}

  git log --decorate --simplify-by-decoration --oneline \
    --decorate-refs='refs/heads/*' \
    --decorate-refs='refs/remotes/*' "$commit" | # select only commits with a branch
    head -n1 | grep "$commit"                  | # keep only current commit, if it actually has a branch
    sed 's/[a-f0-9]\+ (\([^)]*\)) .*/\1/'      | # filter out everything but decorations
    sed -e 's/, /\n/g'                         | # splits decorations
    tail -n1                                     # keep only last decoration
}

_git_prompt_state() {
  local git_status=${1}

  # Clean
  if [[ ${git_status} =~ "working tree clean" ]]; then
    #echo " ${greenTxt}✔"
    #echo " ${greenTxt}" # \uf42e nf-oct-check (nerd font)
    #echo " ${greenTxt}" # \uf00c nf-fa-check (nerd font)
    #echo " ${greenTxt}" # \uf522 nf-oct-sun (nerd font)
    #echo " ${greenTxt}" # \uec10 nf-cod-sparkle (nerd font)
    echo " ${userColor}" # \uec10 nf-cod-sparkle (nerd font)
    return
  fi

  # Merge
  if [[ ${git_status} =~ "You have unmerged paths" ]]; then
    #echo " ${redTxt}M"
    echo " ${redTxt}" # \uf419 nf-oct-git_merge (nerd font)
    return
  fi

  # Cherry-pick
  if [[ ${git_status} =~ "You are currently cherry-picking" ]]; then
    echo " ${redTxt}🍒"
    return
  fi

  # Rebasing
  if [[ ${git_status} =~ "rebase in progress" ]]; then

    local branch
    local targetc
    local current_branch_rebase_pattern="You are currently( editing a commit while)? rebasing branch '([^']*)' on '([^']*)'"
    [[ ${git_status} =~ ${current_branch_rebase_pattern} ]] &&
      branch="${BASH_REMATCH[2]}" &&
      targetc="${BASH_REMATCH[3]}"

    local targetb; targetb=$(_git_prompt_get_commit_branch $targetc)
    local target; [[ -n "$targetb" ]] && target=$targetb || target=$targetc

    local doneCommandPattern="Last commands? done \(([0-9]*) commands? done\)"
    local remainingCommandPattern="Next commands to do \(([0-9]*) remaining commands\)"
    local donec; [[ ${git_status} =~ ${doneCommandPattern} ]] && donec=${BASH_REMATCH[1]}
    local todoc; [[ ${git_status} =~ ${remainingCommandPattern} ]] && todoc=${BASH_REMATCH[1]}
    local totalc=$((donec + todoc))

    local doneColor=${yellowTxt}
    local conflictPattern='fix conflicts and then run "git rebase --continue"'
    [[ ${git_status} =~ ${conflictPattern} ]] && doneColor=${redTxt}

    local rebaseProgress="${whiteTxt}(${doneColor}${donec}${whiteTxt}/${totalc})"
    local rebaseTarget="${blackBold}[${yellowTxt}${branch}${blackBold} ↷ ${cyanTxt}${target}${blackBold}]"

    echo "\n${rebaseTarget}\n${redBold}☈  ${rebaseProgress}"
    return
  fi

  # Changes
  if [[ ${git_status} =~ "Changes " ]]; then
    #echo " ${redTxt}✘"
    echo " ${redTxt}" # \uf467 nf-oct-x (nerd font)
    return
  fi

  # Untracked files
  #echo " ${yellowTxt}✔"
  #echo " ${yellowTxt}+"
  echo " ${yellowTxt}" # \uf44d nf-oct-plus (nerd font)
}
