#!/bin/bash
ping -c 1 www.google.com > /dev/null
echo -n $?
