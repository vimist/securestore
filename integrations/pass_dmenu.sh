#! /bin/bash

set -e


REGEX="$1"

readarray -t FILTERED_ENTRIES < <(
	pass find . -not -path '*/\.*' -type f | \
		grep -Pi "$REGEX" | \
		sed -e 's/^.\///' -e 's/\// \/ /g' | \
		sort
)

(( ${#FILTERED_ENTRIES[@]} == 0 )) && exec "$0"


SELECTED_ENTRY="$((
	printf '%s\n' "${FILTERED_ENTRIES[@]}"
	echo 'More...'
) | dmenu -i -p 'Pass:')"

[[ "$SELECTED_ENTRY" == "More..." ]] && exec "$0"


PRETTY_ENTRY="$SELECTED_ENTRY"
SELECTED_ENTRY="${SELECTED_ENTRY// \/ /\/}"

ACTION_PROPERTY="$((
	while read FUNCTION; do
		echo "Run $FUNCTION"
	done < <(pass list-functions "$SELECTED_ENTRY")

	while read PROPERTY; do
		echo "Type $PROPERTY"
	done < <(pass list-properties "$SELECTED_ENTRY")

	echo "View $PRETTY_ENTRY"
	echo "Edit $PRETTY_ENTRY"
) | dmenu -i -p "$PRETTY_ENTRY")"


ACTION="${ACTION_PROPERTY%% *}"
ACTION="${ACTION,,}"
PROPERTY="${ACTION_PROPERTY#* }"

if [ "$ACTION" == 'view' ]; then
	alacritty --hold --command pass get "$SELECTED_ENTRY"
elif [ "$ACTION" == 'edit' ]; then
	alacritty --command pass edit "$SELECTED_ENTRY"
elif [ "$ACTION" == 'run' ]; then
	pass run-function "$SELECTED_ENTRY" "$PROPERTY"
else
	pass "$ACTION-property" "$SELECTED_ENTRY" "$PROPERTY"
fi
