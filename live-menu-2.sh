#!/usr/bin/env bash
set -euo pipefail
base_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
show_hint() {
    local choice="$1" file
    case "$choice" in
        0) file="$base_dir/SHOW-PRACTICE-2.md" ;;
        c|C) file="$base_dir/PRACTICE-2.md" ;;
        d|D) file="$base_dir/live-cards-2/DIAGNOSTICS.md" ;;
        1|01) file="$base_dir/live-cards-2/01.md" ;;
        2|02) file="$base_dir/live-cards-2/02.md" ;;
        3|03) file="$base_dir/live-cards-2/03.md" ;;
        4|04) file="$base_dir/live-cards-2/04.md" ;;
        5|05) file="$base_dir/live-cards-2/05.md" ;;
        6|06) file="$base_dir/live-cards-2/06.md" ;;
        7|07) file="$base_dir/live-cards-2/07.md" ;;
        8|08) file="$base_dir/live-cards-2/08.md" ;;
        9|09) file="$base_dir/live-cards-2/09.md" ;;
        10) file="$base_dir/live-cards-2/10.md" ;;
        *) printf '%s\n' 'Используй 0, 1–10, c, d или q.' >&2; return 1 ;;
    esac
    if [[ ! -f "$file" ]]; then printf 'Файл не найден: %s\n' "$file" >&2; return 1; fi
    cat -- "$file"
}
if (( $# > 0 )); then
    case "$1" in q|Q) exit ;; esac
    show_hint "$1"
    exit
fi
while true; do
    printf '\n%s\n' 'Практическая №2 — подсказки, только просмотр'
    printf '%s\n' '0  Порядок показа' '1  Scaling' '2  Self-healing'         '3  ConfigMap' '4  Secret' '5  Service' '6  Resource limits'         '7  Health check' '8  Rolling update' '9  Rollback'         '10 Диагностика карточки' 'c  Инструкция запуска PRACTICE-2.md'         'd  Быстрая диагностика' 'q  Выход'
    if ! read -r -p 'Номер: ' choice; then break; fi
    case "$choice" in q|Q) break ;; esac
    show_hint "$choice" || continue
    printf '\n%s\n' 'Команды не выполнялись. Для выполнения скопируй нужный блок после выхода из меню.'
    if ! read -r -p 'Enter — вернуться в меню: ' unused; then break; fi
 done
