# lib.sh: shared functions for the ingester scripts. POSIX sh, awk, sed, grep, shasum, date only.
# Source with: . "$(dirname "$0")/lib.sh"

INGESTER_DIR=$(cd "$(dirname "$0")/.." && pwd)
ROOT_DIR=$(cd "$INGESTER_DIR/.." && pwd)
ENGAGEMENTS_ROOT=${ENGAGEMENTS_ROOT:-$ROOT_DIR/engagements}
case "$ENGAGEMENTS_ROOT" in /*) ;; *) ENGAGEMENTS_ROOT="$ROOT_DIR/$ENGAGEMENTS_ROOT" ;; esac
TAB=$(printf '\t')

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
today() { date '+%e %B %Y' | sed 's/^ *//'; }
utcstamp() { date -u '+%Y%m%dT%H%M%SZ'; }
ingester_version() { cat "$INGESTER_DIR/VERSION"; }
rules_version() { doc_version "$INGESTER_DIR/extraction-rules.md" 2>/dev/null || echo unknown; }
eng_dir() { printf '%s/%s\n' "$ENGAGEMENTS_ROOT" "$1"; }
sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }
unescape_pipes() { sed 's/\\|/|/g'; }
escape_pipes() { sed 's/|/\\|/g'; }

# Version line: first line of the file that starts with "Version ".
doc_version() { awk 'NR<=6 && /^Version [0-9]/ { v=$2; sub(/,$/, "", v); print v; exit }' "$1"; }
bump_version() {
  v=$(doc_version "$1"); [ -n "$v" ] || die "no version line in $1"
  maj=${v%%.*}; min=${v#*.}; new="$maj.$((min + 1))"
  awk -v new="$new" -v d="$(today)" 'done==0 && /^Version [0-9]/ { print "Version " new ", " d "."; done=1; next } { print }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}


# table_rows file: data rows of every markdown table in the file (skips header and alignment rows).
table_rows() { awk '/^\|/ { if ($0 ~ /^\|[-| ]*$/) { inhdr=0; next } if (!started) { started=1; next } print } !/^\|/ { started=0 }' "$1"; }
# table_header file: the first header row.
table_header() { awk '/^\|/ { print; exit }' "$1"; }

# cell "row" n: the n-th cell (1-based) of a markdown table row, trimmed, pipes unescaped.
cell() { printf '%s\n' "$1" | awk -v n="$2" '{ gsub(/\\\|/, "\001"); split($0, c, "|"); v=c[n+1]; gsub(/^ +| +$/, "", v); gsub(/\001/, "|", v); print v }'; }

# col_index file "Column name": 1-based column position in the first table header.
col_index() { table_header "$1" | awk -F'|' -v want="$2" '{ for (i=2;i<NF;i++) { v=$i; gsub(/^ +| +$/, "", v); if (v==want) { print i-1; exit } } }'; }

# fill_template template out KEY=value...: replaces {{KEY}} placeholders.
fill_template() { t=$1; o=$2; shift 2; cp "$t" "$o"
  for kv in "$@"; do k=${kv%%=*}; v=${kv#*=}; v=$(printf '%s' "$v" | sed 's/[\/&]/\\&/g')
    sed -i '' "s/{{$k}}/$v/g" "$o"; done; }

# log_run engagement tid stage outcome "read files" "written files"
log_run() { d=$(eng_dir "$1"); mkdir -p "$d/logs"; f="$d/logs/$(utcstamp)-$2-$3.md"
  { printf '# Run: %s %s\n\n- Time: %s\n- Stage: %s\n- Ingester version: %s\n- Rules version: %s\n- Outcome: %s\n- Read: %s\n- Written: %s\n' "$2" "$3" "$(utcstamp)" "$3" "$(ingester_version)" "$(rules_version)" "$4" "$5" "$6"; } > "$f"; printf '%s\n' "$f"; }

# ---- Items as files (register model 2.18 section 7) ----
# item_dir TYPE: folder name for a type prefix.
item_dir() { case $1 in REQ) echo requirements;; DEC) echo decisions;; LIM) echo limitations;; RSK) echo risks;; OI) echo open-items;; PRC) echo processes;; SYS) echo systems;; STK) echo stakeholders;; TOP) echo topics;; T) echo transcripts;; *) return 1;; esac; }
# item_path engagement ID: path of an item file from its id.
item_path() { p=${2%%-*}; case $2 in T[0-9]*) p=T;; esac; printf '%s/%s/%s.md\n' "$(eng_dir "$1")" "$(item_dir "$p")" "$2"; }
# next_id engagement PREFIX: next free id from the filenames in the type folder. Four digits; T is three.
next_id() { dir="$(eng_dir "$1")/$(item_dir "$2")"; sep="-"; w=4; [ "$2" = T ] && { sep=""; w=3; }
  n=$(ls "$dir" 2>/dev/null | grep -o "^$2$sep[0-9]*" | sed "s/^$2$sep//" | sort -n | tail -1)
  printf "%s%s%0${w}d\n" "$2" "$sep" $(( ${n:-0} + 1 )); }
