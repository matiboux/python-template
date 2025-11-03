#!/bin/sh
set -e

if (
	# If the first argument is a flag,
	[ "${1#-}" != "$1" ] ||
	# Or,
	(
		# Unless the first argument is one of these commands,
		[ "$1" != 'uv' ] &&
		[ "$1" != 'pip' ] &&
		[ "$1" != 'litestar' ] &&
		# And, unless the first argument is one of these shells,
		[ "$1" != 'sh' ] &&
		[ "$1" != 'bash' ]
	)
	# Assume that the user wants to run uv
); then
	set -- uv "$@"
fi

exec "$@"
