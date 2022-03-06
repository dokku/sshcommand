.PHONY: ci-dependencies shellcheck bats install lint unit-tests test
NAME = sshcommand
EMAIL = sshcommand@josediazgonzalez.com
MAINTAINER = dokku
MAINTAINER_NAME = Jose Diaz-Gonzalez
REPOSITORY = sshcommand
HARDWARE = $(shell uname -m)
SYSTEM_NAME  = $(shell uname -s | tr '[:upper:]' '[:lower:]')
BASE_VERSION ?= 0.15.0
IMAGE_NAME ?= $(MAINTAINER)/$(REPOSITORY)
PACKAGECLOUD_REPOSITORY ?= dokku/dokku-betafish

ifeq ($(CI_BRANCH),release)
	VERSION ?= $(BASE_VERSION)
	DOCKER_IMAGE_VERSION = $(VERSION)
else
	VERSION = $(shell echo "${BASE_VERSION}")build+$(shell git rev-parse --short HEAD)
	DOCKER_IMAGE_VERSION = $(shell echo "${BASE_VERSION}")build-$(shell git rev-parse --short HEAD)
endif

version:
	@sed -i.bak 's/SSHCOMMAND_VERSION=""/SSHCOMMAND_VERSION="$(VERSION)"/' sshcommand && rm sshcommand.bak
	@echo "$(CI_BRANCH)"
	@echo "$(VERSION)"
	@./sshcommand version


define PACKAGE_DESCRIPTION
Turn SSH into a thin client specifically for your app
Simplifies running a single command over SSH, and
manages authorized keys (ACL) and users in order to do so.
endef

export PACKAGE_DESCRIPTION

LIST = build release release-packagecloud validate
targets = $(addsuffix -in-docker, $(LIST))

.env.docker:
	@rm -f .env.docker
	@touch .env.docker
	@echo "CI_BRANCH=$(CI_BRANCH)" >> .env.docker
	@echo "GITHUB_ACCESS_TOKEN=$(GITHUB_ACCESS_TOKEN)" >> .env.docker
	@echo "IMAGE_NAME=$(IMAGE_NAME)" >> .env.docker
	@echo "PACKAGECLOUD_REPOSITORY=$(PACKAGECLOUD_REPOSITORY)" >> .env.docker
	@echo "PACKAGECLOUD_TOKEN=$(PACKAGECLOUD_TOKEN)" >> .env.docker
	@echo "VERSION=$(VERSION)" >> .env.docker

build: pre-build
	@$(MAKE) build/darwin/$(NAME)
	@$(MAKE) build/linux/$(NAME)
	@$(MAKE) build/deb/$(NAME)_$(VERSION)_all.deb
	@$(MAKE) build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm

build-docker-image:
	docker build --rm -q -t $(IMAGE_NAME):build .

$(targets): %-in-docker: .env.docker
	docker run \
		--env-file .env.docker \
		--rm \
		--volume /var/lib/docker:/var/lib/docker \
		--volume /var/run/docker.sock:/var/run/docker.sock:ro \
		--volume ${PWD}:/src/github.com/$(MAINTAINER)/$(REPOSITORY) \
		--workdir /src/github.com/$(MAINTAINER)/$(REPOSITORY) \
		$(IMAGE_NAME):build make -e $(@:-in-docker=)

build/darwin/$(NAME):
	chmod +x sshcommand
	mkdir -p build/darwin
	cp -f sshcommand build/darwin/sshcommand

build/linux/$(NAME):
	chmod +x sshcommand
	mkdir -p build/linux
	cp -f sshcommand build/linux/sshcommand

build/deb/$(NAME)_$(VERSION)_all.deb: build/linux/$(NAME)
	chmod 644 LICENSE
	export SOURCE_DATE_EPOCH=$(shell git log -1 --format=%ct) \
		&& mkdir -p build/deb \
		&& fpm \
		--architecture all \
		--category admin \
		--description "$$PACKAGE_DESCRIPTION" \
		--input-type dir \
		--license 'MIT License' \
		--maintainer "$(MAINTAINER_NAME) <$(EMAIL)>" \
		--name $(NAME) \
		--output-type deb \
		--package build/deb/$(NAME)_$(VERSION)_all.deb \
		--url "https://github.com/$(MAINTAINER)/$(REPOSITORY)" \
		--vendor "" \
		--version $(VERSION) \
		--verbose \
		build/linux/$(NAME)=/usr/bin/$(NAME) \
		LICENSE=/usr/share/doc/$(NAME)/copyright

