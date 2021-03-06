#!/bin/sh

LRED="\033[1;31m"
LGRN="\033[1;32m"
LBLU="\033[1;34m"
LCYN="\033[1;36m"
CYAN="\033[0;36m"
YELL="\033[1;33m"
ORNG="\033[0;33m"
GREY="\033[0;37m"
DGRY="\033[1;30m"
NRML="\033[0;00m"
CARRIAGE_RETURN="
"

USERNAME=`whoami`
if [ "${USERNAME}" != "root" ]
then
	echo "\n${YELL}This script must be run as root. Try using '${LBLU}sudo ${0}${YELL}' instead.${NRML}\n"
	exit 1
fi

echo "\n${YELL}Updating apt indexes...${NRML}\n"
apt update

echo "\n${YELL}Installing required packages via apt...${NRML}\n"
apt install -y fbi xserver-xorg-input-evdev

BOOT_CONFIG_CHANGES="dtparam=spi=on\ndtoverlay=piscreen,speed=24000000,rotate=90"

EVDEV_CALIBRATION_XORG_CONF="
Section \"InputClass\"
    Identifier \"calibration\"
    MatchProduct \"ADS7846 Touchscreen\"
    Driver \"evdev\"
    Option \"Calibration\" \"3936 227 268 3880\"
    Option \"InvertX\" \"false\"
    Option \"InvertY\" \"false\"
EndSection
"

echo "\n${YELL}Enabling SPI and PiScreen in '${ORNG}/boot/config.txt${YELL}'...${NRML}\n"
sed -i "s|^[#]dtparam=spi=.*|${BOOT_CONFIG_CHANGES}|" /boot/config.txt

echo "\n${YELL}Changing /dev/fb0 to /dev/fb1 in '${ORNG}/usr/share/X11/xorg.conf.d/99-fbturbo.conf${YELL}'...${NRML}\n"
sed -i "s|/dev/fb0|/dev/fb1|" /usr/share/X11/xorg.conf.d/99-fbturbo.conf

echo "\n${YELL}Adding xorg config file for touchscreen calibration in\n'${ORNG}/etc/X11/xorg.conf.d/99-touchscreen-calibration.conf${YELL}'...${NRML}\n"
if [ ! -d /etc/X11/xorg.conf.d ]
then
	mkdir -p /etc/X11/xorg.conf.d
fi
echo "${EVDEV_CALIBRATION_XORG_CONF}" > /etc/X11/xorg.conf.d/99-touchscreen-calibration.conf

echo "\n${YELL}Enabling SPI and PiScreen in '${ORNG}/boot/config.txt${YELL}'...${NRML}\n"
mv /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf

echo "\n${YELL}Finished! Perform a reboot with the touchscreen attached and hopefully it will be working.${NRML}"
echo "${YELL}Consider enabling SSH in '${LBLU}sudo raspi-config${YELL}' and make note of the IP address to${NRML}"
echo "${YELL}connect to using '${LBLU}ipconfig${YELL}'${NRML}.\n"
