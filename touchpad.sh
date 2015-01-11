#!/bin/bash


function switch(){
local device_id=14;
local state=$(xinput --list-props $device_id | grep "Device Enabled" | cut -d":" -f2)
[ $state -eq 0 ] && xinput --enable  $device_id || xinput --disable $device_id
}

switch

