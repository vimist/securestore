#! /bin/bash

INSTALL_DIR="/usr/local/bin"


case "$1" in
	pass)
		install "pass" "$INSTALL_DIR"
		install "vcstore" "$INSTALL_DIR"
		install "securestore" "$INSTALL_DIR"
		;;
	vcstore)
		install "vcstore" "$INSTALL_DIR"
		install "securestore" "$INSTALL_DIR"
		;;
	securestore)
		install "securestore" "$INSTALL_DIR"
		;;
	remove)
		rm "$INSTALL_DIR/pass" \
			"$INSTALL_DIR/vcstore" \
			"$INSTALL_DIR/securestore"
		;;
	*)
		echo "Usage: $0 pass|vcstore|securestore|remove" >&2
		;;
esac
