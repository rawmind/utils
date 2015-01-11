#!/bin/bash

#   Copyright (C) 2012 Sorokin Alexei <sor.alexei@hotbox.ru>
#     Civil <civil@gentoo.ru>
#   Homepage: http://ubuntovod.ru/soft/ullkd.html
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://gnu.org/licenses/>.

IsDebianBased() {
    if [ -r "/etc/debian_version" ]; then
        return 0;
    else
        return 1;
    fi;
}

IsRussian() {
    if [ -z $(echo "${LANG}" | grep "^ru") ] && [ -z $(echo "${LANG}" | grep "^uk") ]; then
        return 1;
    else
        return 0;
    fi;
}

Usage() {
    if ( ! IsRussian ); then
        echo -n "Использование:";
    else
        echo -n "Usage:";
    fi;
    echo " \`$(basename $0)' [-h] [-v] [-b] [-p] [-r] [-m ...]";
    return 0;
}

ErrorFunc() {
    Usage;
    if ( ! IsRussian ); then
        echo "Try \`$(basename $0)' -h for more information.";
    else
        echo "Запустите \`$(basename $0)' для получения более подробной справки.";
    fi;
    return 1;
}

ParamCheck() {
    Title="ULLKD: Ubuntu Latest Linux Kernel Downloader v0.3";
    while getopts "bprm:hv" ParamStr ${argv}; do
        case "${ParamStr}" in
            b)
              export UbuntuBranchMode=true;
            ;;
            p)
              export PfKernelMode=true;
            ;;
            r)
              export RemoveNonlatestKernelsMode=true;
            ;;
            m)
              export Mirror="${OPTARG}";
            ;;
            h)
              echo "${Title}";
              Usage;
              if ( ! IsRussian ); then
                  echo -e "\n  -b                  install kernel from Ubuntu branch";
                  echo "  -p                  install pf-kernel build of NiGHt-LEshiY";
                  echo "  -r                  remove nonlatest kernels";
                  echo "  -m                  set download mirror (http://archive.ubuntu.com/ubuntu/ by default)";
                  echo "  -h                  print this help and exit";
                  echo "  -v                  display the current version and exit";
                  echo -e "\nReport problems to <sor.alexei@hotbox.ru>.";
              else
                  echo -e "\n  -b                  установить ядро из ветки Ubuntu";
                  echo "  -p                  установить сборку pf-kernel от NiGHt-LEshiY";
                  echo "  -r                  удалить непоследние ядра";
                  echo "  -m                  выставить зеркало загрузки (http://archive.ubuntu.com/ubuntu/ по умолчанию)";
                  echo "  -h                  вывод этой справки и выход";
                  echo "  -v                  вывод информации о версии и выход";
                  echo -e "\nСообщения о замеченных ошибках отправляйте по адресу <sor.alexei@hotbox.ru>.";
              fi;
              exit 0;
            ;;
            v)
              echo "${Title}";
              exit 0;
            ;;
            *)
              ErrorFunc;
              return 1;
            ;;
        esac;
    done;
    shift "$((OPTIND - 1))";
    return 0;
}

Downloader() {
     if [ -z "$1" ]; then
         if ( ! IsRussian ); then
             echo "Please, define download URL." >&2;
         else
             echo "Пожалуйта, укажите URL для загрузки." >&2;
         fi;
         return 1;
     fi;
     if [ -z "$2" ]; then
         Output="$(basename $1)";
     else
         Output="$2";
     fi;
     if ( which 'curl' > /dev/null ); then
         curl -s -o "${Output}" "$1";
         return $?;
     elif ( which 'wget' > /dev/null ); then
         wget -O "${Output}" -q "$1";
         return $?;
     else
         if ( ! IsRussian ); then
             echo "Please, install curl or wget to proceed." >&2;
         else
             echo "Пожалуйста, установите curl или wget для продолжения." >&2;
         fi;
         exit 1;
     fi;
}

KernelDownload() {
    if ( ! IsRussian ); then
        echo "Initializing Linux kernel v${KernelVersion} packages download...";
    else
        echo "Инициализация загрузки пакетов ядра Linux v${KernelVersion}...";
    fi;
    for Count in $(seq 0 $((URLCount- 1))); do
        if ( ! IsRussian ); then
            echo "Downloading package $((Count + 1)) from ${URLCount}...";
        else
            echo "Загрузка пакета $((Count + 1)) из ${URLCount}...";
        fi;
        if ( ! Downloader "${URLs[${Count}]}" ); then
            if ( ! IsRussian ); then
                echo "An error occured, exiting..." >&2;
            else
                echo "Произошла ошибка, выход..." >&2;
            fi;
            Finish;
            return 1;
        fi;
    done;
    return 0;
}

KernelInstall() {
    if ( ! IsRussian ); then
        echo -e "\nInstalling all downloaded packages...";
    else
        echo -e "\nУстановка всех загруженных пакетов..." >&2;
    fi;
    dpkg -i -R "${PWD}";
    apt-get install -f;
    return $?;
}

