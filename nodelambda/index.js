module.exports.handler = async (event) => {
  console.log("Handler Executed");
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
