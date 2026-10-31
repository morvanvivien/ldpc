#!/usr/bin/env bash
# C++ driver for both decoders, with libstdc++ bounds checks and without.
set -eu
compile() {
  g++ -std=c++20 -O1 -D_GLIBCXX_ASSERTIONS -I "$2" -I include/robin_map verify/test_combination_sweep.cpp -o "build/sweep_$1_hardened.exe"
  g++ -std=c++20 -O1 -I "$2" -I include/robin_map verify/test_combination_sweep.cpp -o "build/sweep_$1_plain.exe"
}
mkdir -p build
cp -r src_cpp h_original
curl -fsSL https://github.com/quantumgizmos/ldpc/pull/112.diff | git apply
cp -r src_cpp h_pr112
git fetch -q origin fix-105-osd-dense-bounds
git checkout -q FETCH_HEAD -- src_cpp/osd_dense.hpp
cp -r src_cpp h_patched
compile original h_original
compile pr112 h_pr112
compile patched h_patched
set +e
{
  echo '### C++ driver'
  echo '```'
  python verify/verify_fix.py build
  echo "verify_fix: exit $?"
  echo
  echo 'PR 112 alone, bounds-checked, order 10'
  for which in dense sparse; do
    for k in 1 5 9 10 20; do
      "build/sweep_pr112_hardened.exe" "$which" "$k" 10 50 > /dev/null 2>&1
      echo "  $which k=$k: exit $?"
    done
  done
  echo '```'
} 2>&1 | tee -a "$GITHUB_STEP_SUMMARY"
