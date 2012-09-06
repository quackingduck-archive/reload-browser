all : npm crx

# ---

# NPM Package

# The js file paths to build
COFFEE = $(shell find src -name "*.coffee")
JS = $(COFFEE:src%.coffee=lib%.js)

# Task to build all js files
npm : $(JS)

# How a single js file should be built
lib/%.js : src/%.coffee
	./node_modules/.bin/coffee --compile --lint --output lib $<

# ---

# Chrome Extension

# The filename of the chrome extension
CRX_DIR = browser-extensions/chrome
CRX_VERSION = $(shell cat $(CRX_DIR)/manifest.json | grep version | grep -o [[:digit:]]\.[[:digit:]]\.[[:digit:]])
CRX_FILE = reload-browser-v$(CRX_VERSION).zip

# Task to build chrome extension
crx : $(CRX_FILE)

# How chrome extension should be built
$(CRX_FILE) : $(CRX_SOURCES)
	cd $(CRX_DIR) && zip ../build/$(CRX_FILE) *

# ---

clean :
	rm -rf $(JS) $(CRX_FILE)
