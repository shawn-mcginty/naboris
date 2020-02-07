#!/bin/bash
echo "GET http://localhost:9997/static/random.txt" | vegeta attack -duration=10s -rate 500/1s | vegeta report | tee veg-report.txt

if cat veg-report.txt | grep -i -E '^success.*100\.00%$'; then
  veg_exit=0
else
  veg_exit=1
fi

rm -f veg-report.txt
exit $veg_exit