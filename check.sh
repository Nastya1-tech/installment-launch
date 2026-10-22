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

has '<h1' "h1"
has 'id="offer-btn"' "offer button"
has 'mailto:hello@example\.com' "mailto"
has 'Написать мне' "RU button text"
has 'Write to me' "EN button text"
has '№1' "proof №1"
has '1([ ]|&nbsp;| )500\+' "proof 1 500+"
has '2([ ]|&nbsp;| )000\+' "proof 2 000+"

[ "$(grep -o 'class="step"' "$F" | wc -l | tr -d ' ')" -eq 7 ] || { echo "FAIL: cycle must have exactly 7 steps"; exit 1; }
has 'Аналитика' "RU step Аналитика"
has 'Analytics' "EN step Analytics"
if sed -n '/id="problem"/,/<\/section>/p' "$F" | grep -q '80%'; then echo "FAIL: 80% in problem block"; exit 1; fi

hasnt 'https?://' "external URL found"
hasnt 'кросс|выручк|оборот|cross-sell|revenue' "forbidden word"
grep -qE '\bNDA\b' "$F" && { echo "FAIL: forbidden word NDA"; exit 1; }

has 'Pasha Bank Georgia' "Pasha Bank Georgia"
has 'MAIB' "MAIB"
has 'MTBank' "MTBank"
has 'Umico' "Umico"
has '80%' "80%"
has 'id="mail-btn"' "mail button"
has 'Анастасия Губаревич' "RU signature"
has 'Anastasia Gubarevich' "EN signature"
has 'Nestl' "Nestlé"
has 'Huggies' "Huggies"
has '5.7.10' "5-7-10"
hasnt '<img' "img tag found"

has 'создавала с нуля' "RU wording создавала с нуля"
hasnt 'построила' "forbidden wording построила"

echo "OK"
