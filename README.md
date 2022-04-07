MPI, CUDA-Aware MPI, NCCL性能比較用一式

- ディレクトリ構成
src/
    ソースコード
    測定する最大サイズがdefine.hに書かれているので注意
job_openmpi_base/
    「不老」Type IIサブシステム用、OpenMPI用のジョブスクリプトなど


- 「不老」Type II OpenMPIベンチマーク手順

(このREAME.txtのあるところ、commbenchディレクトリにいる状態からスタート)


1. srcと同じ階層に作業用ディレクトリを作って移動する。
$ mkdir workdir_1p
$ cd workdir_1p
なお基本的には
workdir_1p
workdir_2p
workdir_4p
のように3バリエーション作って実行する想定になっている。
（ノードあたり1プロセス、ノードあたり2プロセス、ノードあたり4プロセスの3種。）


2. ビルドする
$ ../job_openmpi_base/build.sh
実際にはsrc/Makefileを呼び出しているだけ。
カレントディレクトリに実行可能ファイルが作られる。
MakefileにOpenMPIやCUDAの設定は書いていないので、
ビルドスクリプトを呼ぶ時点で見えているものが使われる。
もしも特殊なINCLUDEディレクトリなどを参照する必要がある場合はMakefileをカスタマイズすること。
1p, 2p, 4pでバイナリは変わらないため、使い回して良い。
(ビルドにたいした時間はかからないため、ここは効率化させていない。)


3. モジュール設定ファイルを作る、またはテンプレートファイルを作る
次項のジョブスクリプト生成時には、
ジョブテンプレートファイルである
../job_openmpi_base/job_type2_*_template.sh
を用いてジョブスクリプトを生成する。

具体的には、これらのテンプレートファイルの複製をカレントディレクトリに持ってきて、
その中の文字列BINをsedで実行ファイル名に置き換える。
テンプレートファイルと同名のファイルがカレントディレクトリにある場合はそれを使うという挙動にしてあるため、
実行環境に合わせたテンプレートファイルを用意しても良い。

いきなり4のジョブスクリプト生成を引数なしで実行すると
テンプレートファイルがカレントディレクトリにtmp付きで複製される(例: job_type2_2n1p_template.tmp.sh)ため
これをtmpなし(例: job_type2_2n1p_template.sh)に複製して利用すると良い。

（旧版では文字列MODULESを置き換える挙動にしていたが、env.shをevalする挙動に変更した。）


4. ジョブスクリプトを生成する
3で作成したモジュール設定ファイルやテンプレートファイルを元にジョブスクリプトを生成する。
$ ../job_openmpi_base/generate_{1p,2p,4p}.sh
のように実行すると
../job_openmpi_base/job_type2_1n2p_template.sh (1node, 2procs/node, 1proc/socket 用)
../job_openmpi_base/job_type2_1n4p_template.sh (1node, 4procs/node, 2procs/socket 用)
../job_openmpi_base/job_type2_2n1p_template.sh (2nodes, 1proc/node, 1proc/socket 用)
../job_openmpi_base/job_type2_2n2p_template.sh (2nodes, 2procs/node, 1procs/socket 用)
../job_openmpi_base/job_type2_2n4p_template.sh (2nodes, 4procs/node, 2procs/socket 用)
を元に適宜書き換えが行われてバッチジョブスクリプトファイルが生成される。

3に書いたように、カレントディレクトリに対応する~template.shと同名のファイルが存在する場合には
../job_openmpi_base/に置いてあるテンプレートファイルではなく
カレントディレクトリに置いてあるテンプレートファイルが使われる。

引数に1,2,4のいずれかを与えるとそのノード数のもののみが生成される。
数字だけを与えることも、モジュール設定ファイルと数字の両方を与えることも可能。
例 $ ../job_openmpi_base/generate_1p.sh 1


5. env.sh を準備する
各ジョブ開始時にevalされるenv.shを用意する。
module loadなどのジョブスクリプト冒頭で実行して欲しい処理を書いておく。
仕様上、複数行の命令を実行する場合は行末に；を書いておく必要がある。


6. ジョブを実行する
$ ../job_openmpi_base/bench_{1p,2p,4p}.sh
で一括実行が可能。
実際にはローカルに置かれているshファイルを順にpjsubするだけ。
個別のベンチマークを行いたいときは個別のshファイルをpjsubすれば良い。
（一度適当なジョブを単体で実行し動作確認してからまとめて実行するのが妥当。）
1p: ~2n1p.shのみ実行
2p: ~2p.shを実行
4p: ~4p.shを実行
latencyは2プロセス実行の場合しか測定されない。
(実行はされるが、プロセス数の条件で弾かれて終わる。)

実行バリエーションが多く投入可能数制限にひっかかる可能性があるため、
cpu, cuda, ca, ncclを1まとめにしたステップジョブとして実行される。
また引数に1,2,4のいずれかを与えるとそのノード数のもののみが実行される。
例 $ ../job_openmpi_base/bench_1p.sh
例 $ ../job_openmpi_base/bench_2p.sh 2


7. 実行時間を確認する
実行が終わると
log_1n4p_mpi_reduce.txt
のようなログファイルがそれぞれ作られる。
$ ../job_openmp_base/analyze_{1p,2p,4p}.sh
を実行すると、ログファイルを元に結果部分だけ抽出したcsvファイルが作られる。
さらに、
1ノード実行の結果一覧 log_1n{2p,4p}_all.csv
や
2ノード実行の結果一覧 log_2n{1p,2p,4p}_all.csv
も生成される。
これらをExcelで開けばグラフの作成に便利。
なおallgather, broadcast, latencyだけCHAR型通信のため1byteから、
それ以外はFLOAT型のため4byteから始まることに注意。

引数に1,2,4のいずれかを与えるとそのノード数のもののみが解析される。
例 $ ../job_openmpi_base/analyze_1p.sh
例 $ ../job_openmpi_base/analyze_2p.sh 2

さらにgnuplotでpng形式のグラフも生成するようにした。
*_all.png はreduce, allreduce, reducescatter, allgather, broadcast の各グラフが統合されたもの。
*_all2.png はさらにlatencyも統合されたもの。
latencyは2プロセス実行の場合しか測定されないため、*_all2.pngが生成されるのも該当する場合のみ。


8. グラフの取りまとめ
analyze1.sh と analyze2.sh でグラフをまとめられるようにした。
スクリプト内のディレクトリ名を編集して実行する。




OpenACC版の測定について
build_acc.sh を使うとACC版のビルドができる。
スクリプト生成は generate_acc_?p.sh
実行は bench_acc_?p.sh
解析は analyze_acc_?p.sh

