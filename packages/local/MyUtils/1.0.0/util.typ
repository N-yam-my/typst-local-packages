#let kinto(body) = {
  body = if body.has("text") { body.text }
  if type(body) != str { return none }
  h(1fr, weak: true)
  for c in body.clusters() {
    c
    h(1fr, weak: true)
  }
}
// Set up BOX function for in-paragraph blocks such as enum, eq.
#let BOX(body) = {
  linebreak()
  box(width: 100%, body)
}

#let theme(spacing : 1em, no-indent : false, body) = {
  let c = [【#body】]
  if no-indent {
    return [
      #set par(first-line-indent: 0em)
      【#body】#h(spacing)
    ]
  } else {
    return [
      【#body】#h(spacing)
    ]
}}
#let note(fill : red, ..args, body) = {
  set text(fill : fill, ..args)
  body
}
// #let question(body) = {
//   return heading(level : 3, numbering : none, {
//     box(width : 1.5em, fill : luma(60%), outset : (y : 0.25em), radius : 0.4em,
//       text(fill : white)[#align(center)[_Q_#h(0.15em)]])
//     box(width : 1fr, fill : luma(85%), inset : (x: 0.1em), outset : (y: 0.25em), radius : 0.4em,
//       emph[#h(1em)#text(fill : luma(25%), body)])
//   })
// }
// #let kihan = highlight.with(fill : yellow.mix(white))
#let Concl = highlight.with(fill : yellow.mix(white))
#let Eval = highlight.with(
  stroke : (
    x : none,
    y : 0.25em+yellow.mix(white)
  ),
  top-edge : "baseline",
  bottom-edge : "descender",
  fill : yellow.mix(white)
)
// #let youken = highlight.with(fill : green.mix(white))
#let Elem = highlight.with(fill : green.mix(white))
#let Fact = highlight.with(
  stroke : (
    x : none,
    y : 0.25em+green.mix(white)
  ),
  top-edge : "baseline",
  bottom-edge : "descender",
  fill : green.mix(white)
)
#let strike = strike.with(stroke : red+0.125em)

#let Splitted(
  count : 2,
  gutter : 1em,
  stroke : (dash : "dashed"),
  ..body
) = pad(
    left : - gutter/2, 
    grid(
      columns : (1fr, ) * count,
      rows : 1,
      gutter : gutter/2,
      inset : (left : gutter/2),
      stroke : (x, _) => {
        if x > 0 {
          (left : stroke)
        }
      },
    ..body
))

#let my-columns(
  count : 2,
  gutter : 1em,
  stroke : 1pt+black,
  height,
  body
) = context {
  block(
  height : 1em * height + par.leading * (height - 1),
  columns(
    count,
    gutter : gutter,
    {
      place(
        dx : 100%+ gutter/2,
        line(
          end : (0%, 100% + par.leading * 0.25),
          stroke: stroke
      ))
      set text(costs : (orphan : 0%, widow : 0%))
      box(height : 0em)
      v(-0.7em)
      parbreak()
      body
    }
  )
)
}
// }
#{
let _ = state("size-and-font", none)
let _ = counter("kian")
}
#let kian(
  numbering : (..nums) => {
    let d = nums.pos().len() - 1
    let rule = ("第1.", "1.", "(1).", "ア.", "(ア).")
    return numbering(rule.at(d - 1), nums.pos().at(d))
  },
  heading-width : 3em,
  offset : 0,
  body
) = {
  let t = state("size-and-font")
  let c = counter("kian")
  context {
    t.update((size: text.size, font : "BIZ UDPMincho"))
  }
  c.update(())
  {
    set heading(
      numbering : none,
      offset : offset,
      outlined : false,
      bookmarked : false
    )
    show heading : it => {
      if it.level > 5 { return none }
      set text(
        ..t.get(),
        weight : "regular"
      )
      parbreak()
      box(
        width : heading-width,
        baseline : 0.12em,
        // stroke : 1pt,
        [
          #c.step(level : it.level)
          #set align(right)
          #context underline(
            stroke: 0.05em,
            numbering(
              numbering,
              ..c.get()
          ))
          #h(0.5em)
      ])
      h(1em)
      [#it.body]
      if it.level == 1 or it.body != [] {
        parbreak()
      } else { h(weak : true, 1em) }
    }
    [#body]
  }
  c.update(())
}

#let fmt-jd(
  prefix : "最判",
  is-big : false,
  number : 0,
  name : "民集",
  date,
  publish
) = {
  let p = (prefix.first(), prefix.last())
  let m = if is-big { "大" } else if number > 0 {
    numbering("(一)", number)
  } else { none }
  let (td, tp) = (date, publish).map(type)
  assert(
    td == array or td == str,
    message : "Formatter Error : type of [date] must be array or string."
  )
  // assert(
  //   date.len() == 4,
  //   message : "Formatter Error : length of [date] must be 4."
  // )
  assert(
    date.at(0) in ("m", "M", "t", "T", "s", "S", "h", "H", "r", "R"),
    message : "Formatter Error : the first item of [date] must be in {m, t, s, h, r} or uppercases of them."
  )
  assert(
    tp == array or  tp == str,
    message : "Formatter Error : type of [publish] must be array or string."
  )
  let date = if td == array { date }
    else if td == str { date.split(regex("[ .-]")) }
  let publish = if tp == array { publish }
    else if tp == str { publish.split(regex("[ .-]")) }
  let nengo = lower(date.remove(0))
  let dict-nengo = (
    m : "明治", t : "大正", s : "昭和", h : "平成", r : "令和",
  )
  let n = dict-nengo.at(nengo)
  let d = date.map(str).join(".")
  let pub = publish.map(str).join("-")
  let pfix = if prefix.clusters().len() == 2 { p.at(0) + m + p.at(1) } else {
      prefix
  }
  return pfix + n + d +  name + pub
}

#let pros(
  pro-marker : (emoji.snowman, emoji.icecream.shaved, emoji.ice),
  // pro-marker : (emoji.penguin,),
  body
) = [
  #set list(marker : (..pro-marker))
  #body
]
#let cons(
  con-marker : (emoji.fire, emoji.namebadge, emoji.explosion),
  // con-marker : (emoji.namebadge,),
  body
) = [
  #set list(marker : (..con-marker))
  #body
]

// Define abbreviations for easy-typing.
#let ulim = math.op([$overline(lim)$], limits : true)
#let llim = math.op([$underline(lim)$], limits : true)
#let phm(relative : 0em) = h(relative)
// [
#let interval(a, b) = [$(#a, #b]$] //)
