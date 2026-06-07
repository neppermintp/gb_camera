##################
# Variables
##################

DATE_FILE := $(shell date "+%Y.%m.%d")
DATE_HEADER := $(shell date "+%B %d, %Y")
BMP_DIR = _RAW

FOLDER := $(shell i=1; \
    while [ -d src/$(DATE_FILE)_$$(printf '%02d' $$i) ]; do \
        i=$$((i+1)); \
    done; \
    echo src/$(DATE_FILE)_$$(printf '%02d' $$i))

##################
# Recipes
##################

.PHONY: dates

dates:
	@echo $(DATE_FILE)
	@echo $(DATE_HEADER)

bmp-dir:
	@if [ ! -d $(BMP_DIR) ]; then \
	mkdir $(BMP_DIR); \
	fi

convert-raw:
	@if [ -z "$(wildcard $(BMP_DIR)/*.bmp)" ]; then \
		echo "No bmp files to convert."; \
	else \
		mogrify -format png $(BMP_DIR)/*.bmp; \
		mkdir $(BMP_DIR)/bmp $(BMP_DIR)/png; \
		mv $(BMP_DIR)/*.bmp $(BMP_DIR)/bmp; \
		mv $(BMP_DIR)/*.png $(BMP_DIR)/png; \
	fi

album-dir:
	echo $(FOLDER)
	mkdir $(FOLDER)

album-assets: convert-raw album-dir
	mv $(BMP_DIR)/png $(FOLDER)
	mv $(BMP_DIR)/bmp $(FOLDER)
	cp templates/gallery.html $(FOLDER)

album-injection:
	sed -i 's/<!-- TITLE -->/$(DATE_FILE)/g' $(FOLDER)/gallery.html
	sed -i 's/<!-- HEADER_1 -->/$(DATE_HEADER)/g' $(FOLDER)/gallery.html
	sed -i 's|<!-- NEW_ENTRY -->|    <!-- NEW_ENTRY -->\n    <dt>$(DATE_HEADER) \&mdash; <a href="./$(FOLDER)/gallery.html">$(FOLDER)</a></dt>|' index.html

album: album-assets album-injection
	@for img in $(FOLDER)/png/*.png; do \
	fname=$$(basename $$img); \
	sed -i 's/<!-- GALLERY -->/<div class="gb_cell"><img src="png\/'"$$fname"'" class="gb_item"><\/div>\n    <!-- GALLERY -->\n/' $(FOLDER)/gallery.html; \
	done

# clean:
# 	rm -rf $(BMP_DIR)