Installer() {
    if ( ! KernelDownload ); then
        return 1;
    fi;
    KernelInstall;
}

RepoKernel() {
    if [ -z "${Mirror}" ]; then
        Mirror="http://archive.ubuntu.com/ubuntu/";
    fi;
    Architecture=$(dpkg --print-architecture);

    export KernelVersion=$(Downloader "${Mirror}/pool/main/l/linux/" - | tr '"' '\n' | grep '^linux-image' | \
      sed -n '$p' | tr '_' '\n' | sed -n '2p');
    KernelVersionDot=$(echo "${KernelVersion}" | tr '-' '.');
    KernelVersionMajor=$(echo "${KernelVersion}" | sed -e 's/\.[^.]*$//g');
    KernelMetaVersion=$(Downloader "${Mirror}/pool/main/l/linux-meta/" - | tr '"' '\n' | grep '^linux-image' | \
      sed -n '$p' | tr '_' '\n' | sed -n '2p');

    URLCount=6;
    URLs[0]="${Mirror}/pool/main/l/linux-meta/linux-image-generic_${KernelMetaVersion}_${Architecture}.deb";
    URLs[1]="${Mirror}/pool/main/l/linux-meta/linux-headers-generic_${KernelMetaVersion}_${Architecture}.deb";
    URLs[2]="${Mirror}/pool/main/l/linux/linux-image-${KernelVersionMajor}-generic_${KernelVersion}_${Architecture}.deb";
    URLs[3]="${Mirror}/pool/main/l/linux/linux-image-extra-${KernelVersionMajor}-generic_${KernelVersion}_${Architecture}.deb";
    URLs[4]="${Mirror}/pool/main/l/linux/linux-headers-${KernelVersionMajor}_${KernelVersion}_all.deb";
    URLs[5]="${Mirror}/pool/main/l/linux/linux-headers-${KernelVersionMajor}-generic_${KernelVersion}_${Architecture}.deb";

    Installer;
    ExitCode=$?;

    for Count in $(seq 0 $((URLCount - 1))); do
        Name=$(basename "${URLs[${Count}]}" | tr '_' '\n' | sed -n '1p');
        if [[ ! "${Name}" == 'linux-image-generic' ]] && [[ ! "${Name}" == 'linux-headers-generic' ]]; then
            apt-mark auto "${Name}";
        fi;
    done;
    return "${ExitCode}";
}

PPAKernel() {
    Mirror="http://kernel.ubuntu.com/~kernel-ppa/mainline/";
    Architecture=$(dpkg --print-architecture);

    KernelVersionMajor=$(Downloader "${Mirror}" - | grep -v '\-rc' | \
      sed -n 's/<a href="/\n/p' | tr '"' '\n' | grep '^v' | sed -n '$p');
    KernelVersionData=$(Downloader ${Mirror}/${KernelVersionMajor} - | sed -n 's/<a href="/\n/p' | \
      tr '"' '\n' | grep -m 1 '^linux-image' | tr '_' '\n' | sed -n '2p');
    export KernelVersion=$(echo "${KernelVersionData}" | sed -e 's/\(.*\)\.\([[:digit:]]*\)/\1/');

    URLCount=4;
    URLs[0]="${Mirror}/${KernelVersionMajor}/linux-headers-${KernelVersion}_${KernelVersionData}_all.deb";
    URLs[1]="${Mirror}/${KernelVersionMajor}/linux-headers-${KernelVersion}-generic_${KernelVersionData}_${Architecture}.deb";
    URLs[2]="${Mirror}/${KernelVersionMajor}/linux-image-${KernelVersion}-generic_${KernelVersionData}_${Architecture}.deb";
    URLs[3]="${Mirror}/${KernelVersionMajor}/linux-image-extra-${KernelVersion}-generic_${KernelVersionData}_${Architecture}.deb";

    Installer;
    return $?;
}

PfKernel() {
    Mirror="http://kernel.night-leshiy.ru/";
    Architecture=$(dpkg --print-architecture);
    PageFile="/tmp/linux-kernel-packages/pf-kernel.htm";

    if ( ! Downloader "${Mirror}" - > "${PageFile}" ); then
        if ( ! IsRussian ); then
            echo "An error occured, exiting..." >&2;
        else
            echo "Произошла ошибка, выход..." >&2;
        fi;
        Finish;
        return 1;
    fi;
    export KernelVersion=$(cat "${PageFile}" | grep '\(ubuntu/\|mint/\)' | \
      grep -E -o "([0-9]+\.){2}[0-9]([-a-zA-Z0-9]+)?(_[a-zA-Z0-9])?" | sort -u);

    URLCount=2;
    if [[ $(cat "${PageFile}" | grep -c 'id="ubuntu"' -) != 0 ]]; then
        URLs[0]="${Mirror}/ubuntu/linux-image-${KernelVersion}_${Architecture}.deb";
        URLs[1]="${Mirror}/ubuntu/linux-headers-${KernelVersion}_${Architecture}.deb";
    else
        URLs[0]="${Mirror}/mint/linux-image-${KernelVersion}_${Architecture}.deb";
        URLs[1]="${Mirror}/mint/linux-headers-${KernelVersion}_${Architecture}.deb";
    fi;
    rm -f "${PageFile}";

    Installer;
    return $?;
}

