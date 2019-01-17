/**
 * Pass the data to send as `event.data`, and the request options as
 * `event.options`. For more information see the HTTPS module documentation
 * at https://nodejs.org/api/https.html.
 *
 * Will succeed with the response body.
 */
exports.handler = (event, context, callback) => {
  let limit = event.limit;
  var sign = 1;
  var edge = 1;
  var currentValue = 0;
  var iterations = 0;

  while (currentValue < limit) {
    currentValue += sign;
    iterations += 1;
    if(currentValue * sign >= edge) {
      edge += 1;
      sign *= -1;
      //console.log("----");
    }
    //console.log(currentValue);
  }

  return {
      'statusCode': 200,
      "status": "Done!",
      "result": currentValue,
      "Iterations": iterations
  }

};

console.time("Execution")
let result = exports.handler({limit: 5000}, null, null);
console.timeEnd("Execution");
console.log(JSON.stringify(result))
