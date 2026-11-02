// Renders resume.yaml (JSON Resume format) to PDF.
// Build from the repository root: npm run pdf

#let data = yaml("/resume.yaml")
#let basics = data.basics

#let accent = rgb("#1d4ed8")
#let muted = luma(90)
#let rule = luma(200)

#let get(dict, key) = {
  let value = dict.at(key, default: none)
  if value == "" { none } else { value }
}

#let format-date(date) = {
  if date == none { return "Present" }
  let parts = str(date).split("-").map(int)
  datetime(year: parts.at(0), month: parts.at(1, default: 1), day: 1).display("[month repr:short] [year]")
}

#let year(date) = if date == none { "Present" } else { str(date).slice(0, 4) }

#let bare-url(url) = url.replace(regex("^https?://(www\.)?"), "").trim("/")

// Highlights wrapped in parentheses list the technologies used in a role.
#let is-tech(h) = h.starts-with("(") and h.ends-with(")")

// Consecutive roles at the same company are shown under a single heading.
#let employers = {
  let groups = ()
  for role in data.work {
    if groups.len() > 0 and groups.last().name == role.name {
      groups.at(-1).roles.push(role)
    } else {
      groups.push((name: role.name, url: get(role, "url"), location: get(role, "location"), roles: (role,)))
    }
  }
  groups
}

#set document(title: basics.name + " – Résumé", author: basics.name)
#set text(font: "Libertinus Serif", size: 10pt, lang: "en")
#set par(leading: 0.6em)
#set list(indent: 0.4em, body-indent: 0.6em, spacing: 0.35em, marker: text(fill: muted)[•])
#set page(
  paper: "a4",
  margin: (x: 1.7cm, top: 1.4cm, bottom: 1.6cm),
  footer: context {
    set text(8pt, fill: muted)
    basics.name
    h(1fr)
    counter(page).display("1 / 1", both: true)
  },
)

#show link: set text(fill: accent)

#show heading.where(level: 1): it => block(above: 1.2em, below: 0.6em, sticky: true)[
  #set text(9pt, weight: "bold", tracking: 0.08em, fill: accent)
  #upper(it.body)
  #v(-0.6em)
  #line(length: 100%, stroke: 0.5pt + rule)
]

#let entry(title, dates, body: none) = block(breakable: false, above: 0.75em)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    strong(title), text(fill: muted, dates),
  )
  #if body != none { body }
]

// Header

#text(24pt, weight: "bold", basics.name)
#v(-0.4em)
#text(13pt, fill: muted, basics.label)

#{
  let contacts = ()
  if get(basics, "email") != none { contacts.push(link("mailto:" + basics.email, basics.email)) }
  if get(basics, "phone") != none { contacts.push(link("tel:" + basics.phone.replace(" ", ""), basics.phone)) }
  if get(basics, "url") != none { contacts.push(link(basics.url, bare-url(basics.url))) }
  for p in basics.at("profiles", default: ()) { contacts.push(link(p.url, bare-url(p.url))) }
  if basics.at("location", default: none) != none { contacts.push(basics.location.region) }
  text(9.5pt, contacts.join(h(0.5em) + text(fill: rule, "|") + h(0.5em)))
}

#if get(basics, "summary") != none [
  #v(0.4em)
  #emph(basics.summary)
]

// Sections

= Experience

#for employer in employers [
  #block(above: 1.1em, below: 0.2em, sticky: true)[
    #text(11.5pt, weight: "bold", if employer.url != none { link(employer.url, text(fill: black, employer.name)) } else { employer.name })
    #if employer.location != none { text(fill: muted, [ · #employer.location]) }
  ]
  #for role in employer.roles {
    let highlights = role.at("highlights", default: ())
    let items = highlights.filter(h => not is-tech(h))
    let tech = highlights.filter(is-tech).map(h => h.slice(1, -1))
    entry(
      role.position,
      format-date(role.startDate) + " – " + format-date(get(role, "endDate")),
      body: [
        #if get(role, "summary") != none { par(role.summary) }
        #if items.len() > 0 { list(..items) }
        #if tech.len() > 0 { text(9pt, fill: muted, emph(tech.join(", "))) }
      ],
    )
  }
]

#let projects = data.at("projects", default: ())
#if projects.len() > 0 [
  = Projects

  #list(
    ..projects.map(p => {
      let title = if get(p, "url") != none { link(p.url, p.name) } else { strong(p.name) }
      if get(p, "summary") != none [#title \ #text(9pt, fill: muted, p.summary)] else { title }
    }),
  )
]

#let skills = data.at("skills", default: ())
#if skills.len() > 0 [
  = Skills

  #skills.map(s => if get(s, "level") != none [*#s.name* #text(fill: muted)[(#s.level)]] else [*#s.name*]).join(h(0.4em) + text(fill: rule, "·") + h(0.4em))
]

#let education = data.at("education", default: ())
#if education.len() > 0 [
  = Education

  #for e in education {
    entry(
      e.studyType,
      year(e.startDate) + " – " + year(get(e, "endDate")),
      body: if get(e, "url") != none { link(e.url, e.institution) } else { e.institution },
    )
  }
]

#let languages = data.at("languages", default: ())
#let interests = data.at("interests", default: ())
#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  if languages.len() > 0 [
    = Languages

    #languages.map(l => [#l.language #text(fill: muted)[(#l.fluency)]]).join(linebreak())
  ],
  if interests.len() > 0 [
    = Interests

    #interests.map(i => i.name).join(", ")
  ],
)
