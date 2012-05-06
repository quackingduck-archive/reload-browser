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
CRX_SOURCES = $(shell ls chrome-extension/*)
CRX_VERSION = $(shell cat chrome-extension/manifest.json | grep version | grep -o [[:digit:]]\.[[:digit:]]\.[[:digit:]])
CRX_FILE = build/reload-browser-v$(CRX_VERSION).crx

# Task to build chrome extension
crx : $(CRX_FILE)

# How chrome extension should be built
$(CRX_FILE) : $(CRX_SOURCES)
	/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
	  --pack-extension=chrome-extension \
	  --pack-extension-key=notes/chrome-extension.pem
	mkdir -p build
	mv chrome-extension.crx $(CRX_FILE)

# ---

clean :
	rm -rf $(JS) $(CRX_FILE)

