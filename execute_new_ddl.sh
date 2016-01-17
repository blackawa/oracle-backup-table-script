#!/bin/sh

echo "----------------------------------------------"
echo "./new_ddl ディレクトリ内のファイルを全てSQLとして"
echo "実行する。"
echo "----------------------------------------------"

# Load Configurations
. ./database_configurations.conf

CONNECTION_STRING=${USER}/${PASSWORD}@${HOSTNAME}:${PORTNO}/${SERVICENAME}

echo
echo "${CONNECTION_STRING}でアクセスしようとしています。意図した挙動ですか？"
echo -n "PRESS ENTER to execute me"
read wait

cd ./new_ddl

for FILE_NAME in `ls`
do
  echo "EXECUTING ${FILE_NAME} ..."
sqlplus -s ${CONNECTION_STRING} << EOF
-- コマンドの結果出力を非表示
set termout off
@${FILE_NAME}
EXIT;
EOF
done
