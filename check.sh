#!/bin/sh
# Static checks for index.html. Exit 0 on success, else print FAIL and exit 1.
cd "$(dirname "$0")" || exit 1
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
has 'setLang' "setLang function"
has 'Запуск рассрочки для банков' "RU title"
has 'Installment launch for banks' "EN title"

hasnt 'https?://' "external URL found"
hasnt 'кросс|cross-sell|cross sell|оборот|выручк|revenue|turnover|скрыт|hidden fee|hidden commission' "forbidden word"

echo "OK"
