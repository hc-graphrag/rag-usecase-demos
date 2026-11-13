# Running the synthetic retrieval demos

This repository contains deterministic, dependency-free retrieval examples for six use cases. The data is synthetic and the code is a lexical baseline, not a GraphRAG implementation or evidence of production accuracy.

Run with Python 3.11 or later:

~~~sh
python src/demo.py --case all
python -m unittest discover -s tests -v
~~~

Cases: maintenance, support, drawings, spreadsheets, contracts, clinical. Experiment parameters and limitations are in config/experiment.json. The canonical technical and planning documents live in https://github.com/hc-graphrag/docs.

## 公開前のセキュリティフック

clone後、変更作業を始める前に一度 `bash scripts/install-hooks.sh` を実行してください。以後、pre-commit と pre-push がステージ内容と送信予定コミットを検査し、機密情報や個人の端末情報があれば公開を止めます。手順と対象は [SECURITY.md](SECURITY.md) を参照してください。
