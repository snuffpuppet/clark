# Sourced by every bench script. Paths, guards and the small helpers they share.
BENCH_DIR=$(cd "$(dirname "$0")/.." && pwd)
ROOT_DIR=$(cd "$BENCH_DIR/.." && pwd)
BENCH_TMP=$(cd "${TMPDIR:-/tmp}" && pwd -P)/clark-bench
ENG=techm-bss
TID=T001
VTT="ABB BSS Advisory _ S1 _ Sales & Commercial.vtt"
SUBJECT="Sales & Commercial"
# What the stand-in reviewer types at the session sheet. The date is not in the transcript or its file name,
# so the reply gives it, as the reviewer did on the real run; it is read from the repo's transcript record.
SESSION_DATE=$(sed -n 's/^session-date: //p' "$ROOT_DIR/engagements/$ENG/transcripts/$TID.md" 2>/dev/null)
GATE_REPLY="accept all. The session date is $SESSION_DATE."
# What make resume types to an arm that was cut off before the dossier gate.
RESUME_REPLY="continue"
JUDGE_MODEL=${JUDGE_MODEL:-claude-opus-5-5}
WINDOW=${WINDOW:-100}

die() { printf 'bench: %s\n' "$*" >&2; exit 1; }
say() { printf '%s\n' "$*" >&2; }

# A run folder is a direct child of $BENCH_TMP and nothing else. Every delete goes through this.
run_ok() { p=$(cd "$1" 2>/dev/null && pwd -P) || return 1
  case "$p" in "$BENCH_TMP"/*) r=${p#"$BENCH_TMP"/}; case "$r" in ""|*/*|.|..|*..*) return 1 ;; esac ;; *) return 1 ;; esac; }
rm_run() { run_ok "$1" || die "refusing to delete $1: not a run folder under $BENCH_TMP"; rm -rf -- "$p"; }

# A version 4 UUID from /dev/urandom, for --session-id.
new_uuid() { head -c 32 /dev/urandom | shasum | awk '{ h = $1; printf "%s-%s-4%s-8%s-%s\n", substr(h,1,8), substr(h,9,4), substr(h,14,3), substr(h,18,3), substr(h,21,12) }'; }

# A seed for awk's srand, so X and Y are assigned at random per run.
new_seed() { head -c 8 /dev/urandom | shasum | awk '{ n = 0; for (i = 1; i <= 7; i++) n = n * 16 + index("0123456789abcdef", substr($1, i, 1)) - 1; print n }'; }

# Fields from the final result event of a stream-json file.
result_line() { grep '"type":"result"' "$1" | grep '"total_cost_usd"' | tail -1; }
json_num() { printf '%s' "$1" | grep -o "\"$2\":[0-9.e+-]*" | head -1 | sed 's/.*://'; }
json_str() { printf '%s' "$1" | grep -o "\"$2\":\"[^\"]*\"" | head -1 | sed 's/^[^:]*:"//; s/"$//'; }

# The arms. Name, then model id.
ARMS="opus claude-opus-5-5
sonnet claude-sonnet-5-5"

# The Claude Code session folders a run's arms left: one per arm working directory, named after its path
# with every character that is not a letter or digit as "-". Only names holding "-clark-bench-" are touched.
rm_sessions() { key=$(printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'); case "$key" in *-clark-bench-*) ;; *) return 1 ;; esac
  for s in "$HOME"/.claude/projects/"$key"-*; do [ -d "$s" ] && rm -rf -- "$s"; done; return 0; }
