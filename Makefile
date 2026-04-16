SHELL := /bin/sh

NODE ?= yarn
BUNDLE ?= bundle

.PHONY: help install install-js install-ruby generate verify-generated test build format clean ci

help:
	@printf "%s\n" \
		"Targets:" \
		"  make install            Install Yarn tooling and Ruby gem dependencies" \
		"  make install-js         Install Yarn tooling with frozen lockfile" \
		"  make install-ruby       Install Ruby gem dependencies with Bundler" \
		"  make generate           Regenerate checked-in OpenAPI and generated client artifacts" \
		"  make verify-generated   Verify checked-in generated artifacts are current" \
		"  make test               Run the RSpec test suite" \
		"  make build              Build the Ruby gem" \
		"  make format             Run repository formatting" \
		"  make clean              Remove local build artifacts" \
		"  make ci                 Run generation verification, tests, and gem build"

install: install-js install-ruby

install-js:
	$(NODE) install --frozen-lockfile

install-ruby:
	$(BUNDLE) install

generate:
	$(NODE) generate

verify-generated:
	$(NODE) verify-generated

test:
	$(BUNDLE) exec rspec

build:
	$(BUNDLE) exec gem build imgwire.gemspec

format:
	$(NODE) format

clean:
	rm -rf pkg *.gem

ci: verify-generated test build
