# fm.awk: the frontmatter reader (F3), shared by lib.sh fm and fm_list and by render-index. Not run on its own:
# lib.sh loads it into FM_AWK and a caller puts its own program after it, which must define fm_done(). fm_done()
# runs once per file, after the file's last line, so a caller can read the body in its own rules as well.
# In fm_done(): FM_FILE is the file being finished (FILENAME already names the next one); FM[key] is the first
# scalar value of each key, set only when the file opens with ---; FMN[key] and FML[key, 1..FMN[key]] are the items
# of the first list under the key. A key is the text before the first ": " or a bare "key:" line; the value is what
# follows the first colon and its spaces. The block ends at the next ---.
# An empty file calls nothing.
function fm_reset() { FM_FILE = FILENAME; split("", FM); split("", FMN); split("", FML); split("", fm_lseen); fm_in = 1; fm_cur = ""; fm_ok = ($0 == "---") }
function fm_join(k, sep,   i, s) { s = ""; for (i = 1; i <= FMN[k]; i++) s = s (i > 1 ? sep : "") FML[k, i]; return s }
function fm_line(   p, k, v) {
  if ($0 == "---") { fm_in = 0; return }
  if (fm_cur != "") { if (substr($0, 1, 4) == "  - ") { FML[fm_cur, ++FMN[fm_cur]] = substr($0, 5); return } fm_cur = "" }
  p = index($0, ": ")
  if (p > 0) k = substr($0, 1, p - 1); else if ($0 ~ /:$/) k = substr($0, 1, length($0) - 1); else return
  if (fm_ok && !(k in FM)) { v = ""; if (p > 0) { v = $0; sub(/^[^:]*: */, "", v) } FM[k] = v }
  if (!(k in fm_lseen)) { fm_lseen[k] = 1; fm_cur = k; FMN[k] += 0 } }
FNR == 1 { if (NR > 1) fm_done(); fm_reset() }
FNR > 1 && fm_in { fm_line() }
END { if (NR) fm_done() }
