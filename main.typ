#set page(paper: "a4", margin: 2.5cm)
#set text(font: ("New Computer Modern", "Noto Serif JP", "Yu Mincho", "BIZ UDPMincho", "MS Mincho"), size: 10.5pt)
#set par(justify: true, leading: 1.2em, first-line-indent: 1em)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 16pt, weight: "bold")[空間操作が順序に依存しない場合の一般化]
  #v(1.5em)
]

= 一般化された定理

多次元格子空間上において、各格子点に値の未定義状態もしくは数値のいずれかの状態を取る格子が分布している状態を考える。この空間に対する操作が、各次元ごとの独立した変換の組み合わせとして表現できる場合、その次元ごとの操作を適用する順序は最終的な結果に影響を与えない。このような操作を「空間操作が順序に依存しない操作」と呼ぶ。

#v(1em)
#align(center)[
  #block(width: 100%, stroke: 1pt + black, inset: 1.5em, radius: 0.5em, align(left)[
    *定理（空間操作が順序に依存しない操作）* \
    空間の状態を $V$ とし、ある次元 $i$ に沿った操作を作用素 $D_i$ とする。以下の2条件を満たすとき、任意の2つの次元の操作（$D_i, D_j$）はどちらを先に行っても結果が等しい（$D_i compose D_j = D_j compose D_i$）。

    + *分離可能な評価関数* \
      ある起点 $p$ に値が存在する場合のみ、目的地のマス $x$ へ向かう変位ベクトル（正負の向きを持つ距離） $d = x - p$ および起点 $p$ に依存する関数 $f_i(d, p)$ を引き、「到達候補」となる値 $V(p) - f_i(d, p)$ を生成する。これは次元ごとに独立して計算できる。
    + *演算の可換・結合・分配法則* \
      複数の起点から同じマスに到達候補が集まった際、それらの集合を1つの値にまとめる集約演算 $plus.circle$ について、計算の順番や組み合わせを変えても結果が変わらず（可換・結合的）、かつ「関数による変化量 $f_i(d, p)$ を引く」操作を後からまとめて行っても結果が等しい性質を持つ。
  ])
]
#v(1em)

= 未定義状態の扱いについて
例えば、集約演算が $max$ のときは空マスを $-oo$ とし、加算（$+$）のときは $0$ とみなす（すなわち演算の単位元をデフォルト値とする）方法は、適用する集約演算の種類によって空間の基本状態が依存してしまい、抽象化の観点からは最適とは言いがたい。

終了条件やデフォルト値の解釈に曖昧さが残るためである。これを解決するアプローチとして、空間を「各座標が単一の値を持つ関数」ではなく、「各座標が*値の集合*を持つ写像」として定義し直す手法が挙げられる。

- 値が存在しない状態は、特定のデフォルト値ではなく単なる「空集合 $emptyset$」として表す。
- 作用素 $D_i$ は、存在する値のみを移動・変換し、移動先の座標に「到達候補値の集合」を生成する。
- 集約演算 $plus.circle$ は、要素が1つ以上ある集合に対してのみ適用され単一の値を返す。到着した集合が空（$emptyset$）の場合は、そのまま空集合となる。


= 定理の証明

分かりやすくするために、2次元空間を例に証明を行う。
X方向の操作を $D_X$、Y方向の操作を $D_Y$ とする。空間上の任意の起点を $(p, q)$、その初期状態の値を $V(p, q)$ とし、変位 $d$ および起点に依存する評価関数をそれぞれ $f_X, f_Y$ とする。

ある起点 $(p, q)$ の値が目的地 $(x, y)$ に到達するときの候補値は、$V(p,q) - f_X(x-p, p) - f_Y(y-q, q)$ のように計算される。

まず、$D_X$ を適用した後の状態 $V_X$ を考える。これは、同じ高さ（Y座標 $q$）に存在する全ての横方向（X座標 $p$）からの候補値の集合に対し、集約演算 $plus.circle$ を適用したものである。
$V_X (x, q) = plus.circle.big_p ( V(p, q) - f_X (x - p, p) )$

