#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--rm_host)
      REMARKABLE_HOST="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [ -z "$REMARKABLE_HOST" ]; then
	echo "remarkable host not set"
	exit 1
fi

REMARKABLE_XOCHITL_DIR=${REMARKABLE_XOCHITL_DIR:-.local/share/remarkable/xochitl/}
TARGET_DIR="${REMARKABLE_HOST}:${REMARKABLE_XOCHITL_DIR}"

# --ignore-existing: skip files that are already present on the remarkable i.e.
# 						do not update those files
# --copy-links: replace links by the referenced file
exec rsync --ignore-existing --copy-links -av -e ssh \
	rm_files/ "$TARGET_DIR"
