.PHONY: all image package dist clean

all: package

image:
	docker build --tag amazonlinux:nodejs .

package:
	docker run --rm --volume ${PWD}/lambda:/var/task --volume lambci-modules:/var/task/node_modules lambci/lambda:build npm install --production

dist: package
	docker run --rm --volume ${PWD}/lambda:/var/task --volume lambci-modules:/var/task/node_modules -v ${PWD}/dist:/dist lambci/lambda:build sh -c 'zip -r /dist/function.zip *'

clean:
	docker volume ls | grep lambci-modules && docker volume rm lambci-modules || echo no existing volume
	rm -f ./dist/function.zip
