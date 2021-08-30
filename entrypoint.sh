#!/bin/bash

modules=$(cat /lib/modules/$(uname -r)/modules.dep | cut -d : -f 1 | cut -d . -f 1)

for module in $modules ; do
    modprobe $module
done

sleep infinity
