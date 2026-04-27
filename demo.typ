#import "template.typ": *

#show: xab-helper.with(
  "SEW",
  "Template Feature Demo",
  title: "HELPER",
  doc_version: "v1.0",
  logo_type: "FULL",
)

= Text & Typographie

Normaler Fließtext mit *fettem*, _kursivem_ und `monospace` Text. Links werden automatisch formatiert: #link("https://example.com")[Beispiel-Link].

== Absätze

Dieser Absatz zeigt Blocksatz. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.

Zweiter Absatz mit mehr Text. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.

= Listen

== Ungeordnete Liste

- Erster Eintrag
- Zweiter Eintrag
  - Untergeordneter Eintrag
  - Noch ein Untereintrag
- Dritter Eintrag

== Geordnete Liste

+ Erster Schritt
+ Zweiter Schritt
  + Teilschritt A
  + Teilschritt B
+ Dritter Schritt

== Begriffsliste (Terms)

/ Begriff 1: Erklärung des ersten Begriffs mit ausführlicher Beschreibung.
/ Begriff 2: Erklärung des zweiten Begriffs.
/ Polymorphismus: Die Fähigkeit, Objekte verschiedener Klassen durch eine gemeinsame Schnittstelle anzusprechen.

= Mathematik

Inline-Gleichung: $E = m c^2$ und $a^2 + b^2 = c^2$.

Block-Gleichung:

$ integral_0^1 x^2 dif x = 1/3 $

$ sum_(i=1)^n i = (n(n+1))/2 $

$ f(x) = cases(
  x^2 & "wenn" x >= 0,
  -x^2 & "wenn" x < 0
) $

= Tabellen

== Einfache Tabelle

#table(
  columns: (auto, 1fr, auto),
  [Name], [Beschreibung], [Wert],
  [Alpha], [Erster Parameter], [1.0],
  [Beta], [Zweiter Parameter], [2.5],
  [Gamma], [Dritter Parameter], [0.7],
  [Delta], [Vierter Parameter], [3.2],
)

== Tabelle mit Top-Header

#table(
  columns: (auto, 1fr, auto, auto),
  [Fach], [Thema], [Note], [ECTS],
  [SEW], [OOP Grundlagen], [1], [3],
  [INSY], [Datenbankdesign], [2], [2],
  [AM], [Analysis], [1], [4],
  [PHYSIK], [Mechanik], [3], [3],
)<top-header>

== Tabelle mit Side-Header

#table(
  columns: (auto, 1fr, 1fr),
  [Eigenschaft], [Klasse A], [Klasse B],
  [Vererbung], [Einfach], [Mehrfach],
  [Zugriffsmod.], [public/private], [public/protected],
  [Abstrakt], [Nein], [Ja],
)<side-header>

== Tabelle mit Both-Header

#table(
  columns: (auto, auto, auto, auto),
  [], [Montag], [Mittwoch], [Freitag],
  [08:00], [SEW], [INSY], [AM],
  [10:00], [PHYSIK], [DEUTSCH], [SEW],
  [13:00], [GGP], [ENGLISCH], [INSY],
)<both-header>

= Hinweisboxen

#info[
  Dies ist eine Info-Box. Hier können wichtige Informationen hervorgehoben werden. Sie eignet sich gut für Hintergrundinformationen oder weiterführende Hinweise.
]

#example[
  Dies ist eine Beispiel-Box. Hier werden konkrete Beispiele dargestellt.

  ```java
  public class HelloWorld {
    public static void main(String[] args) {
      System.out.println("Hello, World!");
    }
  }
  ```
]

#danger[
  Dies ist eine Achtungs-Box. Hier werden Warnungen und wichtige Hinweise angezeigt, die besondere Aufmerksamkeit erfordern.
]

= Code

Inline-Code: `int x = 42;` im Fließtext.

Code-Block:

```python
def fibonacci(n: int) -> int:
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

for i in range(10):
    print(fibonacci(i))
```

```sql
SELECT u.name, COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.active = TRUE
GROUP BY u.id
ORDER BY order_count DESC;
```

= Kombinierte Beispiele

== Info mit Mathematik

#info[
  Die Ableitung von $f(x) = x^n$ ist $f'(x) = n x^(n-1)$.

  Für die Kettenregel gilt: $(f(g(x)))' = f'(g(x)) dot g'(x)$
]

== Beispiel mit Tabelle und Liste

#example[
  Vergleich der Sortieralgorithmen:

  #table(
    columns: (auto, auto, auto, auto),
    [Algorithmus], [Best], [Average], [Worst],
    [Bubble Sort], [$O(n)$], [$O(n^2)$], [$O(n^2)$],
    [Merge Sort], [$O(n log n)$], [$O(n log n)$], [$O(n log n)$],
    [Quick Sort], [$O(n log n)$], [$O(n log n)$], [$O(n^2)$],
  )<top-header>

  Empfehlung nach Anwendungsfall:
  - Kleine Datensätze: Bubble Sort (einfach zu implementieren)
  - Große Datensätze: Merge Sort (garantiertes $O(n log n)$)
  - Durchschnittlich: Quick Sort (gute Cache-Performance)
]

== Achtung mit Begriffen

#danger[
  Verwechslungsgefahr bei folgenden Begriffen:

  / Stack Overflow: Zu tiefe Rekursion oder zu viele lokale Variablen auf dem Call-Stack.
  / Heap Overflow: Schreiben außerhalb des allokierten Speicherbereichs auf dem Heap.
  / Buffer Overflow: Überschreiben von Speicherbereichen durch zu große Eingaben.
]
