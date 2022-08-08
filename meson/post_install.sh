#!/bin/sh

if type update-mime-database 2>&1 >/dev/null ; then
  echo >&2 Updating mime database ...
  update-mime-database $MESON_INSTALL_PREFIX/share/mime
fi
