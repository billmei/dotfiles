#!/bin/bash
# Test suite for verify_hashes.sh. Run: ./verify_hashes_test.sh

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/verify_hashes.sh"
TEST_TMP_ROOT="$SCRIPT_DIR/.verify_hashes_test_tmp"
TESTS_RUN=0
TESTS_FAILED=0

rm -rf "$TEST_TMP_ROOT"
mkdir -p "$TEST_TMP_ROOT"
trap 'rm -rf "$TEST_TMP_ROOT"' EXIT

# Builds a fresh pair of fixture dirs: t1/t2 with a matching file (foo.txt),
# a file only in t1 (only1.txt), an AppleDouble sidecar with a real sibling
# (._foo.txt, should be skipped), and a .DS_Store (should be skipped).
setup_fixture() {
    WORKDIR=$(mktemp -d "$TEST_TMP_ROOT/case.XXXXXX")
    DIR1="$WORKDIR/t1"
    DIR2="$WORKDIR/t2"
    mkdir -p "$DIR1" "$DIR2"
    echo "hello" > "$DIR1/foo.txt"
    echo "hello" > "$DIR2/foo.txt"
    echo "only in t1" > "$DIR1/only1.txt"
    echo "appledouble metadata" > "$DIR1/._foo.txt"
    echo "finder metadata" > "$DIR1/.DS_Store"
}

# Runs the script with the given extra args against the fixture dirs and
# captures stdout/stderr into STDOUT_OUT/STDERR_OUT, returns its exit code.
run_script() {
    STDOUT_OUT=$(mktemp "$TEST_TMP_ROOT/stdout.XXXXXX")
    STDERR_OUT=$(mktemp "$TEST_TMP_ROOT/stderr.XXXXXX")
    "$SCRIPT" "$@" "$DIR1" "$DIR2" >"$STDOUT_OUT" 2>"$STDERR_OUT"
    EXIT_CODE=$?
}

# Asserts that a string contains/doesn't contain a substring, reporting PASS/FAIL.
assert() {
    local description="$1" haystack="$2" needle="$3" expect_present="$4"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expect_present" = "yes" ]; then
        if grep -qF "$needle" <<< "$haystack"; then
            echo "PASS: $description"
        else
            echo "FAIL: $description (expected to find: $needle)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if grep -qF "$needle" <<< "$haystack"; then
            echo "FAIL: $description (expected NOT to find: $needle)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        else
            echo "PASS: $description"
        fi
    fi
}

# Flags a file only present in dir1 as ONLY IN.
setup_fixture; run_script; assert "reports file only in dir1" "$(cat "$STDOUT_OUT")" "ONLY IN $(cd "$DIR1" && pwd -P): only1.txt" yes

# Skips an AppleDouble sidecar file when its real sibling exists.
setup_fixture; run_script; assert "skips ._foo.txt sidecar with sibling foo.txt" "$(cat "$STDOUT_OUT")" "._foo.txt" no

# Skips .DS_Store unconditionally.
setup_fixture; run_script; assert "skips .DS_Store" "$(cat "$STDOUT_OUT")" "DS_Store" no

# Does not print a MISMATCH line for files whose contents are identical.
setup_fixture; run_script; assert "no mismatch for identical files" "$(cat "$STDOUT_OUT")" "MISMATCH" no

# Reports a MISMATCH when the same relative path has different content.
setup_fixture; echo "different" > "$DIR2/foo.txt"; run_script; assert "reports mismatch for differing content" "$(cat "$STDOUT_OUT")" "MISMATCH: foo.txt" yes

# A sidecar file is NOT skipped (and is compared/flagged) when its real sibling is missing.
setup_fixture; rm "$DIR1/foo.txt"; run_script; assert "does not skip orphan ._foo.txt without sibling" "$(cat "$STDOUT_OUT")" "._foo.txt" yes

# An AppleDouble sidecar for a folder (._SomeFolder) is skipped when that folder exists alongside it.
setup_fixture; mkdir "$DIR1/SomeFolder"; echo "folder metadata" > "$DIR1/._SomeFolder"; run_script; assert "skips ._SomeFolder sidecar with sibling folder" "$(cat "$STDOUT_OUT")" "._SomeFolder" no

# An AppleDouble-named file for a folder is NOT skipped when no such folder exists alongside it.
setup_fixture; echo "orphan folder metadata" > "$DIR1/._OrphanFolder"; run_script; assert "does not skip ._OrphanFolder without sibling folder" "$(cat "$STDOUT_OUT")" "._OrphanFolder" yes

# Without -v, matching files don't get a ✅ log line.
setup_fixture; run_script; assert "no checkmark output without verbose" "$(cat "$STDOUT_OUT")" "✅" no

# With -v, matching files get a ✅ log line.
setup_fixture; run_script -v; assert "checkmark output with verbose" "$(cat "$STDOUT_OUT")" "✅ foo.txt" yes

# Without -v, the progress bar is drawn to stderr.
setup_fixture; run_script; assert "progress bar shown without verbose" "$(cat "$STDERR_OUT")" "Comparing" yes

# With -v, the progress bar is suppressed entirely.
setup_fixture; run_script -v; assert "progress bar suppressed with verbose" "$(cat "$STDERR_OUT")" "Comparing" no

# Result lines are not appended to the same line as the progress bar (each ONLY IN line starts at column 0).
setup_fixture; run_script; assert "log line not glued to progress bar text" "$(cat "$STDOUT_OUT")" "]ONLY IN" no

# stdout contains exactly the result lines with no carriage-return bar fragments mixed in (buffered flush keeps stdout clean).
setup_fixture; run_script; assert "stdout has no carriage returns from the bar" "$(cat "$STDOUT_OUT")" "$(printf '\r')" no

