#! /bin/bash


if [ -n "$1" ]; then
	ENTRY="$1"
else
	# Prompt to select an entry if it wasn't given as an argument
	ENTRY="$(
		pass find . -type f | \
			grep -Pv '/\.' | \
			sed -e 's/^.\///' -e 's/\// \/ /g' | \
			sort | \
			dmenu -i -p 'Pass:'
	)"

	[ $? -eq 0 ] || exit 1

	ENTRY="${ENTRY// \/ /\/}"
fi

PRETTY_ENTRY="${ENTRY//\// \/ }"

# Prompt to select an action from an entry
ACTION_PROPERTY="$((
	echo "View $PRETTY_ENTRY"
	echo "Edit $PRETTY_ENTRY"

	while read FUNCTION; do
		echo "Run $FUNCTION"
	done < <(pass list-functions "$ENTRY")

	while read PROPERTY; do
		echo "Type $PROPERTY"
	done < <(pass list-properties "$ENTRY")

) | dmenu -i -p "$PRETTY_ENTRY")"


ACTION="${ACTION_PROPERTY%% *}"
ACTION="${ACTION,,}"
PROPERTY="${ACTION_PROPERTY#* }"

# Perform the specified action
if [ "$ACTION" == 'view' ]; then
	konsole --hold -e pass get "$ENTRY"
elif [ "$ACTION" == 'edit' ]; then
	konsole -e pass edit "$ENTRY"
elif [ "$ACTION" == 'run' ]; then
	pass run-function "$ENTRY" "$PROPERTY"
else
	pass "$ACTION-property" "$ENTRY" "$PROPERTY"
fi
