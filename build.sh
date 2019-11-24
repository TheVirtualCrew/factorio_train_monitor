#!/bin/bash

dirname="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
ignores="build.sh modportal/ .DS_Store README.md .git/ .gitignore"
modname=$(grep '"name"' info.json| cut -d ":" -f2 | sed 's/[", ]//g')
version=$(grep '"version"' info.json| cut -d ":" -f2 | sed 's/[", ]//g')
release="${modname}_${version}"

cmd="rsync -a \"${dirname}\" \"${dirname}/../${release}/\""
for ignore in $ignores
do
    cmd+=" --exclude ${ignore}"
done

$(eval $cmd)
cd "${dirname}../"
zip -r "${release}.zip" "${release}/"
rm -rf "${release}/"
cd "${dirname}"
