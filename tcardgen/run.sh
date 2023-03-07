#!/bin/bash -e

PROGNAME=$(basename $0)

usage() {
    echo "Usage: $PROGNAME content/article.md"
    exit 1
}
shell_session_update() { :; }

for OPT in "$@"
do
    case "$OPT" in
        *)
            TARGET=$OPT
            shift 1
            ;;
    esac
done

if [ ! "$TARGET" ]; then
    echo "No Set TARGET"
    usage
    exit 1
fi

tcardgen -f tcardgen/fonts/KintoSans/ \
-o static/image/og \
-t tcardgen/ogp_image_yamacraft.png \
-c tcardgen/tcardgen.yml \
$TARGET

echo "done."