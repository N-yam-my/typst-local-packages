#let theme(body) = { return [【#body】#h(1em)] }
#let note(fill : red, ..args, body) = {
  set text(fill : fill, ..args)
  body
}
#let question(body) = {
  return heading(level : 3, numbering : none, {
    box(width : 1.5em, fill : luma(60%), outset : (y : 0.25em), radius : 0.4em,
      text(fill : white)[#align(center)[_Q_#h(0.15em)]])
    box(width : 1fr, fill : luma(85%), inset : (x: 0.1em), outset : (y: 0.25em), radius : 0.4em,
      emph[#h(1em)#text(fill : luma(25%), body)])
  })
}
#let kihan = highlight.with(fill : yellow.mix(white))
#let youken = highlight.with(fill : green.mix(white))
#let strike = strike.with(stroke : red+0.125em)
