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
CRX_BUILD_DIR = browser-extensions/build
CRX_SOURCES = $(shell ls $(CRX_DIR)/*)
CRX_VERSION = $(shell cat $(CRX_DIR)/manifest.json | grep version | grep -o [[:digit:]]\.[[:digit:]]\.[[:digit:]])
CRX_FILE = $(CRX_BUILD_DIR)/reload-browser-v$(CRX_VERSION).crx

# Task to build chrome extension
crx : $(CRX_FILE)

# How chrome extension should be built
$(CRX_FILE) : $(CRX_SOURCES)
	/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
	  --pack-extension=$(CRX_DIR) \
	  --pack-extension-key=notes/chrome-extension.pem
	mkdir -p $(CRX_BUILD_DIR)
	mv $(CRX_DIR).crx $(CRX_FILE)

# ---

clean :
	rm -rf $(JS) $(CRX_FILE)
