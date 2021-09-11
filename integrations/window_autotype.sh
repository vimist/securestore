#! /bin/sh

TITLE="$(xdotool getwindowname $(xdotool getactivewindow))"

BROWSER_SUFFIX=' — Mozilla Firefox'

# Build a filter based on the window title
readarray -t TERMS < <(
	echo "${TITLE%$BROWSER_SUFFIX}" | grep -Po '\w{4,}' | sort --unique
)
TERMS="$(IFS='|'; echo "${TERMS[*]}")"


autotype() {
	sleep 0.5
	pass run-function "$1" AutoType
}

case "$TITLE" in
	Sign\ in\ to\ GitHub*$BROWSER_SUFFIX) autotype 'Development/GitHub' ;;
	Sign\ in\ ?\ GitLab*$BROWSER_SUFFIX) autotype 'Development/GitLab' ;;

	Steam\ Login) autotype 'Gaming/Steam' ;;

	Sign\ in\ to\ your\ Microsoft\ account*$BROWSER_SUFFIX) autotype 'General/Microsoft' ;;
	Stripe:\ Sign\ in*$BROWSER_SUFFIX) autotype 'Finance/Stripe' ;;

	*) "/full/path/to/pass_dmenu.sh" "$TERMS" ;;
esac
