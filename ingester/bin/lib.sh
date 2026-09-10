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

# next_id PREFIX file...: scans ids PREFIX-nnn (or Tnnn when PREFIX is T) and prints the next one.
next_id() { p=$1; shift; sep="-"; [ "$p" = T ] && sep=""
  n=$(cat "$@" 2>/dev/null | grep -o "$p$sep[0-9][0-9][0-9]" | sed "s/^$p$sep//" | sort -n | tail -1)
  printf "%s%s%03d\n" "$p" "$sep" $(( ${n:-0} + 1 )); }

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

# transcript_field engagement Tnnn "Column": a cell from the transcript register row.
transcript_row() { table_rows "$(eng_dir "$1")/transcripts.md" | grep "^| $2 |"; }
transcript_field() { r=$(transcript_row "$1" "$2"); [ -n "$r" ] || return 1; cell "$r" "$(col_index "$(eng_dir "$1")/transcripts.md" "$3")"; }

# vtt_path engagement Tnnn: the transcript file wherever it sits, verifying the SHA. Prints the path.
vtt_path() { d=$(eng_dir "$1"); f=$(transcript_field "$1" "$2" File) || die "$2 is not in transcripts.md"
  s=$(transcript_field "$1" "$2" SHA-256)
  for p in "$d/transcripts/unprocessed/$f" "$d/transcripts/processed/$f"; do
    if [ -f "$p" ]; then [ "$(sha256 "$p")" = "$s" ] || die "SHA-256 of $p does not match transcripts.md"; printf '%s\n' "$p"; return 0; fi; done
  die "transcript file $f not found under transcripts/"; }

# header_field file "Field": value of "- Field: value" in a file's header list.
header_field() { grep -m1 "^- $2:" "$1" | sed "s/^- $2: *//"; }

# sheet_signed file: prints nothing and returns 0 when the session sheet passes F5; otherwise prints the reason.
sheet_signed() { f=$1
  [ -n "$(header_field "$f" Approver)" ] || { echo "session sheet has no Approver"; return 1; }
  [ -n "$(header_field "$f" 'Approved on')" ] || { echo "session sheet has no Approved on"; return 1; }
  n=$(table_rows "$f" | awk -F'|' '{ v=$(NF-1); gsub(/ /, "", v); if (v == "") n++ } END { print n+0 }')
  [ "$n" -eq 0 ] || { echo "session sheet has $n row(s) with a blank verdict"; return 1; }
  return 0; }

# dossier_signed file: F5 for a dossier. A blank verdict on a Confident item in a bulk-accepted episode is Accept.
dossier_signed() { f=$1
  [ -n "$(header_field "$f" Approver)" ] || { echo "dossier has no Approver"; return 1; }
  [ -n "$(header_field "$f" 'Approved on')" ] || { echo "dossier has no Approved on"; return 1; }
  pend=$("$INGESTER_DIR/bin/dossier2tsv" "$f" | awk -F'\t' '$4 == "" && !($3 == "Confident" && $7 != "") { printf "%s ", $1 }')
  [ -z "$pend" ] || { echo "dossier has pending verdicts on item(s): $pend"; return 1; }
  return 0; }

# accepted_items dossier: dossier2tsv rows whose verdict is Accept or Edit, or blank-but-bulk-accepted Confident.
accepted_items() { "$INGESTER_DIR/bin/dossier2tsv" "$1" | awk -F'\t' '$4 == "Accept" || $4 == "Edit" || ($4 == "" && $3 == "Confident" && $7 != "")'; }

# scope_values engagement: F7 bullets.
scope_values() { awk '/^## Scope taxonomy/ { on=1; next } /^## / { on=0 } on && /^- / { sub(/^- /, ""); print }' "$(eng_dir "$1")/engagement.md"; }
