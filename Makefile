SRC_FILES = $(shell find lib -type f)

all: clean build

build: vim-elixir-host/tools/nvim_elixir_host

.PHONY: run
run: build
	./test/vim_test_runner

vim-elixir-host/tools/nvim_elixir_host: ${SRC_FILES}
	mix escript.build

.PHONY: clean
clean:
	rm vim-elixir-host/tools/nvim_elixir_host
