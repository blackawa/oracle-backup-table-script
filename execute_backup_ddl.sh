#!/bin/sh

echo "----------------------------------------------"
echo "sed_for_backup.shで生成した"
echo "バックアップテーブル作成DDLを実行する。"
echo "ファイル名が変わらないので驚くかもしれませんが、"
echo "中身はちゃんとバックアップ用テーブルになっています。"
echo "----------------------------------------------"

# Load Configurations
. ./database_configurations.conf

CONNECTION_STRING=${USER}/${PASSWORD}@${HOSTNAME}:${PORTNO}/${SERVICENAME}

echo
echo "${CONNECTION_STRING}でアクセスしようとしています。意図した挙動ですか？"
echo -n "PRESS ENTER to execute me"
read wait
echo

cd ./backup_ddl

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
