# The model benchmark. Plain sh and the host claude CLI; nothing is installed, so there is no Dockerfile.
# make bench     run both arms on T001, judge them twice, print the report, tear down (KEEP=1 keeps it)
# make selftest  everything except the models, with a fake judge; tears down
# make check     syntax of every script and the delete guard
# make clean     remove kept run folders under $TMPDIR/clark-bench and every Claude Code session folder
#                a bench run left under ~/.claude/projects (do not run it while a bench is running)

.PHONY: bench selftest check clean resume

bench:
	@bin/bench

selftest:
	@bin/selftest

check:
	@for f in bin/*; do sh -n "$$f" || exit 1; done
	@sh -c '. bin/lib.sh; mkdir -p "$$BENCH_TMP"; ! run_ok "$$BENCH_TMP" && ! run_ok "$$BENCH_TMP/.." && ! run_ok / && echo "check passed"'

clean:
	@sh -c '. bin/lib.sh; for d in "$$BENCH_TMP"/*; do [ -d "$$d" ] || continue; rm_sessions "$$d" || true; rm_run "$$d" && echo "removed $$d"; done; for s in "$$HOME"/.claude/projects/*-clark-bench-*; do [ -d "$$s" ] && rm -rf -- "$$s" && echo "removed session folder $${s##*/}"; done; true'

# make resume RUN=<kept run folder>  continue a kept run whose arms were cut off, then judge and report
resume:
	@[ -n "$(RUN)" ] || { echo "usage: make resume RUN=<kept run folder>"; exit 1; }
	@bin/bench --resume "$(RUN)"