次に、その結果に対して $D_Y$ を適用する。今度は、同じ縦の列（X座標 $x$）に存在する全ての縦方向（Y座標 $q$）からの影響をまとめる。
$
  V_(X Y) (x, y) & = plus.circle.big_q ( V_X (x, q) - f_Y (y - q, q) ) \
                 & = plus.circle.big_q ( ( plus.circle.big_p ( V(p, q) - f_X (x - p, p) ) ) - f_Y (y - q, q) )
$

ここで、定理の前提条件である「分配法則」を用いる。集約演算 $plus.circle$ に対して「関数を引く」操作は分配できるため、外側にある $- f_Y(y-q, q)$ を内側のまとまりの中に入れることができる。
$V_(X Y) (x, y) = plus.circle.big_q plus.circle.big_p ( V(p, q) - f_X (x - p, p) - f_Y (y - q, q) )$

さらに、集約演算 $plus.circle$ は順番を問わないため、縦と横のどちらから計算をまとめても、全座標 $(p, q)$ の集合から一斉に集約することと同じになる。また、関数の適用（$f_X$ と $f_Y$）も独立しているため順番を入れ替えられる。
$
  V_(X Y) (x, y) & = plus.circle.big_(p, q) ( V(p, q) - f_X (x-p, p) - f_Y (y-q, q) ) \
                 & = plus.circle.big_p plus.circle.big_q ( ( V(p, q) - f_Y (y - q, q) ) - f_X (x - p, p) ) \
                 & = D_X [D_Y [V]] (x, y)
$

これにより、$D_X compose D_Y = D_Y compose D_X$ が示され、「XからY」の順でも「YからX」の順でも結果が一致することが証明された。
また、$f_X, f_Y$は任意の関数で成り立つ。

#pagebreak()

= 集約演算の分類

本体系において、ある格子座標に複数の起点からの到達候補値の集合が形成された場合、それらを1つの状態に決定するための「集約規則」が必要となる。ただし、操作の性質によってこの規則が不要な場合もある。

== 規則が不要な処理（単射な操作）
移動先が一意に決定され、複数の起点が同一の目的地にマッピングされない操作である。到達する候補値の集合の要素数が常に1以下になるため、集約演算が不要となる。例えば、図形全体の平行移動や縮小の操作など。

== 規則が必要な処理（単射ではない操作）
波紋のような値の伝播など、同じ格子に複数の値が到達し得る操作である。この場合、適用される演算子 $plus.circle$ は可換法則および結合法則を満たす必要がある。例えば以下のようなものである。

- 最大値（$max$）や最小値（$min$）：評価関数が「減算」で定義される場合に分配法則を満たす。
- 加算（$+$）や乗算（$times$）：評価関数が「乗算」などで定義される場合に分配法則を満たす。
- 集合的演算：「平均値」や「最頻値」の算出。

#pagebreak()

= 具体例

本体系は幾何学的な操作から値の伝播までを包含できる。以下に $5 times 5$ の2次元空間における具体例を図示する。

#let cell-size = 2.5em
#let grid-table(..content) = table(
  columns: (cell-size, cell-size, cell-size, cell-size, cell-size),
  rows: (cell-size, cell-size, cell-size, cell-size, cell-size),
  align: center + horizon,
  ..content
)

== 1. 平行移動
目標とする移動量を $k$ としたとき、関数 $f_i(d, p)$ を以下のような区分関数として定義する。
$
  f_i(d, p) = cases(
    0 & (d = k text(" のとき")),
    +oo & (d != k text(" のとき"))
  )
$
変位が $k$ 以外の場所では到着時の値が $V(p) - oo = -oo$ （未定義）となり、集合から取り除かれる。正負の向きを持つ $k$ を指定することで、任意の方向への平行移動が表現される。

#align(center)[
  #grid(
    columns: 3,
    gutter: 2em,
    [
      *初期状態* \
      #grid-table(
        [],
        [],
        [],
        [],
        [],
        [],
        [1],
        [2],
        [3],
        [],
        [],
        [4],
        [5],
        [6],
        [],
        [],
        [7],
        [8],
        [9],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
    [
      *X方向へ $+1$ 移動* \
      #grid-table(
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [1],
        [2],
        [3],
        [],
        [],
        [4],
        [5],
        [6],
        [],
        [],
        [7],
        [8],
        [9],
        [],
        [],
        [],
        [],
        [],
      )
    ],
    [
      *Y方向へ $-1$ 移動* \
      #grid-table(
        [],
        [1],
        [2],
        [3],
        [],
        [],
        [4],
        [5],
        [6],
        [],
        [],
        [7],
        [8],
        [9],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
  )
]

