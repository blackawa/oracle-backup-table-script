#!/bin/sh

echo "----------------------------------------------"
echo "./tmp/tablenames.txtに基づいて"
echo "現在のテーブル定義からリストア用のSQLファイルを"
echo "作成します。"
echo "----------------------------------------------"

# Load Configurations
. ./database_configurations.conf
CONNECTION_STRING=${USER}/${PASSWORD}@${HOSTNAME}:${PORTNO}/${SERVICENAME}

echo
echo "${CONNECTION_STRING}でアクセスしようとしています。意図した挙動ですか？"
echo -n "PRESS ENTER to execute me"
read wait
echo

# Define Variables
RESTORE_FILENAME=./restore.sql

# 前回の出力結果を削除
rm ${RESTORE_FILENAME}
if [ $? -ne 0 ]; then
  echo "前回の結果ファイル ${RESTORE_FILENAME} を削除できませんでした。"
  exit 1
fi

for LINE in `cat ./tmp/tablenames.txt`;
do 
# ファイルからの読み込みは改行文字が混じるのでそれを削除する
TABLE_NAME=`echo ${LINE} | tr -d '\r' | tr -d '\n'`
BK_TABLE_NAME="${TABLE_NAME%???}_BK"
echo "GENERATE RESTORE SCRIPT FOR ${TABLE_NAME}"

# テーブルとカラムの紐付きをファイルに書き出す
sqlplus -s ${CONNECTION_STRING} @load_table_columns.sql ${TABLE_NAME}
# 書き出したファイルからカラム一覧を取得して、カンマ区切りに整形する
COLUMNS=`tr '\r' ',' <./tmp/TAB_COLUMNS_${TABLE_NAME}.LST | tr -d '\n' | sed -e 's/,$//'`

echo "INSERT INTO ${TABLE_NAME} (${COLUMNS}) SELECT ${COLUMNS} FROM ${BK_TABLE_NAME};" >> ${RESTORE_FILENAME}
done

echo "----------------------------------------------"
echo "リストアに使用するためのひな形となるSQLファイルを"
echo "生成しました: ${RESTORE_FILENAME}"
echo "----------------------------------------------"

exit 0