build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm: build/linux/$(NAME)
	chmod 644 LICENSE
	export SOURCE_DATE_EPOCH=$(shell git log -1 --format=%ct) \
		&& mkdir -p build/rpm \
		&& fpm \
		--architecture x86_64 \
		--category admin \
		--description "$$PACKAGE_DESCRIPTION" \
		--input-type dir \
		--license 'MIT License' \
		--maintainer "$(MAINTAINER_NAME) <$(EMAIL)>" \
		--name $(NAME) \
		--output-type rpm \
		--package build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm \
		--rpm-os linux \
		--url "https://github.com/$(MAINTAINER)/$(REPOSITORY)" \
		--vendor "" \
		--version $(VERSION) \
		--verbose \
		build/linux/$(NAME)=/usr/bin/$(NAME) \
		LICENSE=/usr/share/doc/$(NAME)/copyright

clean:
	rm -rf build release validation

ci-setup:
	docker version
	rm -f ~/.gitconfig

bin/gh-release:
	mkdir -p bin
	curl -o bin/gh-release.tgz -sL https://github.com/progrium/gh-release/releases/download/v2.3.0/gh-release_2.3.0_$(SYSTEM_NAME)_$(HARDWARE).tgz
	tar xf bin/gh-release.tgz -C bin
	chmod +x bin/gh-release

bin/gh-release-body:
	mkdir -p bin
	curl -o bin/gh-release-body "https://raw.githubusercontent.com/dokku/gh-release-body/master/gh-release-body"
	chmod +x bin/gh-release-body

release: bin/gh-release bin/gh-release-body
	rm -rf release && mkdir release
	tar -zcf release/$(NAME)_$(VERSION)_linux_$(HARDWARE).tgz -C build/linux $(NAME)
	tar -zcf release/$(NAME)_$(VERSION)_darwin_$(HARDWARE).tgz -C build/darwin $(NAME)
	cp build/deb/$(NAME)_$(VERSION)_all.deb release/$(NAME)_$(VERSION)_all.deb
	cp build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm release/$(NAME)-$(VERSION)-1.x86_64.rpm
	bin/gh-release create $(MAINTAINER)/$(REPOSITORY) $(VERSION) $(shell git rev-parse --abbrev-ref HEAD)
	bin/gh-release-body $(MAINTAINER)/$(REPOSITORY) v$(VERSION)

release-packagecloud:
	@$(MAKE) release-packagecloud-deb
	@$(MAKE) release-packagecloud-rpm

release-packagecloud-deb: build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/ubuntu/bionic  build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/ubuntu/focal  build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/debian/stretch build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/debian/buster  build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/debian/bullseye build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/raspbian/buster build/deb/$(NAME)_$(VERSION)_all.deb
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/raspbian/bullseye build/deb/$(NAME)_$(VERSION)_all.deb

release-packagecloud-rpm: build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm
	package_cloud push $(PACKAGECLOUD_REPOSITORY)/el/7           build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm

validate: test
	mkdir -p validation
	lintian build/deb/$(NAME)_$(VERSION)_all.deb || true
	dpkg-deb --info build/deb/$(NAME)_$(VERSION)_all.deb
	dpkg -c build/deb/$(NAME)_$(VERSION)_all.deb
	cd validation && ar -x ../build/deb/$(NAME)_$(VERSION)_all.deb
	cd validation && rpm2cpio ../build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm > $(NAME)-$(VERSION)-1.x86_64.cpio
	ls -lah build/deb build/rpm validation
	sha1sum build/deb/$(NAME)_$(VERSION)_all.deb
	sha1sum build/rpm/$(NAME)-$(VERSION)-1.x86_64.rpm

test: lint unit-tests

lint: shellcheck bats
	@echo linting...
	# SC2034: VAR appears unused - https://github.com/koalaman/shellcheck/wiki/SC2034
	# desc is used to declare the description of the function
	@$(QUIET) find . -not -path '*/\.*' | xargs file | egrep "shell|bash" | awk '{ print $$1 }' | sed 's/://g' | xargs shellcheck -e SC2034

unit-tests: /usr/local/bin/sshcommand
	@echo running unit tests...
	@mkdir -p test-results/bats
	@$(QUIET) TERM=linux bats --formatter bats-format-junit -e -T -o test-results/bats tests/unit

pre-build:
	true

/usr/local/bin/sshcommand:
	@echo installing sshcommand
	cp ./sshcommand /usr/local/bin/sshcommand
	chmod +x /usr/local/bin/sshcommand

shellcheck:
ifneq ($(shell shellcheck --version >/dev/null 2>&1 ; echo $$?),0)
ifeq ($(SYSTEM_NAME),darwin)
	brew install shellcheck
else
	sudo apt-get update -qq && sudo apt-get install -qq -y shellcheck
endif
endif

bats:
ifeq ($(SYSTEM_NAME),darwin)
ifneq ($(shell bats --version >/dev/null 2>&1 ; echo $$?),0)
	brew install bats-core
endif
else
	git clone https://github.com/josegonzalez/bats-core.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats
endif
