.PHONY: all image push

KMODVER := eea9cbc
IMAGE_REGISTRY ?= quay.io/ryan_raasch
BUILDTOOL ?= docker

DRIVER_TOOLKIT  = registry.redhat.io/openshift4/driver-toolkit-rhel8

PKI_PATH ?= $(shell echo $$HOME)/pems/export/entitlement_certificates/pki.key

OCP_KVER_4_6    = 4.18.0-193.56.1.el8_2.x86_64
OCP_KVER_4_7    = 4.18.0-240.22.1.el8_3.x86_64

BUILD_ARGS_OCP_4_6 = --build-arg KVER=$(OCP_KVER_4_6) --build-arg BUILD_IMAGE_BASE=$(DRIVER_TOOLKIT):v4.6.0
BUILD_ARGS_OCP_4_7 = --build-arg KVER=$(OCP_KVER_4_7) --build-arg BUILD_IMAGE_BASE=$(DRIVER_TOOLKIT):v4.7.0

BUILDTOOL?= docker

all: ocp-4.6 ocp-4.7

pem:
	cp -v $(PKI_PATH) pki.key

ocp-4.6: pem
	$(BUILDTOOL) build . $(BUILD_ARGS_OCP_4_6) -t $(IMAGE_REGISTRY)/dfl-drivercontainer:ocp-4.6-$(KMODVER)

ocp-4.7: pem
	$(BUILDTOOL) build . $(BUILD_ARGS_OCP_4_7) -t $(IMAGE_REGISTRY)/dfl-drivercontainer:ocp-4.7-$(KMODVER)

push:
	$(BUILDTOOL) push $(IMAGE_REGISTRY)/dfl-drivercontainer:ocp-4.6-$(KMODVER)
	$(BUILDTOOL) push $(IMAGE_REGISTRY)/dfl-drivercontainer:ocp-4.7-$(KMODVER)

