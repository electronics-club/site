# Makefile based static site generator, depends only on the GNU coreutils (cat, cp, rm, echo)
# The serve target requires python 3.
#
# HTML files in the source directory are prefixed with header.html and footer.html and output to the output tree

# Process a signle file, either concating it with the header and footer or copying it unchanged.
build/%.html: source/%.html header.html footer.html Makefile
	@mkdir -p $(dir $@)
	cat header.html $< footer.html > $@

#build/%: source/%
#	cp $< $@

# Process every file
build: $(patsubst source/%,build/%,$(shell find source -type f))
	@echo Have `find build -type f | wc -l` files and `find build -type d | wc -l` directories

# Remove all files in the build directory
clean:
	-rm -r build/*

# Spin up a simple server to view the results
serve: build
	python -m http.server -d build

# GitHub pages integration, github will have to be configured to serve from the root of the gh-pages branch.
# One time setup for github pages
gh-setup:
	git checkout --orphan gh-pages
	git reset --hard
	git commit --allow-empty -m "Init"
	git checkout main
# Deploy the site to pages
gh-deploy: build
	git worktree add public_html gh-pages
	cp -rf build/* public_html
	cd public_html && \
	git add --all && \
	git commit -m "Deploy to github pages" && \
	git push origin gh-pages
	git worktree remove public_html

.PHONY: build


