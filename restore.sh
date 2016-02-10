#!/bin/bash
# restore.sh
# A script for restoring backups.
# License: MIT (see LICENSE file before using.)

. config/conf   # include conf

# initialize error log
echo "" > ${ERROR_LOG}

echo $@
echo "Starting restore..."
echo ""
echo "Unpacking backup..."
echo ""

if [[ ${PACKAGE_SPLIT} == TRUE ]]; then
    echo "Merging files..."
    echo ""
    bash "${LIB_DIRECTORY}/multi-expand.sh" $@ "${TMP_DIRECTORY}/temp.tar.gz"
else
    bash "${LIB_DIRECTORY}/expand.sh" $*
fi


files_to_expand=()

last_file="_"
x=0
for ((i = 0; i < ${#FILES_TO_BACKUP[*]}; i++)) do

#file_realpath=$(readlink -f "${FILES_TO_BACKUP[$i]}")
file_realpath=$(bash "${LIB_DIRECTORY}/simple_readlink.sh" "${FILES_TO_BACKUP[$i]}")

if [ "${file_realpath##*/}" != "$last_file" ]; then
    # reset individual file counter (document_0, document_1, ...)
    x=0
fi

file_found=FALSE

while [[ $file_found == FALSE ]]; do

    # if this is the first time checking a new file name
    if [ "${file_realpath##*/}" != "$last_file" ]; then

        # if file exists
        if [ -e "${TMP_BACKUP_DIRECTORY}/${file_realpath##*/}${COMPRESSED_FILE_EXT}" ]; then
            files_to_expand[$i]="${TMP_BACKUP_DIRECTORY}/${file_realpath##*/}${COMPRESSED_FILE_EXT}"
            file_found=TRUE
        else
            echo ""
            echo "Error: no file not found at ${file_realpath##*/}${COMPRESSED_FILE_EXT}"
            break
        fi
    
    # else, this is the next time through while checking a file name
    else

        # if file_0 (or file_1, ...)
        if [ -e "${TMP_BACKUP_DIRECTORY}/${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}" ]; then

            #add to array
            files_to_expand[$i]="${TMP_BACKUP_DIRECTORY}/${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}"
            echo "${TMP_BACKUP_DIRECTORY}/${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}"
            file_found=TRUE
            (( x=$x + 1 ))
        else
            echo ""
            echo "Error: no file not found"
            break
        fi

    fi
done

last_file=${file_realpath##*/}
done


x=0
for i in ${files_to_expand[@]}
do
echo ""
echo "Unpacking: $i"
bash "${LIB_DIRECTORY}/expand.sh" $i

echo ""
echo "Copying unpacked '$i' to ${FILES_TO_BACKUP[$x]}"

copy_this=""
if [ "${FILES_TO_BACKUP[$x]:0:1}" == "/" ]; then
    copy_this="${FILES_TO_BACKUP[$x]:1}"
else
    copy_this="${FILES_TO_BACKUP[$x]}"
fi

cp -rp "$copy_this" "$(dirname ${FILES_TO_BACKUP[$x]})" 2>> ${ERROR_LOG}
if [ $? -ne 0 ]; then
    echo ""
    echo "##########################################################################"
    echo "Error: Couldn't copy this file or folder!  Check ${ERROR_LOG} for details"
    echo "##########################################################################"
fi

(( x=x+1 ))
done


echo "Cleaning up..."
echo ""

# delete backup_folder
if [ -d "${TMP_BACKUP_DIRECTORY}" ]; then
rm -r "${TMP_BACKUP_DIRECTORY}"
fi

# delete temporary multi-file archive
if [ -e "${TMP_DIRECTORY}/temp.tar.gz" ]; then
rm "${TMP_DIRECTORY}/temp.tar.gz"
fi


exit $?

