# MPI, CUDA-Aware MPI, NCCL性能比較用ベンチマーク一式

## ディレクトリ構成
src/
    ソースコード
    測定する最大サイズがdefine.hに書かれているので注意
flow_type2_base/
    「不老」Type IIサブシステム用、OpenMPI用のジョブスクリプトなど

cpu: ホストCPU同士の通信
mpi: CPU-GPU間はcudaMemcpy、CPU間はMPI
ca: GPU間直接MPI通信（Cuda-Aware MPIのCA。Communication Avoidanceではない。）
nccl: GPU間NCCL通信

## ベンチマーク手順

名古屋大学情報基盤センター「不老」Type IIサブシステムでの実例。

このREADME.mdのあるディレクトリにいる状態からスタート。


1. 作業用ディレクトリを作って移動する。
$ mkdir workdir_1p
$ cd workdir_1p
なお基本的には
workdir_1p
workdir_2p
workdir_4p
のように3バリエーション作って実行する想定になっている。
（ノードあたり1プロセス、ノードあたり2プロセス、ノードあたり4プロセスの3種。）


2. ビルドする
$ ../flow_type2_base/build.sh
実際にはsrc/Makefileを呼び出しているだけなので、ビルド環境が合わない場合はMakefileをいじればよい。
カレントディレクトリに実行可能ファイルが作られる。
MakefileにOpenMPIやCUDAの設定は書いていないので、
ビルドスクリプトを呼ぶ時点で見えているものが使われる。
もしも特殊なINCLUDEディレクトリなどを参照する必要がある場合はMakefileをカスタマイズすること。
1p, 2p, 4pでバイナリは変わらないため、使い回して良い。
(ビルドにたいした時間はかからないため、ここは効率化させていない。)


3. モジュール設定ファイルを作る、必要に応じてテンプレートファイルを編集する
次項のジョブスクリプト生成時には、
ジョブテンプレートファイルである
../flow_type2_base/job_type2_*_template.sh
を用いてジョブスクリプトを生成する。

具体的には、これらのテンプレートファイルの複製をカレントディレクトリに持ってきて、
その中の文字列BINをsedで実行ファイル名に置き換える。
テンプレートファイルと同名のファイルがカレントディレクトリにある場合はそれを使うという挙動にしてあるため、
実行環境に合わせたテンプレートファイルを用意しても良い。

いきなり4のジョブスクリプト生成を引数なしで実行すると
テンプレートファイルがカレントディレクトリにtmp付きで複製される(例: job_type2_2n1p_template.tmp.sh)ため
これをtmpなし(例: job_type2_2n1p_template.sh)に複製して利用すると良い。


4. ジョブスクリプトを生成する
3で作成したモジュール設定ファイルやテンプレートファイルを元にジョブスクリプトを生成する。
$ ../flow_type2_base/generate_{1p,2p,4p}.sh
のように実行すると
../flow_type2_base/job_type2_1n2p_template.sh (1node, 2procs/node, 1proc/socket 用)
../flow_type2_base/job_type2_1n4p_template.sh (1node, 4procs/node, 2procs/socket 用)
../flow_type2_base/job_type2_2n1p_template.sh (2nodes, 1proc/node, 1proc/socket 用)
../flow_type2_base/job_type2_2n2p_template.sh (2nodes, 2procs/node, 1procs/socket 用)
../flow_type2_base/job_type2_2n4p_template.sh (2nodes, 4procs/node, 2procs/socket 用)
を元に適宜書き換えが行われてバッチジョブスクリプトファイルが生成される。

3に書いたように、カレントディレクトリに対応する~template.shと同名のファイルが存在する場合には
../flow_type2_base/に置いてあるテンプレートファイルではなく
カレントディレクトリに置いてあるテンプレートファイルが使われる。

引数に1,2,4のいずれかを与えるとそのノード数のもののみが生成される。
数字だけを与えることも、モジュール設定ファイルと数字の両方を与えることも可能。
例 $ ../flow_type2_base/generate_1p.sh 1


5. env.sh を準備する
各ジョブ開始時にevalされるenv.shを用意する。
module loadなどのジョブスクリプト冒頭で実行して欲しい処理を書いておく。
evalの仕様上（で良かったか？）、複数行の命令を実行する場合は行末に；を書いておく必要がある。


6. ジョブを実行する
$ ../flow_type2_base/bench_{1p,2p,4p}.sh
で一括実行が可能。
実際にはローカルに置かれているshファイルを順にpjsubするだけ。
個別のベンチマークを行いたいときは個別のshファイルをpjsubすれば良い。
（一度適当なジョブを単体で実行し動作確認してからまとめて実行するのが妥当。）
1p: ~2n1p.shのみ実行
2p: ~2p.shを実行
4p: ~4p.shを実行
latencyは2プロセス実行の場合しか測定されない。
(手抜きなので実行対象から排除されておらず、実行はされるが、プロセス数の条件で弾かれて終わる。)

実行バリエーションが多く投入可能数制限にひっかかる可能性があるため、
cpu, cuda, ca, ncclを1まとめにしたステップジョブとして実行される。
また引数に1,2,4のいずれかを与えるとそのノード数のもののみが実行される。
例 $ ../flow_type2_base/bench_1p.sh
例 $ ../flow_type2_base/bench_2p.sh 2


7. 実行時間を確認する
実行が終わると
log_1n4p_mpi_reduce.txt
のようなログファイルがそれぞれ作られる。

ルートディレクトリにおいてあるanalyze_1.shとanalyze_2.shを順番に実行すれば
結果のグラフ化まで行ってくれるようにしてある。
実行時にはスクリプト内のディレクトリ名を編集しておく必要がある。
（_1p,_2p,_4pは付けなくて良い。冒頭の例でいうならworkdir。）
analyze_1.shは下記のanalyze_{1p,2p,4p}.shによって画像を生成するスクリプト、
analyze_2.shはグラフをまとめるスクリプト。

内部では
$ ../flow_type2_base/analyze_{1p,2p,4p}.sh
を実行し、ログファイルを元に結果部分だけ抽出したcsvファイルを作成、
そのデータを元にgnuplotで画像を生成している。
*_all.png はreduce, allreduce, reducescatter, allgather, broadcast の各グラフが統合されたもの。
*_all2.png はさらにlatencyも統合されたもの。
latencyは2プロセス実行の場合しか測定されないため、*_all2.pngが生成されるのも該当する場合のみ。

1ノード実行の結果一覧 log_1n{2p,4p}_all.csv　や
2ノード実行の結果一覧 log_2n{1p,2p,4p}_all.csv　も生成される。
Excelで開けばグラフの作成に便利かもしれない。
なおallgather, broadcast, latencyだけCHAR型通信のため1byteから、
それ以外はFLOAT型のため4byteから始まることに注意が必要。

引数に1,2,4のいずれかを与えるとそのノード数のもののみが解析される。
例 $ ../flow_type2_base/analyze_1p.sh
例 $ ../flow_type2_base/analyze_2p.sh 2


A. OpenACC版の測定について
build_acc.sh を使うとACC版のビルドができる。
スクリプト生成は generate_acc_?p.sh
実行は bench_acc_?p.sh
解析は analyze_acc_?p.sh

