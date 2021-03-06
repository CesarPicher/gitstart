#!/bin/bash

export LC_ALL=C

RC="$HOME/.bashrc"
TMP="$RC.git.tmp"

add()
{
grep -F -qx "$1" "$TMP" || echo "$1" >> "$TMP"
}

# Inserts the `$(__git_ps1 "(%s)")` right before the `$` on the PS1 prompt
sed -e '/__git_ps1/b' -e 's|\(^[[:space:]]*PS1='\''.*\)\(\\\$ '\''[[:space:]]*\)$|\1\$(__git_ps1 "(%s)")\2|' "$RC" > "$TMP"

grep -qw PS1 "$TMP" ||
cat <<'EOF' >> "$TMP"
[ -z "$PS1" ] || { __i=; for __a in /etc/bash_completion.d/git /usr/share/doc/git-*/contrib/completion/git-completion.bash; do [ -r "$__a" ] && __i="$__a"; done; [ -n "$__i" ] && . "$__i" && PS1="`echo "$PS1" | sed -e '/__git_ps1/b' -e 's|\(\(\\\\n\)\?\\\\\\\$[[:space:]]*\)$|\$(__git_ps1 "(%s)")\1|'`"; unset __a __i; }
EOF

# Append some proper settings for __git_ps1
add "export GIT_PS1_SHOWDIRTYSTATE=yes"
add "export GIT_PS1_SHOWUNTRACKEDFILES=yes"
add "export GIT_PS1_SHOWUPSTREAM=verbose"

# Install the changes
cmp -s "$RC" "$TMP" || cp -v --backup=t "$TMP" "$RC"
rm -f "$TMP"

[ -f /etc/profile.d/bash_completion.sh ] ||
echo "You probably need: sudo apt-get install bash-completion" >&2
