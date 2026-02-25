{ printf '\xEB\xFE'; dd if=/dev/zero bs=1 count=508 2>/dev/null; printf '\x55\xAA'; } > regius.img
