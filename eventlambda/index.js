module.exports.handler = async (event) => {
  let eventRecord;
  // There are events where the body has multiple records
  if (Array.isArray(event.Records)) {
    //console.log("Multiple records found, processing the first one only");
    eventRecord = event.Records[0];
  }
  else {
    eventRecord = event;
  }

  let bodyContent = eventRecord ? eventRecord.body : {};
  let contentJSON;
  if (typeof bodyContent === "string") {
    contentJSON = JSON.parse(bodyContent);
  }
  let content = `Body bucket: ${contentJSON?.bucket}, key: ${contentJSON?.key}`;
  console.log(content);

  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "Next event triggered",
        input: event,
      },
      null,
      2
    ),
  };
};