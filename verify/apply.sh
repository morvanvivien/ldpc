#!/usr/bin/env bash
# Prepares one variant: main, pr112, fix or both. The new test is present in all of them.
set -eu
variant=$1
git fetch -q origin fix-105-osd-dense-bounds
git checkout -q FETCH_HEAD -- python_test/test_bplsd.py
case "$variant" in
  pr112|both) curl -fsSL https://github.com/quantumgizmos/ldpc/pull/112.diff | git apply ;;
esac
case "$variant" in
  fix|both) git checkout -q FETCH_HEAD -- src_cpp/osd_dense.hpp ;;
esac
git status --short
