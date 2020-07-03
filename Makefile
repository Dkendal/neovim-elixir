SRC_FILES = $(shell find lib config mix.* -type f)

all: clean build

install: build
	yes | mix escript.install ./bin/nvim_elixir_host

uninstall:
	yes | mix escript.uninstall nvim_elixir_host

.PHONY: test
test: vim-test

.PHONY: vim-test
vim-test: build
	./test/vim_test_runner

build: bin/nvim_elixir_host

bin:
	mkdir bin

bin/nvim_elixir_host: bin ${SRC_FILES}
	mix escript.build

.PHONY: clean
clean:
	rm ./bin/nvim_elixir_host
