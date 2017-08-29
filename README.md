# sample-statistics-modeling-using-R-

目的：LTV(Life-Time-Value）－コストを最大化させるような回帰分析モデルを作成する

利用データ：ポーランドのマーケティング結果によるデータ（出所は別途明記）

回帰分析モデルの考え方

1.着目したパラメータは以下の通り
- モデル変数（ターゲット層絞り込み）
- job(職種)：引退者と学生は口座作りやすい
- education(学歴)：学歴が高いと口座作りやすい
- defaultunknown（元利払いを不履行してない⇒但しunknownを不履行していないと仮定)
- poutcomesuccess(過去のキャンペーンで作成した人物は口座作りやすい（但し定期預金2つもつくるか？注意が必要）)
- 他にもマクロ経済要因（インフレ、金利、景況）は無視しがたいが、Euribor3Mなどのデータもあるが今のところは無視、時系列分析？）

2.上記変数による重回帰分析実施

3.閾値求める ⇒　#フラグたてる：口座作る1ないしは口座作らない0
- 0から1まで総当たりした場合のフラグをypred_flagに格納し
- 最終的に求めたいのはどのx（閾値）がnet_profitを最大化するかを求める。

4.LTVからコストを差し引いたものを計算
