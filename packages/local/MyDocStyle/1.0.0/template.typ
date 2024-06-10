// define states at beginning
#let stateHeading = state("isJapanese", false)
#let stateGothicFont = state("GothicFont", ("", ""))

// Set up title
#let title(
  title : "Title",
  titlefmt : x => text(size : 22pt)[#x],
  author : "Author",
  authorfmt : x => text(size : 16pt)[#x],
  titlepage : false,
  ..pageargs,
  title-font : (
  "New Computer Modern",
  "BIZ UDPMincho",
  ),
  body,
) ={
  set document(title : title, author : author)
  set page(
    ..pageargs.named()
  )
  show footnote.entry : it => {
    set text(font : title-font)
    it
  }
  // Display title and author
  let title-content = {
    set text(font : title-font, size : 12pt)
    block(titlefmt(title))
    if author == "" { none } else {
      block(authorfmt(author))
    }
  }
  {
    set align(center)
    if titlepage {
      v(1fr)
      title-content
      v(1fr)
      pagebreak()
    } else {
      title-content
    }
  }
  body
}

// declare document config
#let config(
  textFont : (
    "New Computer Modern",
    "BIZ UDPMincho"
  ),
  gothicFont : (
    "New Computer Modern",
    "BIZ UDPGothic"
  ),
  mathFont : (
    "New Computer Modern Math",
    "BIZ UDPMincho"
  ),
  enableChapter : false,
  isJapanese : true,
  body,
) = {
  // update states
  state("isJapanese").update(isJapanese)
  state("GothicFont").update(gothicFont)

  let lang = if isJapanese {"ja"} else {"en"}
  set text(
    font : textFont,
    size : 12pt,
    lang : lang,
    // spacing : 0.25em
  )
  show footnote.entry : it => {
    set text(font : title-font)
    it
  }
  show math.equation : set text(font: mathFont)
  // Set proper (?) spaces between CJK characters and inline-math.
  show math.equation.where(block : false) : it => {
    // let loc = it.location()
    h(0.25em, weak: true) + it + h(0.25em, weak: true)
    // regex("[\p{scx:Han}\p{scx:Hira}\p{scx:Kana}]")
  }
  // Set pargraph settings
  set align(left)
  set par(leading : 0.65em, first-line-indent : 1em, justify : true)
  set block(above : 0.65em, below : 0.65em)
  show par : set block(spacing : 0.65em)
  // Set font for strong
  show strong : set text(font : gothicFont)
  // Set font for specific weight => not working now…
  // show text.where(weight : "bold") : set text(font : gothicFont)
  // Set heading text settings
  show heading : set text(weight : "bold", font : gothicFont)
  show "「" : [ 「]
  show "」" : [」 ]
  // Set section numbering
  set heading(numbering : "1.")
  // Set up level-1 Heading
    show heading.where(level : 1) : it => {
      set block(above: 1.5em, below:1em)
      let preChapter = {
        locate(loc => {
          if it.numbering == none []
          else if state("isJapanese").at(loc) [
            #let GlobalNumbering = it.numbering
            #let localNumbering = if type(GlobalNumbering) == str {
              // Why is this going well?
              GlobalNumbering.trim(".")
            } else {GlobalNumbering}
            第#numbering(localNumbering, ..counter(heading).at(it.location()))章 \
          ] else [
            Chapter #numbering(it.numbering, ..counter(heading).at(it.location())) \
          ]
        })
      }
      if enableChapter { return locate(loc => {
        set text(
          font : state("GothicFont").at(loc),
          weight : "bold",
          size : 20pt,
        )
        block({
          preChapter
          h(0.5em)
          it.body
        })
      })} else { return block(text(size : 16pt)[#it]) }
    }
  // Set up level-2 Heading
  show heading.where(level: 2): it => {
    let aboveSpace = if enableChapter {1.5em} else {1em}
    let belowSpace = 0.5em
    set block(above: aboveSpace, below: belowSpace)
    if enableChapter {
      return block(text(size : 16pt)[#it])
    } else {
      return block(text(size :14pt)[#it])
    }
  }
  // Rules for lower headings
  show heading: it => {
    set text(size : 14pt)
    set block(above: 1em, below: 0.5em)
    it
  }
  body
}

// Set up Part heading
#let Part(numbering : "I.", body) = {
  let c = counter("Part")
  pagebreak()
  c.step()
  counter(heading).update(0)
  let prePart = {
    locate(
      loc => {
        if state("isJapanese").at(loc) [
          #let defaultNumbering = numbering
          #let localNumbering = if type(defaultNumbering) == str {
            defaultNumbering.trim(".")
          } else {defaultNumbering}
          第#c.display(localNumbering)部
        ] else [Part #c.display(numbering)]
  })}
  set align(center)
  locate(loc => {
    set text(
      font : state("GothicFont").at(loc),
      weight : "bold",
      size : 22pt,
    )
    [
      #v(1fr)
      #prePart \
      #body
      #v(1fr)
    ]
  })
  pagebreak()
}
