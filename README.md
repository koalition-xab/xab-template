# Helper Template

Typst template package for all XAB helpers

Look in /demo to see the features in action.

## INSTALL / UPDATE

### Linux

Run the following command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/koalition-xab/xab-template/main/install/install-linux.sh | bash
```

Running the script again checks for updates and repairs any submodule issues.

<details>
<summary>Using flags</summary>

Download the script once to use flags:

```bash
curl -fsSL https://raw.githubusercontent.com/koalition-xab/xab-template/main/install/install-linux.sh -o xab-install.sh
chmod +x xab-install.sh
./xab-install.sh --help
```

| Flag | Description |
|---|---|
| `-c, --check` | Check install health and available updates without modifying anything |
| `-u, --uninstall` | Remove the installed template |
| `-f, --force` | Remove existing installation and reinstall from scratch |
| `-y, --yes` | Skip all confirmation prompts (useful for CI/automation) |
| `-p, --path DIR` | Install to a custom path instead of the default |

</details>

### Windows

Run the following command in PowerShell:

```pwsh
iwr https://raw.githubusercontent.com/koalition-xab/xab-template/main/install/install-windows.ps1 -UseBasicParsing | iex
```

Running the script again checks for updates and repairs any submodule issues.

<details>
<summary>Using flags</summary>

Download the script once to use flags:

```pwsh
iwr https://raw.githubusercontent.com/koalition-xab/xab-template/main/install/install-windows.ps1 -OutFile xab-install.ps1
.\xab-install.ps1 -Help
```

| Flag | Description |
|---|---|
| `-Check` | Check install health and available updates without modifying anything |
| `-Uninstall` | Remove the installed template |
| `-Force` | Remove existing installation and reinstall from scratch |
| `-Yes` | Skip all confirmation prompts (useful for CI/automation) |
| `-Path <dir>` | Install to a custom path instead of the default |

</details>

## Fonts

XAB helper template requires following fonts:

- Open Sans
- Montserrat
- STIX Two Math

## Usage Example

```typ
#import "template.typ": *

#show: xab-helper.with(
  "INSY",
  "3. INSY Test",
  title: "Zusammenfassung",
  doc_version: "v1.1",
)
```

> [!TIP]
> Named parameters are optional\
> `title` defaults to "Zusammenfassung"\
> `doc_version` defualts to "v1.0"

## Predefined Styles

XAB Helpers styles certain elements by default

### Tables

Table elements are styled using alternating row-colors and a subtle border radius:
![Example table with alternating row colors](docs/img/table_alternating.png)

> [!TIP]
> You don't manually have to make your table header bold. XAB Helper Template can do this for you:\
> Label your table with either `top-header`, `side-header` or `both-header`:
>
> ```typ
> #table(
>   columns: 2,
>   [Header 1], [onlytwentyfourcharacters],
>   [Header 2], [Lorem ipsum...],
> )<side-header>
> ```
>
> Result:\
> ![Example table with automatic header styling](docs/img/automatic_header.png)

#### Remove styles

To remove predefined styles from `table` elements, label the table with `nostyle`

```typ
#table(
    columns: 2,
    [...], [...],
    [...], [...],
)<nostyle>
```

### Callouts

XAB Helper Template wraps pre-styled `showybox` callouts for different purposes:

![Example callouts for info, example and danger content](docs/img/callouts.png)

- Info

  ```typ
  #info[
    Info Content
  ]
  ```

- Example

  ```typ
  #example[
    Example Content
  ]
  ```

- Danger

  ```typ
  #danger[
    Danger Content
  ]
  ```
