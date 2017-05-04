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
    readonly GIT_SEPARATOR=''

    readonly WARN_FG="\[\033[1;33m\]"
    readonly ALERT_FG="\[\033[0;31m\]"
    readonly INFO_FG="\[\033[0;34m\]"
    readonly SUCCESS_FG="\[\033[0;32m\]"
    readonly COMMON_INV_FG="\[\033[0;30m\]"
    readonly COMMON_FG="\[\033[1;37m\]"
    readonly COMMON_LIGHT_FG="\[\033[0;36m\]"

    readonly WARN_BG="\[\033[46m\]"
    readonly ALERT_BG="\[\033[41m\]"
    readonly INFO_BG="\[\033[44m\]"
    readonly SUCCESS_BG="\[\033[46m\]"
    readonly COMMON_BG="\[\033[40m\]"

    readonly DIM="\[$(tput dim)\]"
    readonly REVERSE="\[$(tput rev)\]"
    readonly RESET="\[\033[0m\]"
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
					PS1+="$INFO_FG$branchBackColor$GIT_SEPARATOR$branchColor$branchBackColor${gitInfo}$COMMON_LIGHT_FG$consoleBackColor$GIT_SEPARATOR$RESET"
				else
					PS1+="$INFO_FG$consoleBackColor$GIT_SEPARATOR$RESET"
			fi
        else
            PS1+="$COMMON_FG$ALERT_BG$(gitInfo)$RESET"
        fi
        PS1+="$consoleBackColor$COMMON_FG $PS_SYMBOL $COMMON_BG$consoleColor$GIT_SEPARATOR$RESET"

        if [ $isError -ne 0 ]; then
            PS1+=" "
        fi
    }
    PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
