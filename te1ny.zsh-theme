# Colors
user_bg="#1D423F"
user_text="#b1f0da"
user_icon="#b1f0da"

dir_bg="#345e54"
dir_text="#97ccb9"
dir_icon="#97ccb9"

git_bg="#212830"
git_text="#F0F6FC"
git_icon="#9198A1"
git_added="#7CEB96"
git_deleted="#EB675E"
git_diff_bg="#303A46"

cmd_text="#99dec6"

# This deleting space after RPROMPT
ZLE_RPROMPT_INDENT=0 

# Huy znaet nahuya, no nado (Maybe for using functions in raw strings aka '')
setopt PROMPT_SUBST

PROMPT=$'\n'
RPROMPT=""

# %F start fill foreground
# $f stop fill foreground
# %K start fill background
# %k stop fill background

# USER
PROMPT+="%K{${user_bg}}%F{${user_icon}}  %F{${user_text}} %n %F{${user_bg}}%K{${dir_bg}}"

# DIR
PROMPT+="%F{${dir_bg}}%F{${dir_icon}}   %F{${dir_text}}%~ %k%F{${dir_bg}}%f"

# '$' aaaah dollar...
PROMPT+=" $ "

PROMPT+="%F{${cmd_text}}"

# GIT : PREFIX | DIRTY/CLEAN | SUFFIX
RPROMPT+='$(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{${git_bg}}%F{${git_icon}}%K{${git_bg}}  %F{${git_text}}"

# precmd() is a hook called when need reprint PROMPT
function precmd() {
	local in_git_repo=$(git_repo_name)
	[[ -z $in_git_repo ]] && return

	local git_added_count=$(git diff --numstat 2>/dev/null | awk '{added+=$1} END{print added}') 
	local git_deleted_count=$(git diff --numstat 2>/dev/null | awk '{deleted+=$2} END{print deleted}')

	if [[ -n "$git_added_count" && -n "$git_deleted_count" ]]; then
		ZSH_THEME_GIT_PROMPT_DIRTY=" %F{${git_diff_bg}}%K{${git_diff_bg}}%F{${git_added}}  ${git_added_count} %F{${git_deleted}} ${git_deleted_count}"
		ZSH_THEME_GIT_PROMPT_SUFFIX=" %F{${git_deleted}}%K{${git_deleted}} "
	else
		ZSH_THEME_GIT_PROMPT_DIRTY=""
		if [[ -z "$git_status" ]]; then
			ZSH_THEME_GIT_PROMPT_SUFFIX=" %F{${git_added}}%K{${git_added}} "
		else
			ZSH_THEME_GIT_PROMPT_SUFFIX=" %F{${git_deleted}}%K{${git_deleted}} "
		fi
	fi
}
