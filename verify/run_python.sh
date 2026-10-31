#!/usr/bin/env bash
# Never stops on failure: the result of each step is the point.
set +e
variant=$1
{
  echo "### $variant"
  echo '```'
  python -m pytest python_test/test_bplsd.py -q -k order_above_cluster > new_test.log 2>&1
  echo "new test: exit $?"
  tail -2 new_test.log
  python verify/repro_lsd_single_decode.py --max-shots 60
  python -m pytest python_test -q > full.log 2>&1
  echo "python_test: exit $?"
  tail -4 full.log
  echo '```'
} 2>&1 | tee -a "$GITHUB_STEP_SUMMARY"
