SHELL := /bin/sh

NODE ?= yarn
BUNDLE ?= bundle
RUBOCOP_CACHE_ROOT ?= .rubocop_cache

.PHONY: help install install-js install-ruby generate verify-generated test build lint lint-ruby format format-ruby clean ci

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
		"  make lint               Run Ruby linting for handwritten code" \
		"  make lint-ruby          Run RuboCop against lib/ and spec/" \
		"  make format             Run repository formatting" \
		"  make format-ruby        Autoformat handwritten Ruby with RuboCop" \
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

lint: lint-ruby

lint-ruby:
	RUBOCOP_CACHE_ROOT=$(RUBOCOP_CACHE_ROOT) $(BUNDLE) exec rubocop lib spec

format:
	$(MAKE) format-ruby
	$(NODE) format

format-ruby:
	RUBOCOP_CACHE_ROOT=$(RUBOCOP_CACHE_ROOT) $(BUNDLE) exec rubocop -A lib spec

clean:
	rm -rf pkg *.gem $(RUBOCOP_CACHE_ROOT)

ci: verify-generated lint test build
