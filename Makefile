NAME = artist-sdk
VERSION = 0.0.1
OUTPUT_FILE_NAME = $(NAME)-$(VERSION)
COMMON_FILES = include toolchain makefiles

.PHONY: fetch
fetch:
	cd src && ./fetch.sh

.PHONY: zip
zip:
	mkdir -p releases && cd src && zip -r "../releases/$(OUTPUT_FILE_NAME).zip" $(COMMON_FILES)  install.sh

.PHONY: rpm
rpm:
	mkdir -p releases
	mkdir -p rpmbuild/SOURCES/$(OUTPUT_FILE_NAME)
	cd src && cp -r $(COMMON_FILES) LICENSE Makefile ../rpmbuild/SOURCES/$(OUTPUT_FILE_NAME)/
	cd rpmbuild/SOURCES && tar -zcf $(OUTPUT_FILE_NAME).tar.gz $(OUTPUT_FILE_NAME) && rm -r $(OUTPUT_FILE_NAME)
	rpmbuild -bb rpmbuild/SPECS/$(NAME).spec
	mv rpmbuild/RPMS/x86_64/*.rpm releases/
	rm -r rpmbuild/BUILD/* rpmbuild/RPMS/* rpmbuild/SOURCES/*

.PHONY: deb
deb:
	mkdir -p releases 
	cd debian/ && rm -r $(OUTPUT_FILE_NAME) $(NAME)_$(VERSION).orig.tar.gz *.buildinfo *.changes  *.debian.tar.xz  *.dsc 2>/dev/null || true
	mkdir debian/$(OUTPUT_FILE_NAME)
	cd src && cp -r $(COMMON_FILES) Makefile ../debian/$(OUTPUT_FILE_NAME)/
	cd debian && tar -zcf $(NAME)_$(VERSION).orig.tar.gz $(OUTPUT_FILE_NAME)
	cp -r debian/debian debian/$(OUTPUT_FILE_NAME)/
	cd debian/$(OUTPUT_FILE_NAME) && dpkg-buildpackage -us -uc
	mv debian/*.deb releases/

.PHONY: clean
clean:
	rm -rf releases/*
	
