GRCC_VERSION=0.3.0
GRCC_DOCKER_IMAGE=macalimlim/godot-rust-cross-compiler
# replace those with your game name/version
GRCC_GAME_PKG_NAME=crosscompilertoy
GRCC_GAME_PKG_VERSION=$(GRCC_VERSION)
# replace cctoy with the name of your rust library
GRCC_GODOT_RUST_LIB_NAME=cctoy
# replace godot-rust-cross-compiler by your repo name
GRCC_GAME_REPO_NAME=godot-rust-cross-compiler

include grcc.mk

all: grcc-all

test: grcc-test

clean: grcc-clean

native: grcc-native

cross: grcc-cross

export: grcc-export

build:
	docker build -t $(GRCC_DOCKER_IMAGE):$(GRCC_VERSION) --build-arg GRCC_VERSION=${GRCC_VERSION} docker/
	docker build -t $(GRCC_DOCKER_IMAGE):latest --build-arg GRCC_VERSION=${GRCC_VERSION} docker/

push:
	docker push $(GRCC_DOCKER_IMAGE):$(GRCC_VERSION)
	docker push $(GRCC_DOCKER_IMAGE):latest

run:
	docker run -it $(GRCC_DOCKER_IMAGE):latest
