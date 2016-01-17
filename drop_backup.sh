#!/bin/sh

echo "----------------------------------------------"
echo "./tmp/tablenames.txtに基づいて"
echo "今回リストア用に生成されたバックアップテーブルを"
echo "削除します。"
echo "----------------------------------------------"

# Load Configurations
. ./database_configurations.conf
CONNECTION_STRING=${USER}/${PASSWORD}@${HOSTNAME}:${PORTNO}/${SERVICENAME}

echo
echo "${CONNECTION_STRING}でアクセスしようとしています。"
echo "注意！ 本当に意図した操作ですか？"
echo -n "PRESS ENTER **2 TIMES** to execute..."
read wait
read wait

for LINE in `cat ./tmp/tablenames.txt`;
do 
# ファイルからの読み込みは改行文字が混じるのでそれを削除する
TABLE_NAME=`echo ${LINE} | tr -d '\r' | tr -d '\n'`
BK_TABLE_NAME="${TABLE_NAME%???}_BK"
echo "DROP TABLE ${BK_TABLE_NAME};"
sqlplus -s ${CONNECTION_STRING} << EOF
  -- 処理結果文の非表示
  set feedback off

  DROP TABLE ${BK_TABLE_NAME};
  EXIT;
EOF
done
