#! /bin/bash

TITLE="$(xdotool getwindowname $(xdotool getactivewindow))"

BROWSER_SUFFIX='Mozilla Firefox'


autotype() {
	pass run-function "$1" AutoType
}

case "$TITLE" in
	Sign\ in\ ?\ GitLab*$BROWSER_SUFFIX) autotype 'Development/GitLab' ;;
	Login\ -\ Chess.com*$BROWSER_SUFFIX) autotype 'Gaming/Chess.com' ;;
	Steam\ Login) autotype 'Gaming/Steam' ;;
	Sign\ in\ to\ your\ Microsoft\ account*$BROWSER_SUFFIX) autotype 'General/Microsoft' ;;
	Stripe:\ Sign\ in*$BROWSER_SUFFIX) autotype 'Finance/Stripe' ;;
esac
