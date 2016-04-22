#!/bin/bash

set -v

echo >>lpl
./l.pl &
sleep 2
./l.pl
cat lpl
