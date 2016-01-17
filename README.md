# Oracle Database BackUp Script w/ Select Insert

OracleDatabaseのデータをバックアップ用のテーブルに退避、復旧するスクリプトです。

## 使い方

初回は、`./backup_ddl`、`./new_ddl`ディレクトリを作っておく。
(そのディレクトリ内をlsした結果でループを回すため、.gitkeepを置けない。)

1. `./database_configurations.conf`を、バックアップを取りたいデータベースの情報に合わせて修正する。
1. `backup_ddl`ディレクトリにバックアップを取りたい任意テーブルのddlを格納する。( **必ずインデックス作成のDDLも格納すること。** )
1. `sed_for_backup.sh`を実行して現在のバージョンのddlをバックアップ用テーブルのddlに変換する。
1. `generate_restore_sql.sh`を実行して、現在のテーブル定義から単純な(修正が必要な)リストア用sqlファイルを生成する。
1. `execute_backup_ddl.sh`を実行して、バックアップ用テーブルを生成するDDLを全て実行する。
1. `select_insert_to_backup_table.sh`を実行して、データを全て退避する。
1. `drop.sh`を実行して現在のテスト用テーブルを全て削除する。
1. 連携されたDDLを実行する。(やり方は問わないが、実行したいDDLを`./new_ddl`ディレクトリに入れて`execute_new_ddl.sh`を叩くと実行してくれる。)
1. `restore.sql`を必要な形に変更する。
1. `restore.sql`を実行する。ただしsqlplusにスクリプトとして渡すと文字数過多でエラーを吐くため、違う手段で。
1. データが正常にリストアできたことを確認したら、`drop_backup.sh`を実行して、必要なくなったバックアップテーブルを削除する。

## 実行過程で出力されるファイルとその役割

本スクリプトは、SQLで取得したテーブル情報を一部SPOOLしてファイルに出力し、それを元に必要な情報を構築している。
本項ではそれらファイル群についてまとめる。

|ファイル名|出力されるタイミング|役割と使用されるタイミング|
|:-:|:-:|:-:|
|./tmp/tablenames.txt|`sed_for_backup.sh`実行時|バックアップが必要なテーブル名のリスト。`./backup_ddl`内のDDLから生成され、その後のスクリプトでバックアップ対象を知るためにロードされる。|
|./tmp/TAB_COLUMNS_${TABLE_NAME}.LST|`generate_restore_sql.sh`実行時|ファイル名についたテーブルが持つカラム一覧のリスト。`generate_restore_sql.sh`内で、リストア用のSELECT INSERT文にカラム一覧を埋め込むために使用される。|
|./restore.sql|`generate_restore_sql.sh`実行時|新しい定義のテーブルに入るように修正してから実行するSQLファイル。|

## バックアップテーブルの命名ルール

バックアップテーブルとそのインデックスは、テーブル名の末尾3文字を`_BK`に置換することで生成しています。

具体的には以下のようなコマンドで実現しています。修正の必要がある時はこれを参考にgrepしてください。

```sh
# shの文法で、後方一致の置換を表現します。
BK_TABLE_NAME="${TABLE_NAME%???}_BK"
```

## `restore.sql`の修正方法

`restore.sql`は、バックアップテーブルから元テーブルへのSELECT INSERT文の集合です。
テーブル定義が変わった時に書き直せるように、すべてのカラム名を指定しています。

実行前に、該当テーブルのカラムの対応関係を修正してから実施してください。

どのように修正すべきかは単純にOracleの文法に依存するので、以下のサイトなどをご確認ください。

[INSERT - オラクル・Oracle SQL 入門](http://www.shift-the-oracle.com/sql/insert.html)
