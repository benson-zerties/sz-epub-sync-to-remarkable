#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    -e|--rm_dir)
      RM_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--pdf_dir)
      PDF_DIR="$2"
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

if [ -z "$RM_DIR" ]; then
	echo "remarkable directory rm_dir not set"
	exit 1
fi
if [ -z "$PDF_DIR" ]; then
	echo "pdf_dir not set"
	exit 1
fi

# find all epubs younger than 1 weeks
mapfile -d '' RM_UNBROKEN_LINKS < <(find "$RM_DIR"*.pdf -type l -not -xtype l -print0)
mapfile -d '' RM_BROKEN_LINKS < <(find "$RM_DIR"*.pdf -xtype l -print0)
mapfile -d '' PDF_ARRAY < <(find "$PDF_DIR" -type f -print0)

# Cleanup rm_files, remove broken links
for ITEM in "${RM_BROKEN_LINKS[@]}"
do
	UUID_ITEM="${ITEM%.pdf}"

	echo "broken link ""$UUID_ITEM"
	# remove all files related to this uuid
	rm -rf "$UUID_ITEM"*
done

# Search for pdfs that are missing in rm_files
for ITEM in "${PDF_ARRAY[@]}"
do
	found=0
	for RM_ITEM in "${RM_UNBROKEN_LINKS[@]}"
	do
		SRC_ITEM=$(basename $(readlink -f "$RM_ITEM"))
		[[ "$SRC_ITEM" == $(basename "$ITEM") ]] && found=1
	done
	if [[ $found == 0 ]]; then
		echo "Found pdf that is missing in rm_files ""$ITEM"
		./pdf2remarkable.sh --rm_dir "$RM_DIR" "$ITEM"
	else
		echo "Found pdf that is already present in rm_files ""$ITEM"
	fi
done
