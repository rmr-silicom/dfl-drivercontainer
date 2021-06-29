.PHONY: all image push

KMODVER := eea9cbc
IMAGE_REGISTRY ?= quay.io/ryan_raasch
PODMAN ?= docker
CLI_EXEC ?= bin/oc

KVER_RHEL82 = 4.18.0-193.el8.x86_64
KVER_RHEL83 = 4.18.0-240.el8.x86_64
BUILD_ARGS_RHEL82 = --build-arg CENTOS_VER=docker.io/centos:8.2.2004
BUILD_ARGS_RHEL83 = --build-arg CENTOS_VER=docker.io/centos:8.3.2011
RHEL_VER ?= rhel82

BUILD_ARGS := $(BUILD_ARGS_RHEL82)
ifeq ($(RHEL_VER),rhel83)
BUILD_ARGS := $(BUILD_ARGS_RHEL83)
endif

BUILDTOOL?= podman
IMAGE_NAME := opae

IMAGE := $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(VERSION)

all: image

image:
	$(BUILDTOOL) build . $(CONTAINER_BUILD_ARGS) -t $(IMAGE)

push: image
	$(BUILDTOOL) push $(IMAGE) $(CONTAINER_PUSH_ARGS)

