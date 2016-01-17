#!/bin/sh

echo "----------------------------------------------"
echo "./backup_ddl ディレクトリ内の全てのファイルを"
echo "バックアップテーブルのDDLに書き換えます。"
echo "また、テーブル名一覧をファイルに保存します。"
echo "(のちの作業で必要)"
echo "----------------------------------------------"

rm -rf ./tmp/*
cd ./backup_ddl

for TABLE_NAME in `ls | sed -e 's/10_CREATE_//' | sed -e 's/20_CREATE_//' | sed -e 's/.sql//' | grep -v PK_`
do
  echo ${TABLE_NAME} >> ../tmp/tablenames.txt
  echo "RENAMING ${TABLE_NAME} ..."
  BK_TABLE_NAME="${TABLE_NAME%???}_BK"
  # 置換対象を絞らないと「テーブル名_ID」みたいなカラム名まで置換されるので細かく置換対象を指定する。
  # "TABLE TABLE_NAME" ステートメントを狙い撃ちで置換する。
  grep -l ${TABLE_NAME} ./* | xargs sed -i -e "s/TABLE\ ${TABLE_NAME}/TABLE\ ${BK_TABLE_NAME}/g"
  # "PK_TABLE_NAME" 項目を狙い撃ちで置換する。
  grep -l ${TABLE_NAME} ./* | xargs sed -i -e "s/PK_${TABLE_NAME}/PK_${BK_TABLE_NAME}/g"
done

