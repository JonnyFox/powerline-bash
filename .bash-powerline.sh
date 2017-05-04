#!/usr/bin/env bash

__powerline() {

    # Unicode symbols
    readonly PS_SYMBOL_DARWIN=''
    readonly PS_SYMBOL_LINUX='$'
    readonly PS_SYMBOL_OTHER='$'
    readonly GIT_BRANCH_SYMBOL='⌥ '
    readonly GIT_BRANCH_CHANGED_SYMBOL='+'
    readonly GIT_PUSH_SYMBOL='⇧'
    readonly GIT_PULL_SYMBOL='⇩'

    readonly WARN_FG="\[$(tput setaf 3)\]"
    readonly ALERT_FG="\[$(tput setaf 4)\]"
    readonly INFO_FG="\[$(tput setaf 6)\]"
    readonly SUCCESS_FG="\[$(tput setaf 2)\]"
    readonly COMMON_INV_FG="\[$(tput setaf 0)\]"
    readonly COMMON_FG="\[$(tput setaf 7)\]"

    readonly WARN_BG="\[$(tput setab 3)\]"
    readonly ALERT_BG="\[$(tput setab 4)\]"
    readonly INFO_BG="\[$(tput setab 6)\]"
    readonly SUCCESS_BG="\[$(tput setab 2)\]"
    readonly COMMON_BG="\[$(tput setab 0)\]"

    readonly DIM="\[$(tput dim)\]"
    readonly REVERSE="\[$(tput rev)\]"
    readonly RESET="\[$(tput sgr0)\]"
    readonly BOLD="\[$(tput bold)\]"

    if [[ -z "$PS_SYMBOL" ]]; then
      case "$(uname)" in
          Darwin)
              PS_SYMBOL=$PS_SYMBOL_DARWIN
              ;;
          Linux)
              PS_SYMBOL=$PS_SYMBOL_LINUX
              ;;
          *)
              PS_SYMBOL=$PS_SYMBOL_OTHER
      esac
    fi

    gitStatus() { 

        eval "$1=''"
        eval "$2=''"

        [ -x "$(which git)" ] || return

        local gitCommand="env LANG=C git"  
        local branch="$($gitCommand symbolic-ref --short HEAD 2>/dev/null || $gitCommand describe --tags --always 2>/dev/null)"
        [ -n "$branch" ] || return

        local marks

        local isChanged="$($gitCommand status --porcelain)"

        [ -n "$isChanged" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL$(echo "$isChanged" | wc -l)"

        # local modified="$(echo "$isChanged" | grep 'M' | wc -l)";
        # local added="$(echo "$isChanged" | grep 'A' | wc -l)";
        # local deleted="$(echo "$isChanged" | grep 'D' | wc -l)";
        # local renamed="$(echo "$isChanged" | grep 'R' | wc -l)";
        # local copied="$(echo "$isChanged" | grep 'C' | wc -l)";
        # local unmerged="$(echo "$isChanged" | grep 'U' | wc -l)";
        # local untracked="$(echo "$isChanged" | grep '?' | wc -l)";
        # local ignored="$(echo "$isChanged" | grep '!' | wc -l)";

        # [ $modified -ne 0 ] && marks+="$modified"M
        # [ $added -ne 0 ] && marks+="$added"A
        # [ $deleted -ne 0 ] && marks+="$deleted"D
        # [ $renamed -ne 0 ] && marks+="$renamed"R
        # [ $copied -ne 0 ] && marks+="$copied"C
        # [ $unmerged -ne 0 ] && marks+="$unmerged"U
        # [ $untracked -ne 0 ] && marks+="$untracked"?
        # [ $ignored -ne 0 ] && marks+="$ignored"!

        local stat="$($gitCommand status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
        local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
		
        [ -n "$aheadN" ] && marks+=" $GIT_PUSH_SYMBOL$aheadN"
        [ -n "$behindN" ] && marks+=" $GIT_PULL_SYMBOL$behindN"

        eval "$2='$marks'"
        eval "$1=' $GIT_BRANCH_SYMBOL$branch$marks '"
        return 
    }

    ps1() {
        
        local isError=$?

        if [ $isError -eq 0 ]; then
            local consoleBackColor="$COMMON_BG"
            local consoleColor="$COMMON_INV_FG"
        else
            local consoleBackColor="$ALERT_BG"
            local consoleColor="$ALERT_FG"
        fi
		
        PS1="$INFO_BG$COMMON_FG \w $RESET"

        gitStatus gitInfo gitMarks

        if [ ${#gitMarks} != 0 ]; then
                local branchBackColor="$WARN_BG"
                local branchColor="$WARN_FG"
            else
                local branchBackColor="$SUCCESS_BG"
                local branchColor="$SUCCESS_FG"
        fi

        if shopt -q promptvars; then
			if [ ${#gitInfo} != 0 ]; then
					PS1+="$branchBackColor$INFO_FG$branchBackColor$COMMON_INV_FG${gitInfo}$consoleBackColor$branchColor$RESET"
				else
					PS1+="$consoleBackColor$INFO_FG$RESET"
			fi
        else
            PS1+="$ALERT_BG$COMMON_FG$(gitInfo)$RESET"
        fi
        PS1+="$consoleBackColor$COMMON_FG $PS_SYMBOL $COMMON_BG$consoleColor$RESET"

        if [ $isError -ne 0 ]; then
            PS1+=" "
        fi
    }

    PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
