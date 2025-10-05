const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const sqsClient = new SQSClient({ region: process.env.AWS_REGION });

module.exports.handler = async (event) => {
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
  console.log(`s3 object key: ${key} from bucket: ${bucket}`);

  const message = {
    bucket,
    key,
    message: "File processed successfully"
  };

  const command = new SendMessageCommand({
    QueueUrl: process.env.SQS_QUEUE_URL,
    MessageBody: JSON.stringify(message),
  });

  try {
    const data = await sqsClient.send(command);
    console.log("Success, message sent. MessageID:", data.MessageId);
  } catch (err) {
    console.error("Error", err);
  }

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "Updated Serverless Your function executed successfully!",
        input: event,
      },
      null,
      2
    ),
  };
};