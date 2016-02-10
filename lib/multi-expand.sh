#!/bin/bash
# combine and expand (uncompress) file(s)
# permissions are preserved with -p option
#
# cat backup.tgz.* > backup.tgz

source "$(pwd)/config/conf"

combine_source=
destination=

for i in "$@"
do
    if [ "$i" != "${@: -1}" ]; then
        combine_source="${combine_source}$i "
    else
        destination="$i"
    fi
done

echo $combine_source

# combine files into one big file
cat $combine_source > "$destination"

# move combined archive to tmp directory
mv "$destination" "${TMP_DIRECTORY}/temp.tar.gz"

echo "${TMP_DIRECTORY}/temp.tar.gz"

# expand that big file
tar -xpzvf "${TMP_DIRECTORY}/temp.tar.gz"


echo "Multi-expand complete!"
echo ""

exit $?
