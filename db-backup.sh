#!/bin/bash
# db-backup.sh
# A script for backing up databases.
# License: MIT (see LICENSE file before using.)

. config/conf  # include conf

echo -e "Starting database backup...\n"


databases_to_backup_compressed=()

for ((i = 0; i < ${#DATABASES_TO_BACKUP[*]}; i++)) do

    if [ "${DATABASES_TO_BACKUP[$i]}" == "all" ]; then

        echo -e "Dumping all databases...\n"
        mysqldump --single-transaction --all-databases > "all-databases${DB_FILE_EXT}" -u${DB_BACKUP_USERNAME} -p${DB_BACKUP_PASSWORD}

        echo -e "Packaging all databases...\n"
        bash "${LIB_DIRECTORY}/compress.sh" "all-databases${DB_COMPRESSED_FILE_EXT}" "all-databases${DB_FILE_EXT}"

        echo -e "Cleaning up...\n"
        rm "all-databases${DB_FILE_EXT}"

        databases_to_backup_compressed[$i]="all-databases${DB_COMPRESSED_FILE_EXT}"

    else

        echo -e "Dumping ${DATABASES_TO_BACKUP[$i]}\n"
        mysqldump --add-drop-database --databases "${DATABASES_TO_BACKUP[$i]}" > "${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}" -u${DB_BACKUP_USERNAME} -p${DB_BACKUP_PASSWORD}

        echo -e "Packaging ${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}...\n"
        bash "${LIB_DIRECTORY}/compress.sh" "${DATABASES_TO_BACKUP[$i]}${DB_COMPRESSED_FILE_EXT}" "${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}"

        echo -e "Cleaning up...\n"
        rm "${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}"

        databases_to_backup_compressed[$i]="${DATABASES_TO_BACKUP[$i]}${DB_COMPRESSED_FILE_EXT}"

    fi
done


# bundle package
echo -e "Bundling package...\n"

# create destination directory if necessary
if [ ! -d "${DB_PACKAGE_DESTINATION}" ]; then
    mkdir "${DB_PACKAGE_DESTINATION}"
fi


echo -e "Databases to backup: ${DATABASES_TO_BACKUP[*]}\n"


if [ ! -d "${TMP_BACKUP_DIRECTORY}" ]; then
    mkdir "${TMP_BACKUP_DIRECTORY}"
fi

for i in ${databases_to_backup_compressed[*]}
do
    echo -e "Moving $i to ${TMP_BACKUP_DIRECTORY}...\n"
    
    mv "$i" "${TMP_BACKUP_DIRECTORY}"
done


# if we are splitting packages up
if [[ ${DB_PACKAGE_SPLIT} == TRUE ]]; then

    echo -e "This is going to be a split archive.\n"

    bash "${LIB_DIRECTORY}/multi-compress.sh" "${DB_PACKAGE_DESTINATION}/${DB_PACKAGE_FILENAME}." "${TMP_BACKUP_NAME}" "${DB_PACKAGE_SPLIT_SIZE}"

else
    echo -e "This is going to be an unsplit archive.\n"
    
    # add ${TMP_BACKUP_NAME} to each database file's path
    databases_to_backup_compressed_with_prefix=()
    for ((i = 0; i < ${#databases_to_backup_compressed[*]}; i++)) do
        databases_to_backup_compressed_with_prefix[$i]="${TMP_BACKUP_DIRECTORY}/${databases_to_backup_compressed[$i]}"
    done
    
    bash "${LIB_DIRECTORY}/compress.sh" "$DB_PACKAGE_FILENAME" "${databases_to_backup_compressed_with_prefix[*]}"

    mv "$DB_PACKAGE_FILENAME" "${DB_PACKAGE_DESTINATION}/${DB_PACKAGE_FILENAME}"

fi


echo -e "Cleaning up...\n"


# remove old folder
if [ -d "${TMP_BACKUP_DIRECTORY}" ]; then
    echo -e "Removing old ${TMP_BACKUP_DIRECTORY}...\n"
    
    rm -r "${TMP_BACKUP_DIRECTORY}"
fi


exit $?

