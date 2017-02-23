var AWS = require('aws-sdk');
var S3 = new AWS.S3();
var Sharp = require('sharp');

var BUCKET = process.env.BUCKET;
var URL = process.env.URL;

exports.handler = function(event, context) {
  var key = event.queryStringParameters.key;
  var match = key.match(/(\d*)x(\d*)\/(.*)/);
  var width = parseInt(match[1], 10) || null;
  var height = parseInt(match[2], 10) || null;
  var originalKey = match[3];

  var contentType;

  S3.getObject({Bucket: BUCKET, Key: originalKey}).promise()
    .then(function(data) {
        contentType=data.ContentType;
        return Sharp(data.Body)
        .rotate()
        .resize(width, height)
        .toBuffer()
      }
    )
    .then((buffer) => S3.putObject({
        Body: buffer,
        Bucket: BUCKET,
        ContentType: contentType,
        Key: key
      }).promise()
    )
    .then(() => context.succeed({
        statusCode: '301',
        headers: {'location': `${URL}/${key}`},
        body: ''
      })
    )
    .catch((err) => context.fail(err))
}
