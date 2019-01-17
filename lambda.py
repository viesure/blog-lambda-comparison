import json
import time

def lambda_handler(event, context):
    limit = int(event['limit'])
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

    return {
        'statusCode': 200,
        "status": "Done!",
        "Rrsult": currentValue,
        "Iterations": iterations
    }

if __name__ == "__main__":
    start = time.time()
    result = lambda_handler({'limit': 1000}, {})
    end = time.time()
    print("Execution: " + str((end - start)*1000) + "ms")
    print(result)
