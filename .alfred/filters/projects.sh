#!/bin/bash

INPUT=$1
ALL_PROJECTS=$(ls ~/.alfred/projects | sed -e 's/\.[^.]*$//')

if [[ $# -eq 0 ]]
then
  PROJECTS=($ALL_PROJECTS)
else
  PROJECTS=()
  for item in $ALL_PROJECTS
  do
    [[ $item == $1* ]] && PROJECTS+=($item)
  done
fi

ITEMS=""

for PROJECT in ${PROJECTS[*]}
do
  ITEMS+=$(cat << EOF
    <item uid="$PROJECT" arg="$PROJECT" valid="YES" autocomplete="$PROJECT" type="default">
      <title>$PROJECT</title>
      <icon type="fileicon">/Applications/Utilities/Script Editor.app</icon>
    </item>
  )
done

cat << EOF
<?xml version="1.0"?>
<items>$ITEMS</items>
EOF
