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

[ "$(grep -o 'class="step"' "$F" | wc -l | tr -d ' ')" -eq 8 ] || { echo "FAIL: cycle must have exactly 8 steps"; exit 1; }
has 'Аналитика' "RU step Аналитика"
has 'Analytics' "EN step Analytics"
if sed -n '/id="problem"/,/<\/section>/p' "$F" | grep -q '80%'; then echo "FAIL: 80% in problem block"; exit 1; fi

hasnt 'https?://' "external URL found"
hasnt 'кросс|выручк|оборот|cross-sell|revenue' "forbidden word"
grep -qE '\bNDA\b' "$F" && { echo "FAIL: forbidden word NDA"; exit 1; }

has 'MTBank' "MTBank"
has 'Umico' "Umico"
has 'Грузия и Молдова' "Georgia and Moldova card"
has '80%' "80%"
has 'id="mail-btn"' "mail button"
has 'Анастасия Губаревич' "RU signature"
has 'Anastasia Gubarevich' "EN signature"
has '5.7.10' "5-7-10"
[ "$(grep -o '<img' "$F" | wc -l | tr -d ' ')" -eq 1 ] || { echo "FAIL: exactly one img (portrait) expected"; exit 1; }
has 'src="photo.jpg"' "portrait"

has '[Сс]оздавала с нуля' "RU wording создавала с нуля"
hasnt 'построила' "forbidden wording построила"

has 'No\. 1' "EN No. 1"
has 'aria-pressed' "aria-pressed"

# MVP «Попробуйте сами»
has '<section id="try"' "section try"
[ "$(grep -n '<section id=' "$F" | cut -d'"' -f2 | tr '\n' ' ')" = "offer problem try cycle experience contact " ] || { echo "FAIL: section order must be offer problem try cycle experience contact"; exit 1; }
has 'id="mode-usual"' "mode usual button"
has 'id="mode-program"' "mode program button"
has 'Как обычно' "RU mode usual"
has 'Как в программе' "RU mode program"
has 'The usual way' "EN mode usual"
has 'In the programme' "EN mode program"
has 'в рассрочку нельзя' "RU not available label"
has 'в рассрочку можно' "RU available label"
has 'цена со скидкой' "RU discount label"
has 'function setMode\(' "setMode function"
[ "$(sed -n '/id="try"/,/<\/section>/p' "$F" | grep -o 'class="tile' | wc -l | tr -d ' ')" -ge 5 ] || { echo "FAIL: try needs at least 5 tiles"; exit 1; }
if sed -n '/id="try"/,/<\/section>/p' "$F" | sed 's/<[^>]*>//g' | sed 's/B2[BC]//g' | grep -qE '[0-9]'; then echo "FAIL: digits in try block"; exit 1; fi

# MVP-3: закрытый список из 11 вопросов
[ "$(grep -o 'class="q"' "$F" | wc -l | tr -d ' ')" -eq 11 ] || { echo "FAIL: exactly 11 questions expected"; exit 1; }
[ "$(grep -o 'class="btn ask-btn"' "$F" | wc -l | tr -d ' ')" -eq 11 ] || { echo "FAIL: each question needs an ask button"; exit 1; }
[ "$(grep -o 'aria-expanded="false" aria-controls="qa-' "$F" | wc -l | tr -d ' ')" -eq 11 ] || { echo "FAIL: each question toggle needs aria-expanded"; exit 1; }
has 'один из многочисленных' "RU nuances phrase"
has 'one of many' "EN nuances phrase"
has 'Ответ — на консультации' "RU answer line"
has 'Обсудить на встрече' "RU ask button"
has 'subject=%D0%97.*&body=' "mailto with subject and body for questions"
has '"&body=" \+ encodeURIComponent' "setLang updates question mail body"

# MVP-4: без JavaScript и доступность
has '<section id="try" data-mode="usual"' "no-JS default mode is usual"
has '#try\.js \.q:not\(\.open\) \.q-answer \{ display: none' "answers hidden only under .js"
has '#try:not\(\.js\) \.modes \{ display: none' "mode switch hidden without JS"
hasnt 'class="q-answer"[^>]*hidden' "answers must not be hidden in markup"
hasnt '<[^>]*id="try"[^>]*class="[^"]*\bjs\b' "js class must come from script, not markup"
has 'classList\.add\("js"\)' "script adds js class"
has 'prefers-reduced-motion: reduce' "reduced-motion guard"
has 'scroll-padding-top' "focus not hidden under sticky header"
has 'class="tiles" tabindex="0" aria-label=' "tiles strip focusable and labelled"
has 'tiles"\)\.setAttribute\("aria-label"' "tiles label follows language"
has 'a:focus-visible' "focus ring on all links"

echo "OK"