== 2. 拡大
倍率を $s$ としたとき、起点のマスが $s$ 個のマスに複製されるよう、変位 $d$ と起点 $p$ を用いて関数を以下のように定義する。
$
  f_i(d, p) = cases(
    0 & (p(s-1) <= d < p(s-1) + s text(" のとき")),
    +oo & (text("それ以外"))
  )
$
この関数により、座標 $p$ にある値は $s p$ から $s p + s - 1$ までの範囲に複製され、値の入っているマスが増加する。

#align(center)[
  #grid(
    columns: 3,
    gutter: 2em,
    [
      *初期状態* \
      #grid-table(
        [1],
        [2],
        [],
        [],
        [],
        [3],
        [4],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
    [
      *X方向へ $2$ 倍拡大* \
      #grid-table(
        [1],
        [1],
        [2],
        [2],
        [],
        [3],
        [3],
        [4],
        [4],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
    [
      *Y方向へ $2$ 倍拡大* \
      #grid-table(
        [1],
        [2],
        [],
        [],
        [],
        [1],
        [2],
        [],
        [],
        [],
        [3],
        [4],
        [],
        [],
        [],
        [3],
        [4],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
  )
]

== 3. 値の伝播
変位 $d$ の絶対値に比例して値が減少する評価関数を定義する。初期値を $10$ とし、X方向とY方向の評価関数をそれぞれ以下のように定義する。
$
  f_X(d, p) = 2|d|, quad f_Y(d, p) = 1|d|
$

#align(center)[
  #grid(
    columns: 3,
    gutter: 2em,
    [
      *初期状態* \
      #grid-table(
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [*10*],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
    [
      *X方向へ伝播* \
      #grid-table(
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [6],
        [8],
        [*10*],
        [8],
        [6],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
      )
    ],
    [
      *Y方向へ伝播* \
      #grid-table(
        [4],
        [6],
        [8],
        [6],
        [4],
        [5],
        [7],
        [9],
        [7],
        [5],
        [6],
        [8],
        [*10*],
        [8],
        [6],
        [5],
        [7],
        [9],
        [7],
        [5],
        [4],
        [6],
        [8],
        [6],
        [4],
      )
    ],
  )
]

#pagebreak()

== 4. 値伝播と移動の複合操作
起点が複数存在し、値が衝突して $max$ 演算で集約される伝播操作と、図形の平行移動を組み合わせたよりケース。初期値を $6$ とし、以下の3つの操作を定義する。いずれも到達候補値が $0$ 以下の場合は空集合として扱う。

$
  & "X方向伝播 " (D_X): quad f_X(d, p) = 2|d| \
  & "Y方向伝播 " (D_Y): quad f_Y(d, p) = 2|d| \
  & "Y方向移動 " (M): quad f_M(d, p) = cases(0 & (d = +1 text(" のとき")), +oo & (text("それ以外")))
$

これら3つの異なる演算を適用する順番を変えて、「$D_X -> M -> D_Y$」「$M -> D_Y -> D_X$」「$D_Y -> D_X -> M$」の3通りのルートで実行した結果を示す。各ルートとも操作を1つ適用するごとに状態が遷移するため、初期状態と最終結果の間には中間状態が2個現れる。中間状態はルートごとに異なるが、最終結果は完全に一致する。

#let cell-sm = 1.45em
#let heat-max = 6
#let heat-gradient = gradient.linear(
  rgb("#1e5fb4"), // 低リスク（寒色）
  rgb("#3fc6c6"),
  rgb("#ffe066"),
  rgb("#ff8c00"),
  rgb("#d62828"), // 高リスク（暖色）
)
#let heat-t(v) = calc.min(1, calc.max(0, v / heat-max))
#let heat-fill(v) = if v == none { none } else { heat-gradient.sample(heat-t(v) * 100%) }
#let heat-text(v) = if v != none and heat-t(v) > 0.8 { white } else { black }
#let heat-cell(v) = {
  let bold = type(v) == array
  let val = if bold { v.at(0) } else { v }
  table.cell(fill: heat-fill(val))[
    #set text(fill: heat-text(val))
    #if val == none [] else if bold [*#val*] else [#val]
  ]
}
#let grid-sm(values) = table(
  columns: (cell-sm, cell-sm, cell-sm, cell-sm, cell-sm),
  rows: (cell-sm, cell-sm, cell-sm, cell-sm, cell-sm),
  align: center + horizon,
  ..values.map(heat-cell)
)
#let state-cell(title, values) = [
  *#title*（値のあるマス: #values.filter(v => v != none).len() 個） \
  #grid-sm(values)
]

