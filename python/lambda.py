import json
import time

def lambda_handler(event, context):
    data = json.loads(event["body"])
    limit = data["limit"]
    sign = 1;
    edge = 1
    currentValue = 0;
    iterations = 0

    while currentValue < limit:
        currentValue += sign
        iterations += 1
        if currentValue * sign >= edge:
            edge += 1
            sign *= -1
#            print "----"
#        print currentValue

    body = {
        'status': 'Done!',
        'result': currentValue,
        'iterations': iterations
    }

    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }

#if __name__ == "__main__":
#    start = time.time()
#    result = lambda_handler({'limit': 1000}, {})
#    end = time.time()
#    print("Execution: " + str((end - start)*1000) + "ms")
#    print(result)
