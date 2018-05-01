VERSION = $(shell cat "VERSION")
PREFIX = tac
BIN = @tac_mods
ZIP = tac_mods
FLAGS = -i include -w redefinition-wo-undef -w unquoted-string -w excessive-concatenation
VERSION_FILES = README.md mod.cpp

MAJOR = $(word 1, $(subst ., ,$(VERSION)))
MINOR = $(word 2, $(subst ., ,$(VERSION)))
PATCH = $(word 3, $(subst ., ,$(VERSION)))
BUILD = $(word 4, $(subst ., ,$(VERSION)))
VERSION_S = $(MAJOR).$(MINOR).$(PATCH)
GIT_HASH = $(shell git log -1 --pretty=format:"%H" | head -c 8)

ifeq ($(OS), Windows_NT)
	ifeq ($(PROCESSOR_ARCHITEW6432), AMD64)
		ARMAKE = ./tools/armake_w64.exe
	else
		ifeq ($(PROCESSOR_ARCHITECTURE), AMD64)
			ARMAKE = ./tools/armake_w64.exe
		else
			ARMAKE = ./tools/armake_w32.exe
		endif
	endif
else
	ARMAKE = armake
endif

$(BIN)/addons/$(PREFIX)_%.pbo: addons/%
	@mkdir -p $(BIN)/addons
	@echo "  PBO  $@"
	@${ARMAKE} build ${FLAGS} -f -e "version=$(GIT_HASH)" $< $@

$(BIN)/optionals/$(PREFIX)_%.pbo: optionals/%
	@mkdir -p $(dir $@)$(BIN)_$*/addons
	@echo "  PBO  $@"
	@${ARMAKE} build ${FLAGS} -f -e "version=$(GIT_HASH)" $< $(dir $@)$(BIN)_$*/addons/$(notdir $@)

# Shortcut for building single addons (eg. "make <component>.pbo")
%.pbo:
	"$(MAKE)" $(MAKEFLAGS) $(patsubst %, $(BIN)/addons/$(PREFIX)_%, $@)

all: $(patsubst addons/%, $(BIN)/addons/$(PREFIX)_%.pbo, $(wildcard addons/*)) \
		$(patsubst optionals/%, $(BIN)/optionals/$(PREFIX)_%.pbo, $(wildcard optionals/*))

filepatching:
	"$(MAKE)" $(MAKEFLAGS) FLAGS="-w unquoted-string -p"

$(BIN)/keys/%.biprivatekey:
	@mkdir -p $(BIN)/keys
	@echo "  KEY  $@"
	@${ARMAKE} keygen -f $(patsubst $(BIN)/keys/%.biprivatekey, $(BIN)/keys/%, $@)

$(BIN)/addons/$(PREFIX)_%.pbo.$(PREFIX)_$(VERSION)-$(GIT_HASH).bisign: $(BIN)/addons/$(PREFIX)_%.pbo $(BIN)/keys/$(PREFIX)_$(VERSION).biprivatekey
	@echo "  SIG  $@"
	@${ARMAKE} sign -f -s $@ $(BIN)/keys/$(PREFIX)_$(VERSION).biprivatekey $<

$(BIN)/optionals/$(PREFIX)_%.pbo.$(PREFIX)_$(VERSION)-$(GIT_HASH).bisign: $(BIN)/optionals/$(PREFIX)_%.pbo $(BIN)/keys/$(PREFIX)_$(VERSION).biprivatekey
	@echo "  SIG  $@"
	@${ARMAKE} sign -f -s $(dir $@)$(BIN)_$*/addons/$(notdir $@) $(BIN)/keys/$(PREFIX)_$(VERSION).biprivatekey $(dir $@)$(BIN)_$*/addons/$(PREFIX)_$*.pbo

signatures: $(patsubst addons/%, $(BIN)/addons/$(PREFIX)_%.pbo.$(PREFIX)_$(VERSION)-$(GIT_HASH).bisign, $(wildcard addons/*)) \
		$(patsubst optionals/%, $(BIN)/optionals/$(PREFIX)_%.pbo.$(PREFIX)_$(VERSION)-$(GIT_HASH).bisign, $(wildcard optionals/*))

extensions: $(wildcard extensions/*/*)
	cd extensions/build && cmake .. && make
	find ./extensions/build/ \( -name "*.so" -o -name "*.dll" \) -exec cp {} ./ \;

extensions-win64: $(wildcard extensions/*/*)
	cd extensions/build && CXX=$(eval $(which g++-w64-mingw-i686)) cmake .. && make

release: clean
	@"$(MAKE)" $(MAKEFLAGS) signatures
	@echo "  ZIP  $(ZIP)_$(VERSION).zip"
	@cp *.dll AUTHORS.txt LICENSE logo_tac_ca.paa logo_tac_small_ca.paa mod.cpp README.md $(BIN)
	@zip -qr $(ZIP)_$(VERSION).zip $(BIN)

version:
	@echo "  VER  $(VERSION)"
	$(shell sed -i -r -s 's/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/$(VERSION)/g' $(VERSION_FILES))
	$(shell sed -i -r -s 's/[0-9]+\.[0-9]+\.[0-9]+/$(VERSION_S)/g' $(VERSION_FILES))
	@echo "#define MAJOR $(MAJOR)\n#define MINOR $(MINOR)\n#define PATCHLVL $(PATCH)\n#define BUILD $(BUILD)" > "addons/main/script_version.hpp"
	@echo "#define TAC_VERSION_MAJOR $(MAJOR)\n#define TAC_VERSION_MINOR $(MINOR)\n#define TAC_VERSION_PATCH $(PATCH)\n#define TAC_VERSION_BUILD $(BUILD)" > "extensions/src/common/version.h"

commit:
	@echo "  GIT  prepare release v$(VERSION_S)"
	@git add -A
	@git diff-index --quiet HEAD || git commit -am "Prepare release $(VERSION_S)" -q

publish: version commit release
	@echo "  GIT  publish v$(VERSION_S)"
	@git push -q
	@git tag v$(VERSION_S)
	@git push origin v$(VERSION_S) -q

clean:
	rm -rf $(BIN) $(ZIP)_*.zip

.PHONY: all filepatching signatures extensions extensions-win64 release version commit publish clean
