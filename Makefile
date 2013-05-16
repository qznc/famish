default: partial-mods

VERSION=$(shell git describe --always --tags)

.PHONY: tarball partial-mods clean

tarball:
	rm -rf famish-$(VERSION)
	mkdir famish-$(VERSION)
	cp -rL README.txt game.conf mods -t famish-$(VERSION)/
	tar -cjhf famish-$(VERSION).tar.bz2 famish-$(VERSION)

partial-mods:
	cd partial_mods && ./symlink.sh

clean:
	rm -rf famish-*
