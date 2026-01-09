// Assure default values without annoying explicit settings
#let assure-default(
  dict,
  key,
  value_default
) = {
  return if dict.keys().contains(key) {
    dict.remove(key)
  } else { value_default }
}
// Set up various default values for Japanese typesetting
#let covers-non-cjk = regex("[\u0000-\u2023]")
#let default-args(
  font-args : arguments(),
  text-args : arguments(),
  par-args : arguments(),
  block-args : arguments(),
  page-args : arguments(),
  kihon-hanmen : arguments(),
  non-cjk : covers-non-cjk,
) = {
  // default vaules for font-setting
  let fn = font-args.named()
  let f-init = (
    gothic : assure-default(fn, "gothic",
      (
        (name : "Noto Emoji", covers : regex("\p{EPres}")),
        (name : "New Computer Modern", covers : non-cjk),
        "BIZ UDPGothic",
      )
    ),
    math : assure-default(fn, "math",
      (
        // (name : "Noto Emoji", covers : regex("\p{EPres}")),
        (name : "New Computer Modern Math"),
        "BIZ UDPMincho",
      )
    )
  )
  // default values for <set text(...)>
  let tn = text-args.named()
  let t-init = (
    // As text fonts, you can configure them in both font-args and text-args.
    // If both configured, the former will be applied.
    font : assure-default(
      font-args.named(), "text",
      assure-default(
        tn, "font", (
        (name : "Noto Emoji", covers : regex("\p{EPres}")),
          (name : "New Computer Modern", covers : non-cjk),
          "BIZ UDPMincho",
        )
      )
    ),
    // fallback : assure-default(tn, "fallback", false),
    lang : assure-default(tn, "lang", "ja"),
    region : assure-default(tn, "region", "JP"),
    size : assure-default(tn, "size", 10pt),
    top-edge : assure-default(tn, "top-edge", 0.88em),
    bottom-edge : assure-default(tn, "bottom-edge", -0.12em),
    spacing : assure-default(tn, "spacing", 0%+0.25em)
  )
  // default values for <set par(...)>
  let prn = par-args.named()
  let pr-init = (
    leading : assure-default(prn, "leading", 0.7em),
    spacing : assure-default(prn, "spacing", 0.7em),
    justify : assure-default(prn, "justify", true),
    justification-limits : assure-default(
      prn,
      "justification-limits",
      (
        spacing: (min: 66.67%+0pt, max: 150%+0pt),
        tracking: (min: 0em, max: 0.25em)
      )
    ),
    first-line-indent : assure-default(
      prn,
      "first-line-indent",
      (amount : 1em, all : true)
    )
  )
  // default values for  <set block(...)>
  let bn = block-args.named()
  let b-init = (
    spacing : assure-default(bn, "spacing", 0.7em)
  )
  // default values for  <set page(...)>
  let pgn = page-args.named()
  let pg-init = (
    width : assure-default(pgn, "width", 210mm),
    height : assure-default(pgn, "height", 297mm),
  )
  // abbreviation
  let (w, h, s, l) = (
    // absolute length
    pg-init.at("width"),
    pg-init.at("height"),
    t-init.at("size"),
    // relative to font
    pr-init.at("leading")
  )
  // Compute default Kihon-hanmen; about 0.75 * <width, height>
  let (textwidth, lines-per-page) = (
    w * 0.75 / s, (h / s * 0.75 * 1em + l) / (1em + l)
  ).map(calc.round).map(int)// type => int
  let khn = kihon-hanmen.named()
  // Compute margins; kihon-hanmen > default
  let margins = (
    x : (w - s * assure-default(khn, "line-length", textwidth)) / 2,
    y : (h - ((assure-default(
      khn, "number-of-lines", lines-per-page
    ) * (1em + l)  - l) / 1em ) * s) / 2
  )
  // Add margin setting
  pg-init.insert("margin", assure-default(pgn, "margin", margins))
  return (
    font : f-init,
    text : t-init,
    par : pr-init,
    block : b-init,
    page : pg-init
  )
}
// Initializer for subfile
#let init-subfile(
  font-args : arguments(),
  text-args : arguments(),
  par-args : arguments(),
  block-args : arguments(),
  enable-chapter : false,
  body
) = {
  // Get initial values
  let args = default-args(
    font-args : font-args,
    text-args : text-args,
    par-args : par-args,
    block-args : block-args
  )
  // Apply settings about text
  set text(..args.at("text"), ..text-args)
  // Apply settings about paragraphs
  set par(..args.at("par"), ..par-args)
  // Apply settings about blocks
  set block(..args.at("block"), ..block-args)
  // Set fonts for bold weight and strong(...)
  show text.where(weight : "bold") : set text(
    font : args.at("font").at("gothic")
  )
  show strong : set text(font : args.at("font").at("gothic"))
  set box(baseline: 0.12em)
  // Footnote customize
  set footnote(numbering : "1)")
  show footnote: it => box(
    // baseline: 12%,
    // it
    context place(dx: - measure(it).width, dy: -1em,
      {
        set super(baseline: - measure(it).height)
        box(it)
      }
    )
  ) // (
  show footnote.entry: it => {
    let loc = it.note.location() //(
    set par(first-line-indent: 1em)
    numbering(// (
      "1)",
      ..counter(footnote).at(loc),
    )
    h(0.75em, weak : true)
    it.note.body
  }
  // settings appled in math
  show math.equation : set text(font :args.at("font").at("math"))

  // link
  show link: set text(fill: blue, font: "Moralerspace Argon HWNF")
  show link: underline

  // image (for .svg images)
  show image: set text(font: "BIZ UDPMincho")
  // settings about section
  // numbering
  set heading(numbering : "1.")
  // Let text in headings be bold
  show heading: set text(weight : "bold")
  // Set up level-1 headings
  let s = args.at("text").at("size")
  show heading: set block(
    height: s,
    spacing: 0.7 * s,
    // stroke: black
  )
  let round-in-point(size) = calc.round(size.pt()) * 1pt
  let r(size) = round-in-point(size)
  show heading.where(level : 1) : it => {
    if it.numbering == none { return block(it) }
    let pre-chapter = {
        let l = args.at("text").at("lang")
        if l == "ja" [
          #let global-numbering = it.numbering
          #let local-numbering = if type(global-numbering) == str {
            global-numbering.trim(".")
          } else { global-numbering }
          第#numbering(
            local-numbering, ..counter(heading).at(it.location())
          )章
        ] else [
          Chapter #numbering(
            it.numbering, ..counter(heading).at(it.location())
          )
        ]
    }
    set text(
      size: if enable-chapter { s * 2 } else { r(s * 4/3) }
    )
    if enable-chapter { block(height: (3 + 0.7 * 2) * s, {
        set par(leading: 0.4 * s)
        pre-chapter
        linebreak()
        h(1em) + it.body
      })
    } else { block(it) }
  }
  // Set up level-2 headings
  show heading.where(level: 2): it => {
    if enable-chapter {
      return block(
        text(size : r(s * 4/3))[#it])
    } else {
      return block(
        text(size : r(s * 7/6))[#it]
      )
    }
  }
  // Rules for lower level headings
  // show heading: set block(spacing : 0.7 * s)
  body
}
// Initializer for normal documents
#let init(
  title : none,
  titlefmt : x => block[#text(size : 22pt)[#x]],
  font-title : none,
  author : "",
  title-pagebreak : false,
  authorfmt : x => block[#text(size : 16pt)[#x]],
  page-args : arguments(),
  kihon-hanmen : arguments(),
  font-args : arguments(),
  text-args : arguments(),
  par-args : arguments(),
  block-args : arguments(),
  enable-chapter : false,
  before-title : none,
  body
) = {
  set document(title : title, author : author)
  let args = default-args(
    page-args : page-args,
    kihon-hanmen : kihon-hanmen,
    font-args : font-args,
    text-args : text-args,
    par-args : par-args,
    block-args : block-args
  )
  // Apply settings about page
  set page(
    ..args.at("page"), ..page-args
  )
  // Apply other settings
  show : init-subfile.with(
    font-args : font-args,
    text-args : text-args,
    par-args : par-args,
    block-args : block-args,
    enable-chapter : enable-chapter,
  )
  before-title
  // Set up title
  if title != none {
    // Display title and author
    let title-content = {
      let font = if font-title != none { font-title } else {
        args.at("text").at("font")
      }
      titlefmt(title)
      if author == "" { none } else {
        authorfmt(author)
      }
    }
    {
      set align(center)
      if title-pagebreak {
        v(1fr)
        title-content
        v(1fr)
        pagebreak()
      } else {
        title-content
      }
    }
  }
  body
}

#let init-kian(
  heading : arguments(
    date : "日付",
    year : "年度",
    subject : "科目",
    time : "時間"
  ),
  date : [`#date`],
  year : [`#year`],
  subject : [`#subject`],
  time : (00, 00),
  title : none,
  author : "",
  page-args : arguments(),
  kihon-hanmen : arguments(
    line-length : 36,
    number-of-lines : 23
  ),
  font-args : arguments(),
  text-args : arguments(
    size: 14pt,
    costs : (
      orphan : 0%,
      widow : 0%,
    ),
  ),
  par-args : arguments(
    leading : 1em,
    spacing : 1em
  ),
  block-args : arguments(
    spacing : 1em
  ),
  body
) = {
  let args = default-args(
    font-args : font-args,
    page-args : page-args,
    kihon-hanmen : kihon-hanmen,
    text-args : text-args,
    par-args : par-args
  )
  let margins = args.at("page").remove("margin")
  let (s, l) = (
    args.at("text").at("size"),
    args.at("par").at("leading")
  )
  let (t, b) = (
    margins.at("y") + 2 * (s + l),
    margins.at("y") - 2 * (s + l)
  )
  show : init.with(
    title : title,
    titlefmt : x => {},
    font-title : none,
    author : author,
    title-pagebreak : false,
    authorfmt : x => {},
    page-args : arguments(
      ..page-args,
      margin : (
        x : margins.at("x"),
        top : t, bottom : b
      ),
  ),
  kihon-hanmen : kihon-hanmen,
    font-args : font-args,
    text-args : text-args,
    par-args : par-args,
    block-args : block-args,
    enable-chapter : false,
    before-title : none
  )
  set page(
      background : [
      #{
      set raw(lang : "typst")
      set text(font : "BIZ UDPGothic")
      let c = counter("line-number")
      pad(
        top : 2*(s+l) - 0.5em,
        block(
          width : 37em,
          height : 25 * (s + l),
          {
            set align(center)
            set box(stroke : 1.5pt, height : s + l)
            stack(dir : ttb,
              stack(dir : ltr, 
                h(60%),
                box(width : 10%, strong(heading.at("date"))),
                box(width : 30%, date),
              ),
              stack(
              dir : ltr,
              box(width : 10%, strong(heading.at("year"))),
              box(width : 10%, year),
              box(width : 10%, strong(heading.at("subject"))),
              box(width : 30%, subject),
              box(width : 10%, strong(heading.at("time"))),
              box(width: 30%, inset : (x: 0.25em))[
                #sub[*構成*]#h(weak : true, 0em)
                #time.at(0)
                #h(weak : true, 0em)#sub[*分*]
                #h(1fr)
                #sub[*記述*]#h(weak : true, 0em)
                #time.at(1)
                #h(weak : true, 0em)#sub[*分*]
              ]),
              ..(
                stack(
                  dir : ltr,
                  box(stroke : none, width : 0%)[
                    #c.step()
                    #context {
                      let a = c.get().at(0)
                      if a == 1 or a == 23 or calc.gcd(a, 5) == 5 {
                        place(dx : -0.5em, dy : l, {
                          set text(8pt)
                          set align(right)
                          c.display()
                        })
                      }
                    }
                  ],
                  box(width : 100%, stroke : 1pt)
                ),
              ) * 23
            )
            c.update(0)
          }
        )
      )
    }
    ]
  )
  body
}
// Set up Part heading
#let Part(numbering : "I.", body) = {
  let c = counter("Part")
  context {
    if counter(page).get() != (1,) { pagebreak() }
  }
  c.step()
  counter(heading).update(0)
  let prePart = {
    context {
      let value-lang = text.lang
      if value-lang == "ja" [
        #let defaultNumbering = numbering
        #let localNumbering = if type(defaultNumbering) == str {
          defaultNumbering.trim(".")
        } else {defaultNumbering}
        第#c.display(localNumbering)部
      ] else [Part #c.display(numbering)]
  }}
  set align(center)
  set text(
    weight : "bold",
    size : 22pt,
  )
  [
    #v(1fr)
    #prePart \
    #body
    #v(1fr)
  ]
  pagebreak()
}
// Workarounds 
// if working out properly without this, don't load.
#let workarounds(
  body
) = {
  // math
  // automatic space between CJK character and inline-math;
  // by assuming latter as latin character
  show math.equation.where(block : false) : it => {
    context {
      let l = hide[a] + sym.wj + h(weak : false, - measure[a].width)
      let r = h(weak : false, - measure[a].width) + sym.wj + hide[a]
      return l + sym.wj + it + sym.wj + r
  }}
  // proportional fonts
  // currently typst seems not to be able to process CJK braces
  // and punctuations very well in proportional font.
  show regex("[\u3001-\u303F]"): it => {
    return h(0em, weak: true) + it + h(0em, weak: true)
  }
  show regex("[（「『［〔【]") : it => h(0em, weak : true) + it
  show regex("[）」』］〕】]") : it => it + h(0em, weak : true)
  show regex("[、。！？：；／・]") : it => it + h(0em, weak : true)
  body
}