# fm file key: scalar value from the frontmatter block.
fm() { awk -v k="$2" 'NR==1 && $0 != "---" { exit } NR>1 && /^---$/ { exit } NR>1 && index($0, k ": ") == 1 { sub(/^[^:]*: */, ""); print; exit } NR>1 && $0 == k ":" { print ""; exit }' "$1"; }
# fm_list file key: list items under a key, one per line.
fm_list() { awk -v k="$2" 'NR>1 && /^---$/ { exit } on && /^  - / { sub(/^  - /, ""); print; next } on && !/^  - / { exit } NR>1 && ($0 == k ":" || index($0, k ": ") == 1) { on=1 }' "$1"; }
# fm_set file key value: replace or add a scalar in the frontmatter.
fm_set() { awk -v k="$2" -v v="$3" 'NR>1 && /^---$/ && !done { if (!seen) print k ": " v; done=1 } !done && NR>1 && (index($0, k ": ") == 1 || $0 == k ":") { print k ": " v; seen=1; next } { print }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"; }
# fm_list_add file key value: append an item to a list key (created if missing), unless already present.
fm_list_add() { fm_list "$1" "$2" | grep -qxF "$3" && return 0
  awk -v k="$2" -v v="$3" 'NR>1 && /^---$/ && !done { if (!seen) { print k ":"; print "  - " v } ; done=1 } !done && NR>1 && ($0 == k ":" || index($0, k ": ") == 1) { print k ":"; seen=1; inlist=1; next } inlist && /^  - / { print; next } inlist { print "  - " v; inlist=0 } { print }' "$1" > "$1.tmp" && mv "$1.tmp" "$1"; }
# claim_sections file: section ids (f1, s2 ...) in a process or system file.
claim_sections() { awk '/^## [fs][0-9]+ / { print $2 }' "$1"; }
# claim_field file section key: "- key: value" under "## <section> ...".
claim_field() { awk -v s="$2" -v k="$3" '/^## / { on = ($2 == s) } on && index($0, "- " k ": ") == 1 { sub(/^- [^:]*: */, ""); print; exit }' "$1"; }
# render template out: fills {{KEY}} placeholders from files in $VALDIR (one file per KEY). Missing keys become blank.
render() { awk -v dir="$VALDIR" '
  { line = $0
    while (match(line, /\{\{[A-Z0-9_]+\}\}/)) { key = substr(line, RSTART + 2, RLENGTH - 4); val = ""; f = dir "/" key
      while ((getline l < f) > 0) val = val (val == "" ? "" : "\n") l; close(f)
      if (val == "" && line ~ /^[ \t]*\{\{[A-Z0-9_]+\}\}[ \t]*$/) { line = "\001SKIP"; break }
      line = substr(line, 1, RSTART - 1) val substr(line, RSTART + RLENGTH) }
    if (line != "\001SKIP") { sub(/[ \t]+$/, "", line); print line } }' "$1" > "$2"; }
# vals: start a fresh value set. set_val KEY value. set_list KEY "line\nline" writes list items.
vals() { VALDIR=$(mktemp -d); export VALDIR; }
set_val() { printf '%s' "$2" > "$VALDIR/$1"; }
set_list() { printf '%s\n' "$2" | grep . | sed 's/^/  - /' > "$VALDIR/$1" || true; }
vals_done() { rm -rf "$VALDIR"; unset VALDIR; }
# transcript helpers
transcript_field() { f=$(item_path "$1" "$2"); [ -f "$f" ] || return 1; fm "$f" "$3"; }
vtt_path() { d=$(eng_dir "$1"); f=$(transcript_field "$1" "$2" file) || die "$2 is not registered in transcripts/"
  s=$(transcript_field "$1" "$2" sha256)
  for p in "$d/transcripts/unprocessed/$f" "$d/transcripts/processed/$f"; do
    if [ -f "$p" ]; then [ "$(sha256 "$p")" = "$s" ] || die "SHA-256 of $p does not match transcripts/$2.md"; printf '%s\n' "$p"; return 0; fi; done
  die "transcript file $f not found under transcripts/"; }
# stk_lookup engagement "name": prints the STK id whose name or variant matches, case-insensitive.
stk_lookup() { lc=$(printf '%s' "$2" | tr 'A-Z' 'a-z'); for f in "$(eng_dir "$1")"/stakeholders/STK-*.md; do [ -f "$f" ] || continue
  n=$(fm "$f" name | tr 'A-Z' 'a-z'); if [ "$n" = "$lc" ] || fm_list "$f" variants | tr 'A-Z' 'a-z' | grep -qx "$lc"; then fm "$f" id; return 0; fi; done; return 1; }

# ---- Gates (F5) ----
header_field() { grep -m1 "^- $2:" "$1" | sed "s/^- $2: *//"; }
sheet_signed() { f=$1
  [ -n "$(header_field "$f" Approver)" ] || { echo "session sheet has no Approver"; return 1; }
  [ -n "$(header_field "$f" 'Approved on')" ] || { echo "session sheet has no Approved on"; return 1; }
  n=$(table_rows "$f" | awk -F'|' '{ v=$(NF-1); gsub(/ /, "", v); if (v == "") n++ } END { print n+0 }')
  [ "$n" -eq 0 ] || { echo "session sheet has $n row(s) with a blank verdict"; return 1; }
  return 0; }
dossier_signed() { f=$1
  [ -n "$(header_field "$f" Approver)" ] || { echo "dossier has no Approver"; return 1; }
  [ -n "$(header_field "$f" 'Approved on')" ] || { echo "dossier has no Approved on"; return 1; }
  pend=$("$INGESTER_DIR/bin/dossier2tsv" "$f" | awk -F'\t' '$4 == "" && !($3 == "Confident" && $7 != "") { printf "%s ", $1 }')
  [ -z "$pend" ] || { echo "dossier has pending verdicts on item(s): $pend"; return 1; }
  return 0; }
accepted_items() { "$INGESTER_DIR/bin/dossier2tsv" "$1" | awk -F'\t' '$4 == "Accept" || $4 == "Edit" || ($4 == "" && $3 == "Confident" && $7 != "")'; }
# phases engagement: phase names in order; current_phase engagement: the one marked (current).
phases() { awk '/^## Phases/ { on=1; next } /^## / { on=0 } on && /^- / { sub(/^- /, ""); sub(/ \(current\)$/, ""); print }' "$(eng_dir "$1")/engagement.md"; }
current_phase() { awk '/^## Phases/ { on=1; next } /^## / { on=0 } on && /^- .* \(current\)$/ { sub(/^- /, ""); sub(/ \(current\)$/, ""); print; exit }' "$(eng_dir "$1")/engagement.md"; }
# eng_log engagement "message": appends one dated line to the engagement's LOG.md.
eng_log() { f="$(eng_dir "$1")/LOG.md"; [ -f "$f" ] || printf '# Log: %s\n\nRunning log of this engagement, newest last.\n\n' "$1" > "$f"; printf -- '- %s: %s\n' "$(today)" "$2" >> "$f"; }
