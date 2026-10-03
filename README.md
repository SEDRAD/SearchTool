# SearchTool

SearchTool is a small and fast text-search utility for developers, written in Delphi.

It searches for text inside source code and other plain-text files across a folder and, optionally, its subfolders.

## Features

- Search text inside multiple files
- Multiple file masks separated by `;`
- Recursive search in subfolders
- Case-sensitive or case-insensitive search
- Displays the file name, line number and full path
- 6-line preview around the selected result
- Double-click a result to open the file
- Context menu:
  - Open file
  - Open containing folder
  - Copy full path
- Search progress display
- Stop an ongoing search
- Error display
- Path and file-mask history
- French and English interface
- Automatic Windows language detection
- Support for common text encodings, including:
  - UTF-8
  - UTF-8 BOM
  - UTF-16 LE/BE BOM
  - Windows ANSI
  - Windows-1251 fallback for Cyrillic text

## File filters

SearchTool includes predefined filters for common development files:

- Delphi / Pascal (`*.pas`, `*.dpr`, `*.dpk`, `*.dfm`, `*.inc`)
- C / C++
- C#
- Java
- Python
- JavaScript / TypeScript
- PHP
- HTML / CSS
- XML / JSON
- SQL
- Batch / PowerShell
- Shell scripts
- TXT / LOG / INI
- All files (`*.*`)

Custom masks can also be entered manually.

## Requirements

- Windows
- 32-bit and 64-bit versions

SearchTool 1.0 was developed with Embarcadero RAD Studio 12.3 / Delphi.

## Scope of version 1.0

SearchTool 1.0 searches plain-text files only.

Formats such as PDF, DOCX and XLSX are not supported in this version.

## License

License information will be added before the first release.

## Author

SEDRAD
