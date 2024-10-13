export DOCKER_DEFAULT_PLATFORM=linux/amd64
PROJECT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))



SRC_FOLDER		= ./src
REPORTS_FOLDER	= ./src/reports
BUILD_FOLDER	= ./build
CODE_FOLDER		= ../code

MAIN_FILE		= main.tex

LATEX_PROGRAM	= xelatex
LATEX_ARGS		=

PROFILE			?= default
REPORT			?= templates/lab



SRC_FOLDER		:= $(abspath $(SRC_FOLDER))
REPORTS_FOLDER	:= $(abspath $(REPORTS_FOLDER))
BUILD_FOLDER	:= $(abspath $(BUILD_FOLDER))
CODE_FOLDER		:= $(abspath $(CODE_FOLDER))

export SRC_FOLDER
export REPORTS_FOLDER
export BUILD_FOLDER
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
\input{profiles/${PROFILE}/profile.tex}
\newcommand{\reportDirectory}{\reportBaseDirectory/${REPORT}}
endef
export settings_content



all: write_settings build

write_settings:
	echo "$$settings_content" > ${PROJECT_DIR}/src/settings.tex

build:
	docker compose -f ${PROJECT_DIR}/containers/docker-compose.yml up

rebuild:
	docker compose -f ${PROJECT_DIR}/containers/docker-compose.yml up --build

build_locale:
	mkdir -p ${BUILD_FOLDER} && \
	cd src \
	&& ${LATEX_PROGRAM} ${LATEX_ARGS} -output-directory=${BUILD_FOLDER} ${MAIN_FILE}\
	&& cd ../


.PHONY: all build rebuild build_locale write_settings
