#!/bin/bash
# 1.0 nanosecond – cycle time for radio frequency 1 GHz (1×10^9 hertz), an inverse unit.


A_FREQ=$(avblfreq="available frequency steps:";cpupower -c 1 frequency-info | grep "$avblfreq" | sed "s/$avblfreq//" | sed "s/ GHz,\| GHz/GHz/g" | xargs)
FREQ="2.00GHz"
DEFAULT_GOVERNOR="powersave"



function check_freq(){
if [[ "$A_FREQ" != *"$FREQ"* ]]; then
echo -e "\n$FREQ is not supported. See list: [ $A_FREQ ]"
exit 1;
fi
}

function show_status(){
echo -e "Current freq:\n$(cpupower -c all frequency-info -mf)"
echo -e "Turbo boost: $(cat /sys/devices/system/cpu/cpufreq/boost)"
}

function switch_on_lock(){
show_status
echo -e "Want to freq: $FREQ on all cpus"
check_freq
bash -c  'printf "0" >  /sys/devices/system/cpu/cpufreq/boost'
cpupower -c all frequency-set -f $FREQ > /dev/null 
echo "Done!"
show_status
}

function switch_off_lock(){
cpupower -c all frequency-set -g $DEFAULT_GOVERNOR > /dev/null
bash -c  'printf "1" >  /sys/devices/system/cpu/cpufreq/boost'
show_status
}



if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

case $1 in
	"off")
switch_off_lock;;
	"on")
switch_on_lock;;
	*)
echo "Argument is missed! Expected [on, off]";;
esac


