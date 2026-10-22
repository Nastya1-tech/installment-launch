#!/bin/sh
# Static checks for index.html. Exit 0 on success, else print FAIL and exit 1.
cd "$(dirname "$0")" || exit 1
if locale -a 2>/dev/null | grep -qx 'en_US.UTF-8'; then export LC_ALL=en_US.UTF-8; else export LC_ALL=C.UTF-8; fi
F=index.html
[ -f "$F" ] || { echo "FAIL: $F not found"; exit 1; }

has() { grep -qE "$1" "$F" || { echo "FAIL: $2"; exit 1; }; }
hasnt() { grep -qiE "$1" "$F" && { echo "FAIL: $2"; exit 1; }; return 0; }

has '<meta name="viewport"' "viewport meta"
has '<style>' "inline style"
has 'data-lang="ru"' "default language ru"
has 'id="lang-ru"' "RU switcher button"
has 'id="lang-en"' "EN switcher button"
for s in offer problem cycle experience contact; do
  has "<section id=\"$s\"" "section $s"
done
has 'function setLang\(' "setLang function defined"
has '<title>Запуск рассрочки для банков</title>' "RU <title>"
has 'en: *\{' "META.en object"
has 'title: *"Installment launch for banks"' "META.en.title"
has 'description: *"[A-Za-z][^"]+"' "META.en.description non-empty English"
has 'subject: *"[A-Za-z][^"]+"' "META.en.subject non-empty English"

hasnt 'https?://' "external URL found"
hasnt 'кросс|выручк|оборот|cross-sell|revenue' "forbidden word"
grep -qE '\bNDA\b' "$F" && { echo "FAIL: forbidden word NDA"; exit 1; }

echo "OK"
