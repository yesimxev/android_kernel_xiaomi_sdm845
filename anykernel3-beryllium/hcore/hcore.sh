### Some of the stuff is from https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-project/-/blob/master/nethunter-installer/boot-patcher/anykernel.sh

OUTFD=$1;

# set up working directory variables
[ "$hhome" ] || home=$PWD;
hbin=$home/hcore;
hpath=/mnt/system

# System partition (Device specific, change if u wanna use it for others)
hsystem=/dev/block/sde48

mount_sysrw() {
umount -l /mnt/system
mount $hsystem $hpath
}

umount_sysrw() {
umount -l /mnt/system
}

insert_after_last() {
	grep -q "^$3$" "$1" || {
		line=$(($(grep -n "^[[:space:]]*$2[[:space:]]*$" "$1" | tail -1 | cut -d: -f1) + 1));
		sed -i "${line}i$3" "$1";
	}
}

install() {
	setperm "$2" "$3" "$home$1";
	if [ "$4" ]; then
		cp -r "$home$1" "$(dirname "$4")/";
		return;
	fi;
	cp -r "$home$1" "$(dirname "$1")/";
}


patch_initrc() {
ui_print " "
ui_print "[!] Patching init.rc"


if [ ! "$(grep /init.nethunter.rc $SYSTEM_ROOT/init.rc)" ]; then
  insert_after_last "$SYSTEM_ROOT/init.rc" "import .*\.rc" "import /init.nethunter.rc";
fi;

}

patch_ueventrc() {
ui_print " "
ui_print "Patching ueventd.rc"

if [ ! "$(grep /dev/hidg* $SYSTEM_ROOT/ueventd.rc)" ]; then
  insert_after_last "$SYSTEM_ROOT/ueventd.rc" "/dev/kgsl.*root.*root" "# HID driver\n/dev/hidg* 0666 root root";
fi;

}

install_nhscript() {
ui_print "Installing hid scripts"
cp -rf $hhome/hcore/init.nethunter.rc /mnt/system/init.nethunter.rc

}

hcore() {
ui_print " "
ui_print "HCORE patcher for beryllium."
ui_print "HCORE ver: 1.0.0"

mount_sysrw;

patch_initrc;

patch_ueventrc;

install_nhscript;

umount_sysrw;
}