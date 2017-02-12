.PHONY: all image package dist clean

all: package

image:
	docker build --tag amazonlinux:nodejs docker

package: image
	docker run --rm --volume ${PWD}/lambda:/mnt/build --volume ${PWD}/dist:/mnt/dist amazonlinux:nodejs

dist: package
	cd lambda && zip -r ../dist/function.zip *

clean:
	rm -r lambda/node_modules
	docker rmi --force amazonlinux:nodejs
