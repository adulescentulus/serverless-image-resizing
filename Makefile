.PHONY: all image package dist deploy clean

all: image dist

image:
	docker build --tag amazonlinux:nodejs .

awsconfigure:
	docker run -it --rm --volume ${PWD}/../.aws:/root/.aws amazonlinux:nodejs aws configure

package:
	docker run --rm --volume ${PWD}/lambda:/var/task --volume imgresize-modules:/var/task/node_modules lambci/lambda:build-nodejs6.10 npm install --production

dist: package
	docker run --rm --volume ${PWD}/lambda:/var/task --volume imgresize-modules:/var/task/node_modules -v ${PWD}/dist:/dist lambci/lambda:build-nodejs6.10 sh -c 'zip -r /dist/function.zip *'

deploy:
	docker run --rm --volume ${PWD}:/build -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY amazonlinux:nodejs bin/deploy

clean:
	docker volume ls | grep imgresize-modules && docker volume rm imgresize-modules || echo no existing volume
	rm -f ./dist/function.zip
