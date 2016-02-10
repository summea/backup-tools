#!/bin/bash
# backup.sh
# A script for backing up files and directories. 
# License: MIT (see LICENSE file before using.)

. config/conf  # include conf

# initialize error log
echo "" > ${ERROR_LOG}

echo -e "Starting backup...\n"

# get exclude files and format so it will work with compress.sh call
exclude_files_command_line_format=()
for ((i = 0; i < ${#EXCLUDE_FILES[*]}; i++)) do
    exclude_files_command_line_format[$i]=" --exclude '${EXCLUDE_FILES[$i]}'"
done


for i in ${FILES_TO_BACKUP[*]}; do

    # get full path for file(s) we are going to compress
    #file_realpath=$(stat -f "$i")
    file_realpath=$(bash "${LIB_DIRECTORY}/simple_readlink.sh" "$i")

    # compress file(s)
    echo "backing up: $i"

    file_created=FALSE
    was_error=FALSE
    x=0
    
    while [[ $file_created == FALSE ]]; do

        # if no file exists at file_0 (or file_1, ...)
        if ! [ -e "${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}" ]; then

            # if this is the first time through for individual file
            if [ $x == 0 ]; then

                # if file doesn't exist yet, package as plain file name (no _0, _1, ...)
                if ! [ -e ${file_realpath##*/}${COMPRESSED_FILE_EXT} ]; then
                    eval bash "${LIB_DIRECTORY}/compress.sh" "${file_realpath##*/}${COMPRESSED_FILE_EXT}" "$i" ${exclude_files_command_line_format[@]} 2>> ${ERROR_LOG}
                    if [ $? -ne 0 ]; then
                        was_error=TRUE
                    fi
                else
                    eval bash "${LIB_DIRECTORY}/compress.sh" "${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}" "$i" ${exclude_files_command_line_format[@]} 2>> ${ERROR_LOG}
                    if [ $? -ne 0 ]; then
                        was_error=TRUE
                    fi
                fi

            # else this is not the first time through
            else
                eval bash "${LIB_DIRECTORY}/compress.sh" "${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}" "$i" ${exclude_files_command_line_format[@]} 2>> ${ERROR_LOG}
                if [ $? -ne 0 ]; then
                    was_error=TRUE
                fi
            fi
            file_created=TRUE

        # if file does exist, increment x so we don't overwrite previous file
        else
            (( x=$x + 1 ))
        fi

        # output errors (if any)
        if [[ $was_error == TRUE ]]; then
            echo "########################################################################################"
            echo "Error: Couldn't package certain file(s) or folder(s)!  Check ${ERROR_LOG} for details"
            echo -e "########################################################################################\n"
            was_true=FALSE
        fi

    done

done

echo ""

files_to_backup_compressed=()

# add compressed file names to a new array that we will use
# later to delete these compressed files when done

last_file="_"
x=0

for ((i = 0; i < ${#FILES_TO_BACKUP[*]}; i++)) do

    #file_realpath=$(stat -f "${FILES_TO_BACKUP[$i]}")
    #file_realpath=$(simple_readlink.sh "${FILES_TO_BACKUP[$i]}")
    file_realpath=$(bash "${LIB_DIRECTORY}/simple_readlink.sh" "${FILES_TO_BACKUP[$i]}")

    # reset x if we are looking at a new file than the last file we were looking at
    if [ "${file_realpath##*/}" != "$last_file" ]; then
        x=0
    fi

    file_found=FALSE

    while [[ $file_found == FALSE ]]; do

        # if this file is different than the previous file we were looking at
        if [ "${file_realpath##*/}" != "$last_file" ]; then

            if [ -e "${file_realpath##*/}${COMPRESSED_FILE_EXT}" ]; then
                files_to_backup_compressed[$i]="${file_realpath##*/}${COMPRESSED_FILE_EXT}"
                file_found=TRUE
            fi
        

        # else we are looking at a duplicate file name but don't want to overwrite old file
        else

            if [ -e "${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}" ]; then

                #add to array
                files_to_backup_compressed[$i]="${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}"
                echo "${file_realpath##*/}_$x${COMPRESSED_FILE_EXT}"
                file_found=TRUE
                (( x=$x + 1 ))
            fi

        fi
    done

    last_file=${file_realpath##*/}
done


# bundle package
echo -e "bundling package...\n"

# create destination directory if necessary
if [ ! -d "${PACKAGE_DESTINATION}" ]; then
    mkdir "${PACKAGE_DESTINATION}"
fi


echo -e "Files to backup: ${files_to_backup_compressed[*]}\n"

if [ ! -d "${TMP_BACKUP_DIRECTORY}" ]; then
    mkdir "${TMP_BACKUP_DIRECTORY}"
fi

for i in ${files_to_backup_compressed[*]}
do
    echo -e "Moving $i to ${TMP_BACKUP_DIRECTORY}...\n"
    mv "$i" "${TMP_BACKUP_DIRECTORY}"
done


# if we are splitting packages up
if [[ ${PACKAGE_SPLIT} == TRUE ]]; then

    echo -e "This is going to be a split archive.\n"
    echo -e "This may take a while...\n"
    
    bash "${LIB_DIRECTORY}/multi-compress.sh" "${PACKAGE_DESTINATION}/${PACKAGE_FILENAME}." "${TMP_BACKUP_NAME}" "${PACKAGE_SPLIT_SIZE}"

else

    echo -e "This is going to be an unsplit archive.\n"
    echo -e "This may take a while...\n"

    # add ${TMP_BACKUP_NAME} to each file's path
    files_to_backup_compressed_with_prefix=()
    for ((i = 0; i < ${#files_to_backup_compressed[*]}; i++)) do
        files_to_backup_compressed_with_prefix[$i]="${TMP_BACKUP_DIRECTORY}/${files_to_backup_compressed[$i]}"
    done

    bash "${LIB_DIRECTORY}/compress.sh" "$PACKAGE_FILENAME" "${files_to_backup_compressed_with_prefix[*]}"

    mv "$PACKAGE_FILENAME" "${PACKAGE_DESTINATION}/${PACKAGE_FILENAME}"
fi

echo -e "cleaning up...\n"

# remove old folder
if [ -d "${TMP_BACKUP_DIRECTORY}" ]; then
    echo -e "Removing old ${TMP_BACKUP_DIRECTORY}...\n"
    rm -r "${TMP_BACKUP_DIRECTORY}"
fi


exit $?
