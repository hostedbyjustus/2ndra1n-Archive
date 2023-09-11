
# !/bin/bash

set -e
clear

bold=$(tput bold)
normal=$(tput sgr0)

platform=$(uname)
platformDir=$(pwd)

if [ "$platform" = 'Darwin' ]; then
    dir='bin/osx'
elif [ "$platform" = 'Linux' ]; then
    dir='bin/linux'
else
    echo "[x] OS not supported"
    exit 1
fi


# -------------------------
# Let's create some functions
#--------------------------

detect_device(){
    if [ "$platform" = 'Darwin' ]; then
        # macOS -> Get device info from System Profiler
        system_profiler="$(system_profiler SPUSBDataType 2> /dev/null)"
        applesn="$(printf '%s' "$system_profiler" | grep -B1 'Vendor ID: 0x05ac' | grep 'Product ID:' | cut -dx -f2 | cut -d' ' -f1 | tail -r)"
    elif [ "$platform" = 'Linux' ]; then
        # Linux -> Get device info from lsusb
        lsusb="$(lsusb)"
        applesn="$(lsusb | cut -d' ' -f6 | grep '05ac:' | cut -d: -f2)"
    else
        echo "[x] OS not supported"
        exit 1
    fi

    local countDevice=0
    local serialUSB=""
    for apple in $applesn; do
        case "$apple" in
            12a8|12aa|12ab)
            device_mode=normal
            countDevice=$((countDevice+1))
            ;;
            1281)
            device_mode=recovery
            countDevice=$((countDevice+1))
            ;;
            1227)
            device_mode=dfu
            countDevice=$((countDevice+1))
            ;;
            1222)
            device_mode=diag
            countDevice=$((countDevice+1))
            ;;
            1338)
            device_mode=checkra1n_stage2
            countDevice=$((countDevice+1))
            ;;
            4141)
            device_mode=pongo
            countDevice=$((countDevice+1))
            ;;
        esac
    done
    if [ "$countDevice" = "0" ]; then
        device_mode=none
    elif [ "$countDevice" -ge "2" ]; then
        echo "[~] Please attach only one device" > /dev/tty
        kill -30 0
        exit 1;
    fi
    if [ "$os" = "Linux" ]; then
        usbserials=$(cat /sys/bus/usb/devices/*/serial)
    elif [ "$os" = "Darwin" ]; then
        usbserials=$(printf '%s' "$sp" | grep 'Serial Number' | cut -d: -f2- | sed 's/ //')
    fi
    if grep -qE '(ramdisk tool|SSHRD_Script) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{1,2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}' <<< "$usbserials"; then
        device_mode=ramdisk
    fi
    echo "$device_mode"
}

chars="/-\|"

# -------------------------
# Let's begin
#--------------------------

getDevice(){
    while [ "$(detect_device)" = "none" ]; do
        for (( i=0; i<${#chars}; i++ )); do
            sleep 0.5
            echo -en "[${chars:$i:1}] Waiting for your device to connect" "\r"
        done
    done
    echo "[✓] Connected"
    echo $(echo "[~] Detected device in $bold$(detect_device)$normal mode" | sed 's/dfu/DFU/')

    if grep -E 'pongo|checkra1n_stage2|diag' <<< "$(detect_device)"; then
        echo "[-] Detected device in unsupported mode '$(detect_device)'"
        exit 1;
    fi
}

# -------------------------
# OS Specific Variables
#--------------------------


# -------------------------
# Setup... creating folders
#--------------------------

create(){
    echo "[✓] Trying to create ipsw folder"
    if [ -d ipsw/ ]; then
        echo "[~] ipsw folder already exists... skipping"
        sleep 1
    else
        mkdir -p ipsw
        echo "[✓] ipsw folder created"
        sleep 1
    fi

    echo "[✓] Trying to create ramdisk folder"
    sleep 1
    if [ -d ramdisk/ ]; then
        echo "[~] ramdisk folder already exists... skipping"
        sleep 1
    else
        echo "[✓] Cloning into ramdisk/..."
        git clone https://github.com/nocontent06/2ndra1n_ramdisk.git ramdisk/
        echo "[✓] ramdisk/ cloned"
        
        sleep 1
    fi

    echo "[✓] Trying to locate bin/ folder"
    sleep 1
    if [ -d bin/ ]; then
        echo "[✓] bin folder exists... very good :)"
        echo "[✓] Making bin/ executable"
        chmod +x bin/*
        sleep 1
    else
        echo "[x] An error occured while trying to locate bin/ folder"
        exit 1
    fi
}


# Variables

ipsw="ipsw/*.ipsw"
ramdisk="ramdisk/"


# Supported iOS Versions for each iPhone/iPad/iPod

# Get Device Info

device_info(){
    # THANKS EDWIN XD
    if [ "$1" = 'recovery' ]; then
        echo $("$dir"/irecovery -q | grep "$2" | sed "s/$2: //")
    elif [ "$1" = 'normal' ]; then
        echo $("$dir"/ideviceinfo | grep "$2: " | sed "s/$2: //")
    fi
}

# Function for setting autoboot to true

setAutoBoot() {
    "$dir"/irecovery -c "setenv auto-boot true"
    "$dir"/irecovery -c "saveenv"
}

# Function for wating for device

waitForDevice() {
    if [ "$(detect_device)" != $1 ]; then
        echo "[~] Waiting for your device to enter $1 mode"
    fi

    while [ "$(detect_device)" != $1 ]; do
        sleep 0.5
    done

    if [ "$(detect_device)" = $1 ]; then
        echo "[✓] Connected device in $1 mode"
        setAutoBoot;
    fi

}

# Main

setup() {
    echo "[✓] Before we begin... connect your device to your computer (The mode is unnecessary)"
    sleep 0.5
    getDevice
    if [ "$(detect_device)" = "normal" ]; then
        echo "[^] Hey! You're an $(device_info normal ProductType) on $(device_info normal ProductVersion)"   
        echo "[✓] Put this iPhone in recovery mode..."
        "$dir"/ideviceenterrecovery $(device_info normal UniqueDeviceID)
    elif [ "$(detect_device)" = "recovery" ]; then
        echo "[^] Hey! You're an $(device_info recovery PRODUCT)!"
    fi
    create
    waitForDevice normal
}

boot(){
    echo "[✓] Start booting..."
    pwnDevice
    sleep 1
    resetDevice

    echo "[✓] Booting device..."
    "$dir"/irecovery -f "boot/$deviceID-"
}

setup







deviceID=$(device_info recovery PRODUCT)
version=$(device_info recovery ProductVersion)


