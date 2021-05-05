include .circleci/.env
export

build:
	bash .circleci/build.sh

deploy:
	bash .circleci/deploy.sh

OS_NAME := $(shell uname -s | tr A-Z a-z)

os:
	@echo $(OS_NAME)