#align(center)[
  #stack(
    dir: ltr,
    spacing: 0.6em,
    text(size: 8pt)[0],
    box(width: 6em, height: 0.8em, fill: heat-gradient, stroke: 0.5pt + black),
    text(size: 8pt)[6],
  )
]

#v(1em)
#align(center)[
  #grid(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: center + horizon,
    gutter: 0.8em,

    // ルート1
    state-cell("初期状態", (
      none, none, none, none, none,
      none, (6,), none, (6,), none,
      none, none, none, none, none,
      none, none, none, none, none,
      none, none, none, none, none,
    )),
    [$arrow(D_X)$ \ X伝播],
    state-cell("状態1", (
      none, none, none, none, none,
      4, 6, 4, 6, 4,
      none, none, none, none, none,
      none, none, none, none, none,
      none, none, none, none, none,
    )),
    [$arrow(M)$ \ Y移動],
    state-cell("状態2", (
      none, none, none, none, none,
      none, none, none, none, none,
      4, 6, 4, 6, 4,
      none, none, none, none, none,
      none, none, none, none, none,
    )),
    [$arrow(D_Y)$ \ Y伝播],
    state-cell("最終結果", (
      none, 2, none, 2, none,
      2, 4, 2, 4, 2,
      4, 6, 4, 6, 4,
      2, 4, 2, 4, 2,
      none, 2, none, 2, none,
    )),

    grid.cell(colspan: 7)[#v(1em)],
    // Spacer

    // ルート2
    state-cell("初期状態", (
      none, none, none, none, none,
      none, (6,), none, (6,), none,
      none, none, none, none, none,
      none, none, none, none, none,
      none, none, none, none, none,
    )),
    [$arrow(M)$ \ Y移動],
    state-cell("状態1", (
      none, none, none, none, none,
      none, none, none, none, none,
      none, (6,), none, (6,), none,
      none, none, none, none, none,
      none, none, none, none, none,
    )),
    [$arrow(D_Y)$ \ Y伝播],
    state-cell("状態2", (
      none, 2, none, 2, none,
      none, 4, none, 4, none,
      none, 6, none, 6, none,
      none, 4, none, 4, none,
      none, 2, none, 2, none,
    )),
    [$arrow(D_X)$ \ X伝播],
    state-cell("最終結果", (
      none, 2, none, 2, none,
      2, 4, 2, 4, 2,
      4, 6, 4, 6, 4,
      2, 4, 2, 4, 2,
      none, 2, none, 2, none,
    )),

    grid.cell(colspan: 7)[#v(1em)],
    // Spacer

    // ルート3
    state-cell("初期状態", (
      none, none, none, none, none,
      none, (6,), none, (6,), none,
      none, none, none, none, none,
      none, none, none, none, none,
      none, none, none, none, none,
    )),
    [$arrow(D_Y)$ \ Y伝播],
    state-cell("状態1", (
      none, 4, none, 4, none,
      none, 6, none, 6, none,
      none, 4, none, 4, none,
      none, 2, none, 2, none,
      none, none, none, none, none,
    )),
    [$arrow(D_X)$ \ X伝播],
    state-cell("状態2", (
      2, 4, 2, 4, 2,
      4, 6, 4, 6, 4,
      2, 4, 2, 4, 2,
      none, 2, none, 2, none,
      none, none, none, none, none,
    )),
    [$arrow(M)$ \ Y移動],
    state-cell("最終結果", (
      none, 2, none, 2, none,
      2, 4, 2, 4, 2,
      4, 6, 4, 6, 4,
      2, 4, 2, 4, 2,
      none, 2, none, 2, none,
    )),
  )
]

