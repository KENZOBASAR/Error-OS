pacman -S dialog
dd if=/dev/zero of=floppy.img bs=512 count=2880
dd if=hs.bin of=floppy.img conv=notrunc
dialog --title " Message " --msgbox " Done making img file!", 10 30