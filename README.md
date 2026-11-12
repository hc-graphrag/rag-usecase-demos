# RAG Use Case Demos

再現可能な小規模デモの置き場です。技術解説・事業企画の正本は [hc-graphrag/docs](https://github.com/hc-graphrag/docs) です。

## 現在の範囲

この初期版は6業務の合成データを使う、依存なしの決定的な文字語彙ベースラインです。LLM、埋め込み、GraphRAGは呼びません。よって実顧客データの有効性、精度、性能を示す結果ではありません。日本語の文字bigramを使う簡易検索で、各ユースケースの動作経路と回帰テストを確認します。

## 実行

Python 3.11以上、標準ライブラリのみ。

~~~sh
python src/demo.py --case all
python -m unittest discover -s tests -v
~~~

個別指定は --case maintenance, support, drawings, spreadsheets, contracts, clinical のようにします。出力は検索した質問、上位文書ID、得点、出典を含みます。

## 実験設定

config/experiment.json にランキング方式、top-k、文字bigram、seed、データファイル、制約を記録しています。テストは合成ケース6問の期待文書を確認します。設定変更時は設定値とテスト結果を一緒に記録してください。

## 次の実証段階

データ所有者承認後に非機密サンプルを追加し、文書ID・版・ページ/シート・ACLを保持。現行検索およびキーワード/ベクトル/ハイブリッドとの同一質問比較、更新・削除・権限試験を実施します。GraphRAG比較を追加する場合は、指定の [llamaindex-python](https://github.com/hc-graphrag/llamaindex-python) を参照し、依存コミットと実験環境を固定してください。
