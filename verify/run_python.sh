#!/usr/bin/env bash
# Never stops on failure: the result of each step is the point.
set +e
variant=$1
asserts=$2
{
  echo "### $variant, bounds checks $asserts"
  echo '```'
  python -m pytest python_test/test_bplsd.py -q -k order_above_cluster > new_test.log 2>&1
  echo "new test: exit $?"
  grep -E "passed|failed|Fatal|Assertion" new_test.log | cut -c1-150 | head -3
  python verify/repro_lsd_single_decode.py --max-shots 60
  python -m pytest python_test -q -rf > full.log 2>&1
  echo "python_test: exit $?"
  grep -E "^FAILED|^ERROR|[0-9]+ (passed|failed)" full.log | cut -c1-120
  echo '```'
} 2>&1 | tee -a "$GITHUB_STEP_SUMMARY"
