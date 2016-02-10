#!/bin/bash
# db-restore.sh
# A script for restoring database backups.
# License: MIT (see LICENSE file before using.)

. config/conf   # include conf

echo "Starting restore..."
echo ""
echo "Unpacking backup..."
echo ""
bash "${LIB_DIRECTORY}/expand.sh" $*


databases_to_import=()

for ((i = 0; i < ${#DATABASES_TO_BACKUP[*]}; i++)) do

    if [ "${DATABASES_TO_BACKUP[$i]}" == "all" ]; then

        echo "Unpacking all databases"
        echo ""
        bash "${LIB_DIRECTORY}/expand.sh" "${TMP_BACKUP_DIRECTORY}/all-databases${DB_COMPRESSED_FILE_EXT}"

        #echo "Cleaning up..."
        #echo ""
        #rm "all-databases${DB_COMPRESSED_FILE_EXT}"

        databases_to_import[$i]="all-databases${DB_FILE_EXT}"

        mv "${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}" "${TMP_BACKUP_DIRECTORY}"

    else

        echo "Unpacking ${DATABASES_TO_BACKUP[$i]}"
        echo ""
        bash "${LIB_DIRECTORY}/expand.sh" "${TMP_BACKUP_DIRECTORY}/${DATABASES_TO_BACKUP[$i]}${DB_COMPRESSED_FILE_EXT}"

        #echo "Cleaning up..."
        #echo ""
        #rm "${DATABASES_TO_BACKUP[$i]}${DB_COMPRESSED_FILE_EXT}"

        databases_to_import[$i]="${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}"
        
        mv "${DATABASES_TO_BACKUP[$i]}${DB_FILE_EXT}" "${TMP_BACKUP_DIRECTORY}"

    fi

done


for i in ${databases_to_import[*]}; do

    echo "Importing $i into database..."
    echo ""
    #if [ "$i" == "all-databases${DB_FILE_EXT}" ]; then
    #    mysql < "$i" -u${DB_RESTORE_USERNAME} -p${DB_RESTORE_PASSWORD}
    #else
        echo "${TMP_BACKUP_DIRECTORY}/$i" -u${DB_RESTORE_USERNAME} -p${DB_RESTORE_PASSWORD}
        mysql < "${TMP_BACKUP_DIRECTORY}/$i" -u${DB_RESTORE_USERNAME} -p${DB_RESTORE_PASSWORD}
    #fi

done


echo "Cleaning up..."
echo ""
#for i in ${databases_to_import[*]}; do
#    rm "$i"
#done


exit $?

