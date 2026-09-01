#set page(width: auto, height: auto, margin: 1cm, fill: white)
#set text(font: ("Noto Sans JP", "Yu Gothic", "BIZ UDPGothic", "MS Gothic"), size: 10.5pt)

#let n = 8
#let decay = 3
#let heat-max = 9
#let heat-gradient = gradient.linear(
  rgb("#3b4cc0"),
  rgb("#a9c6fd"),
  rgb("#f7f2ec"),
  rgb("#f4a582"),
  rgb("#b40426"),
)
#let heat-t(v) = calc.min(1, calc.max(0, v / heat-max))
#let heat-fill(v) = if v == none { none } else { heat-gradient.sample(heat-t(v) * 100%) }
#let heat-text(v) = if v != none and heat-t(v) > 0.8 { white } else { black }

#let pcell = 1.15em
#let num-cell(v) = table.cell(fill: heat-fill(v))[
  #set text(fill: heat-text(v), size: 7pt, weight: 900)
  #if v == none [] else [#v]
]
#let cutout-fill = rgb("#e3e3e3")
#let label-cell(occupied, label) = table.cell(fill: if occupied { cutout-fill } else { white })[
  #set text(size: 8pt, weight: "bold")
  #if label == none [] else [#label]
]
#let num-grid(values) = table(
  columns: (pcell,) * n,
  rows: (pcell,) * n,
  align: center + horizon,
  stroke: 0.5pt + black,
  ..values.map(num-cell)
)
// テーブル自身のセル境界線に依存すると、隣接セルとの線の太さが競合して
// 一部の辺が欠けたように見えるため、経路のマスは枠を独立した図形として上に重ねる
#let route-line = black
#let route-cell(v, on-path) = {
  let base = heat-fill(v)
  let fill = if base == none { none } else if on-path { base } else { base.transparentize(70%) }
  let text-color = if not on-path { luma(65%) } else { heat-text(v) }
  table.cell(fill: fill, inset: 0pt)[
    #if on-path [
      #place(top + left)[#rect(width: pcell, height: pcell, stroke: 2.2pt + route-line)]
    ]
    #set text(fill: text-color, size: 7pt, weight: 900)
    #if v == none [] else [#v]
  ]
}
#let route-grid(values, marks) = table(
  columns: (pcell,) * n,
  rows: (pcell,) * n,
  align: center + horizon,
  stroke: 0.5pt + black,
  ..range(n * n).map(i => route-cell(values.at(i), marks.at(i)))
)
#let label-grid(occ, lbl) = table(
  columns: (pcell,) * n,
  rows: (pcell,) * n,
  align: center + horizon,
  stroke: 0.5pt + black,
  ..range(n * n).map(i => label-cell(occ.at(i), lbl.at(i)))
)

// エンティティ = (占有セル配列, ラベル, リスク値)
#let manhattan(r1, c1, r2, c2) = calc.abs(r1 - r2) + calc.abs(c1 - c2)

#let cell-dist(r, c, cells) = calc.min(..cells.map(cell => manhattan(r, c, cell.at(0), cell.at(1))))

#let entity-field(entities, idx) = range(n).map(r => range(n).map(c => {
  let hit = entities.filter(e => e.at(0).any(cell => cell.at(0) == r and cell.at(1) == c))
  if hit.len() == 0 { none } else { hit.at(0).at(idx) }
})).flatten()

#let entity-occupied(entities) = range(n).map(r => range(n).map(c => {
  entities.any(e => e.at(0).any(cell => cell.at(0) == r and cell.at(1) == c))
})).flatten()

// つながったマスに同じラベルを繰り返さず、各エンティティの中央のマスにのみラベルを置く
#let entity-center-label(entities) = {
  let centers = entities.map(e => (e.at(0).at(calc.floor(e.at(0).len() / 2)), e.at(1)))
  range(n).map(r => range(n).map(c => {
    let hit = centers.filter(x => x.at(0).at(0) == r and x.at(0).at(1) == c)
    if hit.len() == 0 { none } else { hit.at(0).at(1) }
  })).flatten()
}

#let entity-buffer(entities) = range(n).map(r => range(n).map(c => {
  let candidates = entities.map(e => e.at(2) - decay * cell-dist(r, c, e.at(0)))
  let valid = candidates.filter(v => v > 0)
  if valid.len() == 0 { none } else { calc.max(..valid) }
})).flatten()

#let combine-max(grids) = range(n * n).map(i => {
  let vals = grids.map(g => g.at(i)).filter(v => v != none)
  if vals.len() == 0 { none } else { calc.max(..vals) }
})

// 道路データ: 幹線道路（横断）・細街路（縦断）が十字に交差
// ラベルは1マスに収まるよう省略形（凡例に正式名を記載）
#let road-entities = (
  (((3, 0), (3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7)), "幹", 7),
  (((0, 5), (1, 5), (2, 5), (3, 5), (4, 5), (5, 5), (6, 5), (7, 5)), "細", 3),
)

