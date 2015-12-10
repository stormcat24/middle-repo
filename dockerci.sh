#!/usr/bin/env bash
COMMAND=$1

if [ $COMMAND != "build" -a $COMMAND != "push" ]; then
  echo "$COMMAND is invalid command. (Required build|push)." 1>&2
  exit 1
fi

REGISTORY="your-registry:5000"
CURRENT_BRANCH=`git rev-parse --abbrev-ref @`

# 変更があったdockerイメージを取得
if [ $CURRENT_BRANCH = "master" ]; then
  # 現在がmasterであれば、直前のコミットと比較
  TARGET="HEAD^ HEAD"
else
  # masterブランチ以外であれば、origin/masterの最新と比較
  TARGET="origin/master"
fi
git diff $TARGET --name-only | awk '{sub("docker/", "", $0); print $0}' | awk '{print substr($0, 0, index($0, "/") -1)}' > check.tmp

for dir in `ls`
do
  if [ -d $dir ]; then
    imagefile="$dir/image.txt"
    if [ -e $imagefile ]; then
      cat check.tmp | grep -e "^$dir$" > /dev/null
      if [ $? -eq 0 ]; then
        echo "modified $dir"
        name="`cat $imagefile | head -1`:latest"
        echo -e "\e[36m[BUILD]\e[mstart docker build: $name"
        if [ $COMMAND = "build" ]; then
          docker build -t $name $dir
          if [ $? -ne 0 ]; then
            echo -e "\e[31m[FAILED]\e[m docker build -t $name $dir"
            exit 1
          fi
          docker tag -f $name $REGISTORY/$name
        elif [ $COMMAND = "push" ]; then
          #docker push $REGISTORY/$name
          echo "docker push $REGISTORY/$name"
        fi
      else
        echo -e "\e[35m[SKIP]\e[m $dir is not modified."
      fi
    else
      echo -e "\e[33m[WARN]\e[m $imagefile is not found"
    fi
  fi
done

rm check.tmp
