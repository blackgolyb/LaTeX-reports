export DOCKER_DEFAULT_PLATFORM=linux/amd64
PROJECT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))


ENV_FILE ?= $(realpath ./.env)

ifeq ($(ENV_FILE),)
ENV_FILE := $(realpath ../.env)
ifeq ($(ENV_FILE),)
$(error .env file must be in this folder on parent folder)
endif
endif

include $(ENV_FILE)

SRC_FOLDER		:= $(abspath $(SRC_FOLDER))
REPORTS_FOLDER	:= $(abspath $(REPORTS_FOLDER))
PROFILES_FOLDER	:= $(abspath $(PROFILES_FOLDER))
BUILD_FOLDER	:= $(abspath $(BUILD_FOLDER))
BUILDS_FOLDER	:= $(abspath $(BUILDS_FOLDER))
CODE_FOLDER		:= $(abspath $(CODE_FOLDER))

export SRC_FOLDER
export REPORTS_FOLDER
export PROFILES_FOLDER
export BUILD_FOLDER
export BUILDS_FOLDER
export CODE_FOLDER
export MAIN_FILE
export LATEX_PROGRAM
export LATEX_ARGS

# check required variables
ifeq ($(REPORT),)
$(error REPORT variable must be set)
endif
ifeq ($(PROFILE),)
$(error PROFILE variable must be set)
endif

define settings_content
\newcommand{\reportDirectory}{\reportBaseDirectory/${REPORT}}
\input{/profiles/${PROFILE}/profile.tex}
endef
export settings_content



all: build post_build

write_settings:
	echo "$$settings_content" > ${PROJECT_DIR}/src/settings.tex

post_build:
	cp ${BUILD_FOLDER}/main.pdf ${BUILDS_FOLDER}/${REPORT}.pdf

build: write_settings
	docker compose -f ${PROJECT_DIR}/containers/docker-compose.yml up

rebuild: write_settings
	docker compose -f ${PROJECT_DIR}/containers/docker-compose.yml up --build

build_locale: write_settings
	mkdir -p ${BUILD_FOLDER} && \
	cd src \
	&& ${LATEX_PROGRAM} ${LATEX_ARGS} -output-directory=${BUILD_FOLDER} ${MAIN_FILE}\
	&& cd ../


.PHONY: all build rebuild build_locale write_settings
