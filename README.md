# Serverless Image Resizing

## Description

Resizes images on the fly using Amazon S3, AWS Lambda, and Amazon API Gateway. Using a conventional URL structure and S3 static website hosting with redirection rules, requests for resized images are redirected to a Lambda function via API Gateway which will resize the image, upload it to S3, and redirect the requestor to the resized image. The next request for the resized image will be served from S3 directly.

## Usage

The complete setup can be done with Docker. Therefore you only need to [install][docker] it.

1. Build the Lambda function

   The Lambda function uses [sharp][sharp] for image resizing which requires native extensions. In order to run on Lambda, it must be packaged on Amazon Linux. You can accomplish this in one of two ways:

   - Upload the contents of the `lambda` subdirectory to a [Amazon EC2 instance running Amazon Linux][amazon-linux] and run `npm install`, or

   - Use the lambci/lambda:build-nodejs6.10 Docker image to build the package using your local system. Run `docker run --rm --volume //${PWD}:/var/task lambci/lambda:build-nodejs6.10 sh -c "cd lambda && zip -r ../dist/function.zip *"`.

1. Deploy the CloudFormation stack

  The deployment script requires the [AWS CLI][cli] version 1.11.19 or newer to be installed. This is brought to you by using my own Docker image [grolland/aws-cli][dockeraws]. You need to provide your AWS credentials as environment variables. It is best to put _AWS_DEFAULT_REGION_, _AWS_ACCESS_KEY_ID_ and _AWS_SECRET_ACCESS_KEY_ in a properties file and pass it to the Docker container.

  Deploy everything with `docker run --rm -it --env-file ../../aws/.aws -e STACK_NAME=Resize-Develop -v //${PWD}:/build --entrypoint bash grolland/aws-cli -c "bin/deploy"`

1. Test the function

	Upload an image to the S3 bucket and try to resize it via your web browser to different sizes, e.g. with an image uploaded in the bucket called image.png:

	- http://[BucketWebsiteHost]/300x300/path/to/image.png
	- http://[BucketWebsiteHost]/90x90/path/to/image.png
	- http://[BucketWebsiteHost]/40x40/path/to/image.png

	You can find the BucketWebsiteUrl in the table of outputs displayed on a successful invocation of the deploy script.

**Note:** If you create the Lambda function yourself, make sure to select Node.js version 6.10.

## License

This reference architecture sample is [licensed][license] under Apache 2.0.

[license]: LICENSE
[sharp]: https://github.com/lovell/sharp
[amazon-linux]: https://aws.amazon.com/blogs/compute/nodejs-packages-in-lambda/
[cli]: https://aws.amazon.com/cli/
[docker]: https://www.docker.com/products/docker
[dockeraws]: https://hub.docker.com/r/grolland/aws-cli/