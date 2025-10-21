
const processRecord = (eventRecord) => {
  let contentJSON = eventRecord ? eventRecord.body : {};
  if (typeof contentJSON === "string") {
    contentJSON = JSON.parse(contentJSON);
  }
  let content = `Body bucket: ${contentJSON?.bucket}, key: ${contentJSON?.key}`;
  console.log(content);
  return contentJSON;
};

module.exports.handler = async (event) => {
  //let eventRecord;
  // There are events where the body has multiple records
  if (Array.isArray(event.Records)) {
    console.log("Multiple records found, processing the first one only");
    //eventRecord = event.Records[0];
    event.Records.forEach(element => {
      processRecord(element);
    });
  }
  else {
    processRecord(event);
    //eventRecord = event;
  }

  // let contentJSON = eventRecord ? eventRecord.body : {};
  // if (typeof contentJSON === "string") {
  //   contentJSON = JSON.parse(contentJSON);
  // }
  // let content = `Body bucket: ${contentJSON?.bucket}, key: ${contentJSON?.key}`;
  // console.log(content);

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