RemoveNonlatestKernels() {
    InstalledKernelPackages=$(dpkg --get-selections | sed -e 's/\t//g;s/install//g' | grep '^linux');
    InstalledKernelPackages=$(echo "${InstalledKernelPackages}" | grep '^linux-image'; \
      echo "${InstalledKernelPackages}" | grep '^linux-headers');
    SavedKernelPackagesCandidates=$(echo "${InstalledKernelPackages}" | grep '^linux-image');
    SavedKernelVersion=$(echo "${SavedKernelPackagesCandidates}" | tr ' ' '\n' | grep -E -o \
      '[[:digit:]]+\.[[:digit:]]+(\.[[:digit:]]+)?(-[[:digit:]]+)?(\.[[:lower:]]+)?' | sort -u --version-sort | sed -n '$p');
    KernelVersionsToRemove=$(echo "${InstalledKernelPackages}" | tr ' ' '\n' | grep -v "\-${SavedKernelVersion}");
    if [[ -z "${KernelVersionsToRemove}" ]]; then
        if ( ! IsRussian ); then
            echo "Nothing to remove, exiting...";
        else
            echo "Нечего удалять, выход...";
        fi;
    else
        apt-get purge ${KernelVersionsToRemove};
    fi;
    return $?;
}

Finish() {
    cd '/';
    rm -rf "/tmp/linux-kernel-packages";
}

argc="$#"; argv="$@";
trap Finish EXIT;
ParamCheck;
if [[ $? != 0 ]]; then
    exit 1;
fi;

if ( ! IsDebianBased ); then
    if ( ! IsRussian ); then
        echo "Running distribution is not Debian-based, executing stopped for safety reason." >&2;
    else
        echo "Запущенный дистрибутив не является основанным на Debian, выполнение остановлено по причинам безопасности." >&2;
    fi;
    exit 1;
fi;

if [[ "$(id -u)" != 0 ]]; then
    if ( which 'sudo' > /dev/null ); then
        sudo bash "$0" $@;
        exit $?;
    else
        su -c bash "$0" $@;
        exit $?;
    fi;
fi;

rm -rf "/tmp/linux-kernel-packages";
mkdir -p "/tmp/linux-kernel-packages";
cd "/tmp/linux-kernel-packages";

if [[ "${UbuntuBranchMode}" == true ]]; then
    if ( ! IsRussian ); then
        Greeter="Latest Linux kernel packages will be installed from Ubuntu branch...";
    else
        Greeter="Последние пакеты ядра Linux будут поставлены из ветки Ubuntu...";
    fi;
elif [[ "${PfKernelMode}" == true ]]; then
    if ( ! IsRussian ); then
        Greeter="Latest pf-kernel packages from NiGHt-LEshiY will be installed...";
    else
        Greeter="Последние пакеты pf-kernel of NiGHt-LEshiY будут поставлены...";
    fi;
elif [[ "${RemoveNonlatestKernelsMode}" == true ]]; then
    if ( ! IsRussian ); then
        Greeter="All nonlatest Linux kernels will be removed...";
    else
        Greeter="Все непоследние ядра Linux будут удалены...";
    fi;
else
    if ( ! IsRussian ); then
        Greeter="Latest Linux kernel packages will be installed from kernel.ubuntu.com...";
    else
        Greeter="Последние пакеты ядра Linux будут поставлены из kernel.ubuntu.com...";
    fi;
fi;

if ( which 'cowsay' > /dev/null ); then
    cowsay -f "tux" "${Greeter}";
else
    echo -e "${Greeter}\n";
fi;

if [[ "${UbuntuBranchMode}" == true ]]; then
    RepoKernel;
    ExitCode=$?;
elif [[ "${PfKernelMode}" == true ]]; then
    PfKernel;
    ExitCode=$?;
elif [[ "${RemoveNonlatestKernelsMode}" == true ]]; then
    RemoveNonlatestKernels;
    ExitCode=$?;
else
    PPAKernel;
    ExitCode=$?;
fi;

if [[ "${ExitCode}" == 0 ]]; then
    if ( ! IsRussian ); then
        echo -e "\nTask completed, thank you for using this script.";
        echo "Script author: XRevan86, inspired by ubuntovod.ru, licensed under GNU GPLv3+";
    else
        echo -e "\nЗадача выполнена, спасибо за использование этого скрипта.";
        echo "Автор скрипта: XRevan86, вдохновлено ubuntovod.ru, лицензировано под GNU GPLv3+";
    fi;
fi;
exit $?;