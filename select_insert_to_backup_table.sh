#!/bin/sh

echo "----------------------------------------------"
echo "./tmp/tablenames.txtに基づいて、"
echo "現在のテストデータを全てバックアップ用テーブルに"
echo "コピーします。"
echo "----------------------------------------------"

# Load Configurations
. ./database_configurations.conf
CONNECTION_STRING=${USER}/${PASSWORD}@${HOSTNAME}:${PORTNO}/${SERVICENAME}

echo
echo "${CONNECTION_STRING}でアクセスしようとしています。意図した挙動ですか？"
echo -n "PRESS ENTER to execute me"
read wait
echo

for LINE in `cat ./tmp/tablenames.txt`;
do 
# ファイルからの読み込みは改行文字が混じるのでそれを削除する
TABLE_NAME=`echo ${LINE} | tr -d '\r' | tr -d '\n'`
echo "----------------------------------------------"
echo "INSERT INTO ${BK_TABLE_NAME} SELECT * FROM ${TABLE_NAME};"
BK_TABLE_NAME="${TABLE_NAME%???}_BK"
sqlplus -s ${CONNECTION_STRING} << EOF
  INSERT INTO ${BK_TABLE_NAME}
  SELECT * FROM ${TABLE_NAME};
  EXIT;
EOF
done
