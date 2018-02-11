'use strict';

const AWS = require('aws-sdk');
const S3 = new AWS.S3({
  signatureVersion: 'v4',
});
const Sharp = require('sharp');

const BUCKET = process.env.BUCKET;
const URL = process.env.URL;

exports.handler = function(event, context, callback) {
    const key = event.queryStringParameters.key;
    const match = key.match(/(\d*)x(\d*)\/(.*)/);
    const width = parseInt(match[1], 10) || null;
    const height = parseInt(match[2], 10) || null;
    const originalKey = match[3];

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
    .then(buffer => S3.putObject({
        Body: buffer,
        Bucket: BUCKET,
        ContentType: contentType,
        Key: key,
      }).promise()
    )
    .then(() => callback(null, {
        statusCode: '301',
        headers: {'location': `${URL}/${key}`},
        body: '',
      })
    )
    .catch(err => callback(err))
}
