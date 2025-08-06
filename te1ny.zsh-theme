##############
### COLORS ###
##############

zsh_text_clr="#99DEC6"

### LEFT

user_bg_clr="#1D423F"
user_text_clr="#B1F0DA"
user_icon_clr="#B1F0DA"

dir_bg_clr="#345E54"
dir_text_clr="#97CCB9"
dir_icon_clr="#97CCB9"

prompt_symbol_bg_clr="#49786D"
prompt_symbol_text_clr="#b0e8d4"

### RIGHT

git_branch_bg_clr="#212830"
git_branch_text_clr="#F0F6FC"
git_branch_icon_clr="#9198A1"

git_diff_bg_clr="#303A46"
git_diff_added_text_clr="#7CEB96"
git_diff_deleted_text_clr="#EB675E"
git_diff_added_icon_clr="#7CEB96"
git_diff_deleted_icon_clr="#EB675E"

git_status_unstaged_bg_clr="#EB675E"
git_status_commited_bg_clr="#EDDF80"
git_status_up_to_date_bg_clr="#7CEB96"

#################
### VARIABLES ###
#################

### LEFT

user_text="%n"
user_icon=""

dir_text="%~"
dir_icon=""

#prompt_symbol_icon not used
prompt_symbol_text="$"

### RIGHT

#git_branch_text in capsule func
git_branch_icon=""

#git_diff_added_text in capsule
#git_diff_deleted_text in capsule func
git_diff_added_icon=""
git_diff_deleted_icon=""

###################
### ZSH OPTIONS ###
###################

ZLE_RPROMPT_INDENT=0 
setopt PROMPT_SUBST

########################
### PROMPT FUNCTIONS ###
########################

### FORMATTER FUNC

format_icon() {
    local icon=$1
    local color=$2
    echo "%F{${color}}${icon} %f" # gap required for correct display glyph icon. its dont real gap, he only expand icon to right.
}

format_text() {
    local text=$1
    local color=$2
    echo "%F{${color}}${text}%f"
}

get_left_capsule() {
    local content=$1
    local bg_color=$2
    local next_bg_color=$3

    local result="%K{${bg_color}}${content}"

    if [[ -n "$next_bg_color" ]]; then
        result+="%K{${next_bg_color}}%F{${bg_color}}%k%f"
    else
        result+="%k%F{${bg_color}}%f"
    fi

    echo "$result"
}

# NEED TEST
get_right_capsule() {
    local content=$1
    local bg_color=$2
    local previous_bg_color=$3

    local result=""

    if [[ -n "$previous_bg_color" ]]; then
        result+="%K{${previous_bg_color}}%F{${bg_color}}%k%f%K{${bg_color}}${content}%k"
    else
        result+="%F{${bg_color}}%f%K{${bg_color}}${content}%k"
    fi

    echo "$result"
}

### CAPSULES (A place for your capsules)

### LEFT

user_capsule() {
    local icon=$(format_icon $user_icon $user_icon_clr)
    local text=$(format_text $user_text $user_text_clr)

    echo $(get_left_capsule " ${icon} ${text} " $user_bg_clr $dir_bg_clr)
}

dir_capsule() {
    local icon=$(format_icon $dir_icon $dir_icon_clr)
    local text=$(format_text $dir_text $dir_text_clr)

    echo $(get_left_capsule " ${icon} ${text} " $dir_bg_clr $prompt_symbol_bg_clr)
}

prompt_symbol_capsule() {
    local text=$(format_text $prompt_symbol_text $prompt_symbol_text_clr)

    echo $(get_left_capsule " ${text} " $prompt_symbol_bg_clr "")
}

### RIGHT

git_branch_capsule() {
    local raw_branch_text=$(git branch --show-current)

    local icon=$(format_icon $git_branch_icon $git_branch_icon_clr)
    local text=$(format_text $raw_branch_text $git_branch_text_clr)
    
    echo $(get_right_capsule " ${icon}${text} " $git_branch_bg_clr "")
}

git_diff_capsule() {
    local raw_added_text
    local raw_deleted_text
    local raw_diff=$(git diff --numstat 2>/dev/null)

    if [[ -n "$raw_diff" ]]; then
        local raw_added_text=$(echo "$raw_diff" | awk '{print $1}' | tr -d ',')
        local raw_deleted_text=$(echo "$raw_diff" | awk '{print $2}' | tr -d ',')
    else
        echo ""
        return
    fi

    local result=""

    if [[ "$raw_added_text" != "0" && "$raw_deleted_text" != "0" ]]; then
        local added_text=$(format_text $raw_added_text $git_diff_added_text_clr)
        local added_icon=$(format_icon $git_diff_added_icon $git_diff_added_icon_clr)
        local deleted_text=$(format_text $raw_deleted_text $git_diff_deleted_text_clr)
        local deleted_icon=$(format_icon $git_diff_deleted_icon $git_diff_deleted_icon_clr)
        result+=" ${added_icon}${added_text} "
        result+=""
        result+=" ${deleted_icon}${deleted_text} "
    elif [[ "$raw_added_text" != "0" && "$raw_deleted_text" == "0" ]]; then
        local added_text=$(format_text $raw_added_text $git_diff_added_text_clr)
        local added_icon=$(format_icon $git_diff_added_icon $git_diff_added_icon_clr)
        result=" ${added_icon}${added_text} "
    elif [[ "$raw_added_text" == "0" && "$raw_deleted_text" != "0" ]]; then
        local deleted_text=$(format_text $raw_deleted_text $git_diff_deleted_text_clr)
        local deleted_icon=$(format_icon $git_diff_deleted_icon $git_diff_deleted_icon_clr)
        result=" ${deleted_icon}${deleted_text} "
    fi

    echo $(get_right_capsule "$result" $git_diff_bg_clr $git_branch_bg_clr)
}

git_status_capsule() {
    local dirty=$(git status --porcelain 2>/dev/null)
    if [[ -n "$dirty" ]]; then
        echo $(get_right_capsule " " $git_status_unstaged_bg_clr $git_diff_bg_clr)
        return 0
    fi

    local ahead=$(git rev-list --count origin/master..master 2>/dev/null)
    if [[ $ahead -gt 0 ]]; then
        echo $(get_right_capsule " " $git_status_commited_bg_clr $git_diff_bg_clr)
        return
    fi

    echo $(get_right_capsule " " $git_status_up_to_date_bg_clr $git_diff_bg_clr)
}

##############
### PROMPT ###
##############

# If the capsule prompt does not change (it does not call functions inside itself), 
# then it is better to create a global variable in order 
# to avoid unnecessary calls to capsule functions.

user_global=$(user_capsule)
dir_global=$(dir_capsule)
prompt_symbol_global=$(prompt_symbol_capsule)

prompt() {
    local result=$'\n' # move prompt on next line

    result+=$user_global
    result+=$dir_global
    result+=$prompt_symbol_global

    result+=" "
    
    echo "$result"
}

PROMPT='$(prompt)'

################
### RPROMPT  ###
################

rprompt() {
    local result=""
    local is_git_repo=$(git rev-parse --is-inside-work-tree > /dev/null 2>&1)

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        result+=$(git_branch_capsule)
        result+=$(git_diff_capsule)
        result+=$(git_status_capsule)
    fi

    echo "$result"
}

RPROMPT='$(rprompt)'
