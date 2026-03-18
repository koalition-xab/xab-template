#import "@preview/showybox:2.0.4": showybox

#let default-config = (
  font: "Open Sans",
  margins: 1.5cm,
  radius: 4pt,
  font_sizes: (
    document_title: 25pt,
    document_subtitle: 20pt,
    text: 12pt,
  ),
)

#let header_seperator(colors) = {
  h(6pt)
  box(
    baseline: -0.8pt,
    rect(fill: colors.primary, radius: 1pt, height: 6.5pt, width: 6.5pt),
  )
  h(6pt)
}

#let header(subject, title, test_name, doc_version, logo_type, config) = [
  #rect(
    stroke: (left: config.margins + config.colors.primary),
    fill: config.colors.primary.lighten(80%),
    width: 100%,
    inset: config.margins,
  )[
    #grid(
      columns: (1fr, auto),
      [
        #text(title, size: config.font_sizes.document_title, weight: "bold")\
        #text(
          test_name,
          size: config.font_sizes.document_subtitle,
          weight: "bold",
        )
        #v(0.3cm)
        #sym.copyright XAB
        #header_seperator(config.colors)
        #datetime.today().display("[year]-[month]-[day]")
        #header_seperator(config.colors)
        #doc_version
      ],
      image(
        "logos/" + subject + "/XAB_" + logo_type + "_" + subject + ".svg",
        height: 3cm,
      ),
    )
  ]
]

#let xab-helper(
  subject,
  test_name,
  title: "HELPER",
  doc_version: "v1.0",
  logo_type: "FULL",
  config: default-config,
  body,
) = {
  let subject_colors = json("colors.json")
  let colors = (
    primary: rgb(subject_colors.at(subject)),
  )

  config.insert("colors", colors)

  // ------------------ BASIC STYLES ------------------

  set document(
    author: "Koalition-XAB",
    date: datetime.today(),
    title: test_name,
  )
  set text(font: config.font, lang: "de", size: config.font_sizes.text)
  show heading: set text(font: "Montserrat")
  set page(margin: 2cm, numbering: "1")
  set heading(numbering: "1.1")

  // ------------------ TABLE STYLES ------------------

  show table: t => {
    if (t.has("label") and t.label == <nostyle>) {
      return t
    }
    let fields = t.fields()
    if ("label" in fields.keys()) {
      let _ = fields.remove("label")
    }
    let chld = fields.remove("children")

    box(
      radius: config.radius,
      clip: true,
      stroke: 1pt,
    )[
      #table(
        ..fields,
        fill: (x, y) => {
          if (calc.odd(y)) {
            config.colors.primary.darken(60%).transparentize(90%)
          } else {
            rgb(0, 0, 0, 0)
          }
        },
        ..chld
      )<nostyle>
    ]
  }

  show <top-header>: t => {
    show table.cell.where(y: 0): h => {
      if (h.has("label") and h.label == <done>) {
        return h
      }
      let fields = h.fields()
      let body = fields.remove("body")
      if ("label" in fields.keys()) {
        let _ = fields.remove("label")
      }

      [#table.cell(..fields, [*#body*])<done>]
    }
    t
  }

  show <side-header>: t => {
    show table.cell.where(x: 0): h => {
      if (h.has("label") and h.label == <done>) {
        return h
      }
      let fields = h.fields()
      let body = fields.remove("body")
      if ("label" in fields.keys()) {
        let _ = fields.remove("label")
      }

      [#table.cell(..fields, [*#body*])<done>]
    }
    t
  }

  show <both-header>: t => {
    show table.cell.where(y: 0): h => {
      if (h.has("label") and h.label == <done>) {
        return h
      }
      let fields = h.fields()
      let body = fields.remove("body")
      if ("label" in fields.keys()) {
        let _ = fields.remove("label")
      }

      [#table.cell(..fields, [*#body*])<done>]
    }
    show table.cell.where(x: 0): h => {
      if (h.has("label") and h.label == <done>) {
        return h
      }
      let fields = h.fields()
      let body = fields.remove("body")
      if ("label" in fields.keys()) {
        let _ = fields.remove("label")
      }

      [#table.cell(..fields, [*#body*])<done>]
    }
    t
  }
  // ------------------ HEADER + BODY ------------------

  [
    #page(margin: 0pt)[
      #header(subject, title, test_name, doc_version, logo_type, config)
      #block(inset: (top: 1cm, rest: config.margins))[
        #outline(depth: 3)
      ]
    ]
    #counter(page).update(1)
    // Left bar
    #set page(background: {
      align(left)[
        #rect(fill: colors.primary, height: 100%, width: .5cm)
      ]
    })
    #body
    #pagebreak()
    = Haftungsausschluss
    Dieses Dokument wird unter Ausschluss jeglicher Gewährleistung zur Verfügung
    gestellt. Die Autoren übernehmen keine Haftung für die inhaltliche Richtigkeit,
    Vollständigkeit oder Aktualität der Informationen. Insbesondere wird keine
    Garantie für das Erreichen bestimmter Noten oder Prüfungsergebnisse übernommen.
    Die Nutzung der Inhalte erfolgt auf eigene Gefahr.

    = Spenden
    Aufgrund betrieblicher Organistaion werden zurzeit keine Spenden über digitale Wege
    entgegengenommen. Spenden werden daher nur über bares Geld angenommen.
  ]
}

// ------------------ COMPONENTS ------------------

#let info = showybox.with(title: "Info", frame: (
  body-color: blue.lighten(80%),
  title-color: blue.lighten(20%),
  border-color: blue.darken(40%),
))

#let example = showybox.with(
  title: "Beispiel",
  frame: (
    body-color: green.lighten(90%),
    title-color: green.darken(30%),
    border-color: green.darken(70%),
  ),
)

#let danger = showybox.with(
  title: "Achtung",
  frame: (
    body-color: orange.lighten(90%),
    title-color: orange.darken(30%),
    border-color: orange.darken(70%),
  ),
)
