#!/bin/bash
ps -eo pmem,pcpu,rss,vsize,args | sort -k 1 -r | less
