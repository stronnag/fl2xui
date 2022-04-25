#!/bin/sh

ICON_CACHE=${MESON_INSTALL_PREFIX}/share/icons/hicolor

if [ -z "$DESTDIR" ]; then
 echo "Updating gtk icon cache ..."
 if [ "$(uname)" == "Darwin" ] ; then
   gtk3-update-icon-cache -qtf $ICON_CACHE
 else
   gtk-update-icon-cache -qtf $ICON_CACHE
 fi
fi
