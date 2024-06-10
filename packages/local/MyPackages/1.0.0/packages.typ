#import "@preview/diverential:0.2.0": *
#import "@preview/drafting:0.2.0" : *
#import "@preview/fletcher:0.4.3" as fletcher: diagram, node, edge
#import "@preview/i-figured:0.2.4"
#import "@preview/rubby:0.10.1": get-ruby
#let ruby = get-ruby(
  size: 0.5em,         // Ruby font size
  dy: 0pt,             // Vertical offset of the ruby
  pos: top,            // Ruby position (top or bottom)
  alignment: "center", // Ruby alignment ("center", "start", "between", "around")
  delimiter: "|",      // The delimiter between words
  auto-spacing: true,  // Automatically add necessary space around words
)
#import "@preview/metro:0.2.0" : *
#import "@preview/whalogen:0.1.0": ce
#import "@preview/ctheorems:1.1.2": *

#let theoremName(
  modify : false,
  dict : (
    "definition" : "定義",
    "axiom" : "公理",
    "theorem" : "定理",
    "lemma" : "補題",
    "corollary" : "系",
    "example" : "例",
    "proof" : "証明",
    "caution" : "注意",
    "exercise" : "問題",
    "hypothesis" : "仮説",
    "rule" : "規則",
    "hanrei" : "判例",
    "case" : "事例",
    "point" : "ポイント",
  ),
) = {
  let defaultDict = (
    "definition" : "Definition",
    "axiom" : "Axiom",
    "theorem" : "Theorem",
    "lemma" : "Lemma",
    "corollary" : "Corollary",
    "example" : "Example",
    "proof" : "Proof",
    "caution" : "Caution",
    "exercise" : "Exercise",
    "hypothesis" : "Hypothesis",
    "rule" : "Rule",
    "hanrei" : "Judicial Decision",
    "case" : "Case",
    "point" : "Point",
  )
  return if not modify { defaultDict } else { dict }
}
#let thmDict = theoremName(modify: true)
#let myTheoremBase(
  identifier : "definition",
  name : thmDict.definition,
  level : 1,
  nameFormat : x => [(#x)],
  titleFormat : strong,
  color : luma(86%),
  inset : (x : 1.2em, y : 0.65em),
  radius : 0pt,
  stroke : ("left" : ("thickness" : 0.5em, "paint" : luma(50%)),),
  ..args,
) = thmplain(
  identifier,
  name,
  base_level : level,
  namefmt : nameFormat,
  titlefmt : titleFormat,
  fill : color,
  inset : inset,
  radius : radius,
  stroke : stroke,
  ..args,
)
#let definition = myTheoremBase()
#let axiom = myTheoremBase(name : thmDict.axiom, color : luma(88%))
#let rule = myTheoremBase(
  identifier : "rule",
  name : thmDict.rule,
  color : luma(88%),
).with(numbering : none)
#let hanrei = myTheoremBase(
  identifier : "hanrei",
  titlefmt : x => box(
    fill : olive.mix(white),
    inset : (x : 0.5em),
    outset : (y : 0.3em),
    radius : 6pt,
    {
      strong(text(font : "Moralerspace Krypton HWNF", x))
    }
  ),
  name : thmDict.hanrei,
  namefmt : x => underline(
    stroke : (
      paint : color.mix((white, 66%), (olive, 34%)),
      thickness : 0.4em,
      cap : "round",
    ),
    extent : 0em,
    background : true,
    {
      set text(font : ("New Computer Modern", "Kaisei Tokumin"))
      show strong: set text(font : "Kaisei Tokumin")
      x
    }
  ),
  color : color.mix((olive, 15%), (white, 85%)),
  stroke : ("left" : ("thickness" : 0.5em, "paint" : olive.mix(white))),
  radius : 3pt,
  separator : { linebreak() }
)
#let theorem = myTheoremBase(name : thmDict.theorem, color : luma(90%))
#let lemma = myTheoremBase(name : thmDict.lemma, color : luma(92%))
#let corollary = myTheoremBase(name : thmDict.corollary, color : luma(94%))
#let hypothesis = myTheoremBase(
  identifier : "hypothesis",
  name : thmDict.hypothesis,
  color : luma(95%),
  radius : 3pt,
).with(numbering : none)
#let case = myTheoremBase(
  identifier : "case",
  titlefmt : x => box(
    fill : eastern.mix(white),
    inset : (x : 0.5em),
    outset : (y : 0.3em),
    radius : 6pt,
    {
      strong(text(font : "Moralerspace Krypton HWNF", x))
    }
  ),
  name : thmDict.case,
  color : color.mix((eastern, 15%), (white, 85%)),
  stroke : ("left" : ("thickness" : 0.5em, "paint" : eastern.mix(white))),
  radius : 3pt,
  separator : { h(0.25em)}
)

#let point = myTheoremBase(
  identifier : "point",
  name : "Point",
  titlefmt : x => box(
    fill : orange,
    inset : (x : 0.5em),
    outset : (y : 0.3em),
    radius : 6pt,
    {
      strong(text(font : "Moralerspace Krypton HWNF", x))
    }
  ),
  namefmt : x => underline(
    stroke : (
      paint : color.mix((white, 66%), (orange, 34%)),
      thickness : 0.4em,
      cap : "round",
    ),
    extent : 0em,
    background : true,
    {
      set text(font : ("New Computer Modern", "Kaisei Tokumin"))
      show strong: set text(font : "Kaisei Tokumin")
      x
    }
  ),
  separator : parbreak(),
  level : 0,
  color : color.mix((orange, 15%), (white, 85%)),
  stroke : ("left" : ("thickness" : 0.5em, "paint" : orange.mix(white))),
  radius : 3pt,
)
#let exercise = myTheoremBase(
  identifier : "exercise",
  name : thmDict.exercise,
  color : luma(96%),
  stroke : 0.1em+luma(50%),
  radius : 3pt,
)

#let example = thmplain(
  "example",
  thmDict.example,
  inset : (x : 1.2em, bottom : 0.6em),
).with(numbering : none)
#let caution = thmplain(
  "caution",
  thmDict.caution,
  titlefmt : strong,
  inset : (x : 1.2em, bottom : 0.6em),
).with(numbering :none)
#let proof = thmproof(
  "proof",
  thmDict.proof,
  namefmt : if thmDict.proof == "Proof" {name => emph([#name])} else {name => [#name]},
  inset : (x : 1.2em, bottom : 0.6em),
)

#let packageConfig(
  qed-symbol : $square$,
  showEqArgs : (
    level : 1,
    zero-fill : false,
    leading-zero : false,
    numbering : "(1.1)",
    prefix : "eq:",
    only-labeled : true,
    unnumbered-label : "-"
    ),
  body,
) = {
  // Set up the Q.E.D. symbol for proof env.
  show : thmrules.with(qed-symbol: qed-symbol)
  // Show equation numbering only if has("label") or not labeled with <->.
  show math.equation : it => {i-figured.show-equation(it, ..showEqArgs)}
  // Set up supplement for reference.
  set math.equation(supplement : [式])
  body
}