// 建物データ: 道路（3行目・5列目）を避けて配置。上側（0〜2行目）に加え
// 下側（5〜7行目）にも建物を増やし、航路探索が隙間を縫って通るようにする
#let building-entities = (
  (((0, 0), (0, 1)), "住", 4),
  (((2, 0),), "住", 4),
  (((0, 6), (0, 7)), "商", 6),
  (((1, 3), (2, 3)), "工", 7),
  (((2, 6), (2, 7)), "校", 9),
  (((5, 1), (5, 2)), "倉", 5),
  (((7, 3),), "住", 4),
  (((6, 6), (6, 7)), "病", 9),
)

// 予約済み飛行区域データ: 航路状に細長い。建物と同様に0〜2行目に収め、
// 5〜7行目には掛からないようにする
#let flight-entities = (
  (((1, 0), (1, 1), (1, 2), (0, 2), (0, 3), (0, 4), (1, 4)), "A", 9),
  (((1, 6), (1, 7)), "B", 5),
)

#let building-buffer = entity-buffer(building-entities)
#let road-buffer = entity-buffer(road-entities)
#let flight-buffer = entity-buffer(flight-entities)
#let merged = combine-max((building-buffer, road-buffer, flight-buffer))

// 対角の端から端（左下→右上）まで、建物・予約空域のリスクのみを障害物として
// ダイクストラ法で探索した最小コスト経路（道路データは回避対象に含めない）。
// 片方向だけに寄せず盤面全体を使うよう、始点・終点を対角のマスに設定している
#let obstacle = combine-max((building-buffer, flight-buffer))
#let path-cells = ((7, 0), (7, 1), (7, 2), (6, 2), (6, 3), (5, 3), (5, 4), (4, 4), (4, 5), (3, 5), (2, 5), (1, 5), (0, 5), (0, 6), (0, 7))
#let on-path = range(n).map(r => range(n).map(c => {
  path-cells.any(p => p.at(0) == r and p.at(1) == c)
})).flatten()

#let db-block = rect(
  fill: rgb("#6a8fc9"),
  inset: 0.8em,
  radius: 4pt,
)[
  #align(center + horizon)[
    #text(fill: white, weight: "bold", size: 10pt)[空間ID \ データベース]
  ]
]

#let arrow-r = align(center + horizon)[#text(size: 1.3em)[→]]
#let arrow-dr = align(center + horizon)[#text(size: 1.3em)[↘]]
#let arrow-ur = align(center + horizon)[#text(size: 1.3em)[↗]]
#let col-label(name) = align(center + top)[#text(size: 9pt)[#name]]
#let row-label(name) = align(center + horizon)[#text(size: 8pt, weight: "bold")[#name]]

#align(center)[
  #grid(
    columns: (6em, 5.5em, 2em, auto, 2em, auto, 2em, auto, 2em, auto, 2em, auto),
    rows: (auto, auto, auto, auto),
    column-gutter: 0.4em,
    row-gutter: 0.6em,
    align: center + horizon,

    // 行1: 建物データ
    grid.cell(rowspan: 3)[#db-block],
    row-label("建物データ"), arrow-r, label-grid(entity-occupied(building-entities), entity-center-label(building-entities)), arrow-r, num-grid(entity-field(building-entities, 2)), arrow-r, num-grid(building-buffer), arrow-dr, [], [], [],

    // 行2: 道路データ
    row-label("道路データ"), arrow-r, label-grid(entity-occupied(road-entities), entity-center-label(road-entities)), arrow-r, num-grid(entity-field(road-entities, 2)), arrow-r, num-grid(road-buffer), arrow-r, num-grid(merged), arrow-r, route-grid(merged, on-path),

    // 行3: 予約済み飛行区域データ
    row-label[予約済み \ 飛行区域データ], arrow-r, label-grid(entity-occupied(flight-entities), entity-center-label(flight-entities)), arrow-r, num-grid(entity-field(flight-entities, 2)), arrow-r, num-grid(flight-buffer), arrow-ur, [], [], [],

    // 列ラベル行
    [], [], [],
    col-label("切り出し"), [],
    col-label("値の数値化"), [],
    col-label("バッファ確保"), [],
    col-label("合成"), [],
    col-label[航路探索 \ (左下→右上、建物・予約空域を回避)],
  )
]

#v(0.8em)
#align(center)[
  #stack(
    dir: ltr,
    spacing: 0.6em,
    text(size: 8pt)[0],
    box(width: 6em, height: 0.7em, fill: heat-gradient, stroke: 0.5pt + black),
    text(size: 8pt)[9],
  )
]
#align(center)[
  #text(size: 8pt)[
    切り出し段階のラベル: 住=住宅(4)、商=商業(6)、工=工場(7)、校=学校(9)、倉=倉庫(5)、病=病院(9)、幹=幹線道路(7)、細=細街路(3)、A=予約区域A(9)、B=予約区域B(5) \
    バッファ減衰: マンハッタン距離1につき#decay、合成: 最大値（$max$） \
    航路探索: 左下端から右上端まで、建物・予約空域のリスクのみを障害物としてダイクストラ法で最小コスト経路を探索（経路以外のマスは薄く表示、道路データは回避対象外）
  ]
]