# In --quick mode, same-size files with different content are not flagged (size-only check).
setup_fixture; printf "hellp\n" > "$DIR2/foo.txt"; run_script -q; assert "quick mode ignores content, only checks size" "$(cat "$STDOUT_OUT")" "MISMATCH" no

# In --quick mode, a same-name file with a different size is still flagged as a MISMATCH.
setup_fixture; printf "hello world" > "$DIR2/foo.txt"; run_script -q; assert "quick mode flags differing file size" "$(cat "$STDOUT_OUT")" "MISMATCH: foo.txt" yes

# With a third argument, a cp command is written for a file only in dir1, copying it into dir2.
setup_fixture; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; assert "writes cp command for file only in dir1" "$(cat "$COPY_SCRIPT")" "cp $DIR1/only1.txt $DIR2/only1.txt" yes

# With a third argument, running the generated copy script actually copies the missing file across.
setup_fixture; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; bash "$COPY_SCRIPT"; assert "running copy script materializes the missing file" "$([ -f "$DIR2/only1.txt" ] && echo present)" "present" yes

# With a third argument, a MISMATCH file is recorded as a comment line in the copy script.
setup_fixture; echo "different" > "$DIR2/foo.txt"; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; assert "writes # MISMATCH comment for differing file" "$(cat "$COPY_SCRIPT")" "# MISMATCH: foo.txt" yes

# A MISMATCH file is also given a cp command copying the dir1 source over the dir2 destination.
setup_fixture; echo "different" > "$DIR2/foo.txt"; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; assert "writes cp command for MISMATCH file" "$(cat "$COPY_SCRIPT")" "cp $DIR1/foo.txt $DIR2/foo.txt" yes

# Running the copy script overwrites the differing dir2 file with the dir1 source.
setup_fixture; echo "different" > "$DIR2/foo.txt"; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; bash "$COPY_SCRIPT"; assert "MISMATCH cp command overwrites differing file when copy script runs" "$(cat "$DIR2/foo.txt")" "hello" yes

# In --quick mode, a size-MISMATCH is also recorded as a comment line in the copy script.
setup_fixture; printf "hello world" > "$DIR2/foo.txt"; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" -q "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; assert "quick mode writes # MISMATCH comment for size diff" "$(cat "$COPY_SCRIPT")" "# MISMATCH: foo.txt" yes

# Matching files do not produce a MISMATCH comment in the copy script.
setup_fixture; COPY_SCRIPT="$WORKDIR/copy.sh"; "$SCRIPT" "$DIR1" "$DIR2" "$COPY_SCRIPT" >/dev/null 2>&1; assert "no # MISMATCH comment for identical files" "$(cat "$COPY_SCRIPT")" "# MISMATCH" no

# Without a third argument, no copy script side effects occur.
setup_fixture; run_script; assert "no copy script file referenced without third arg" "$(cat "$STDOUT_OUT")" "Copy commands written" no

# Size pre-check (#1): equal-size files with differing content are still caught by the hash in full mode.
setup_fixture; echo "world" > "$DIR2/foo.txt"; run_script; assert "full mode hashes equal-size differing files" "$(cat "$STDOUT_OUT")" "MISMATCH: foo.txt" yes

# Size pre-check (#1): in full mode a size difference is reported as a size MISMATCH (hashing is skipped).
setup_fixture; echo "hello world" > "$DIR2/foo.txt"; run_script; assert "full mode reports size mismatch without hashing" "$(cat "$STDOUT_OUT")" "MISMATCH: foo.txt (size" yes

# Cache (#2): with --cache, a hash cache file is written referencing the compared file.
setup_fixture; CACHE="$WORKDIR/cache.tsv"; run_script --cache "$CACHE"; assert "writes hash cache file" "$(cat "$CACHE" 2>/dev/null)" "foo.txt" yes

# Cache (#2): a second run reusing the cache still reports identical files as matching.
setup_fixture; CACHE="$WORKDIR/cache.tsv"; run_script --cache "$CACHE"; run_script --cache "$CACHE"; assert "cached second run still matches identical files" "$(cat "$STDOUT_OUT")" "MISMATCH" no

# Cache (#2): the cache is actually consulted — poisoning a cached hash for an unchanged file makes the next run report a (false) mismatch.
setup_fixture; CACHE="$WORKDIR/cache.tsv"; run_script --cache "$CACHE"; awk -F'\t' 'BEGIN{OFS="\t"} $4 ~ /\/t1\/foo.txt$/ {$1="deadbeef"} {print}' "$CACHE" > "$CACHE.tmp"; mv "$CACHE.tmp" "$CACHE"; run_script --cache "$CACHE"; assert "reuses cached hash for unchanged file" "$(cat "$STDOUT_OUT")" "MISMATCH: foo.txt" yes

# Cache (#2): a --quick run does not clobber an existing cache built by a full run.
setup_fixture; CACHE="$WORKDIR/cache.tsv"; run_script --cache "$CACHE"; run_script -q --cache "$CACHE"; assert "quick run preserves existing cache" "$(cat "$CACHE" 2>/dev/null)" "foo.txt" yes

# Missing arguments prints usage and exits non-zero.
TESTS_RUN=$((TESTS_RUN + 1)); "$SCRIPT" >/dev/null 2>&1; if [ $? -ne 0 ]; then echo "PASS: missing args exits non-zero"; else echo "FAIL: missing args exits non-zero"; TESTS_FAILED=$((TESTS_FAILED + 1)); fi

echo ""
echo "$TESTS_RUN tests run, $TESTS_FAILED failed."
[ "$TESTS_FAILED" -eq 0 ]
