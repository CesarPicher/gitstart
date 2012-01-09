#!/bin/bash

DIR="$HOME/.ssh"

def=
[ -d .git -a -f .git/config ] && def="`/bin/pwd`"
def="`basename "$def"`"
GITHUBREPO="${1:-$def}"

read def < "$DIR/.github-default"
GITHUBACCOUNT="${2:-$def}"
if [ -z "$GITHUBACCOUNT" -o -z "$GITHUBREPO" ]
then
	cat >&2 <<EOF
Usage: `basename "$0"` ['${GITHUBREPO:-GITHUBREPO}' ['${GITHUBACCOUNT:-GITHUBACCOUNT}']]"
	Creates an SSH key named ${GITHUBACCOUNT:-GITHUBACCOUNT}-${GITHUBREPO:-GITHUBREPO}
	for use as an GITHUB Deployment Key.  When called the first time, you must give
	the 2nd parameter (GITHUBACCOUNT from https://github.com/GITHUBACCOUNT).
	When called from a GIT directory, the first parameter defaults to the directory name.
EOF
	exit 1
fi

echo "$GITHUBACCOUNT" > "$DIR/.github-default"

GITNAME="$GITHUBACCOUNT-$GITHUBREPO"

[ ! -f "$DIR/$GITNAME" ] &&

ssh-keygen -qt rsa -C "$GITNAME" -f "$DIR/$GITNAME" -N '' </dev/null &&

cat <<EOF >> "$DIR/config"

Host git-$GITNAME
 Hostname github.com
 User git
 IdentityFile $DIR/$GITNAME

EOF

cat <<EOF

Paste this to GitHub:

EOF

cat "$DIR/$GITNAME.pub"

cat <<EOF

To make your local master branch tracking the remote master branch
(this assumes you have committed everything):

git remote rename origin oldorigin
git remote add origin git-$GITNAME:$GITHUBACCOUNT/$GITHUBREPO.git
git push origin master
git checkout origin/master; git branch -f master origin/master; git checkout master

To display this information again, just run $0 again.

EOF