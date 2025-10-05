module.exports.handler = async (event) => {
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