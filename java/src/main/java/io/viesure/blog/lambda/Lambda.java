package io.viesure.blog.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class Lambda implements RequestHandler<Request, Response> {

    @Override
    public Response handleRequest(Request request, Context context) {
        int limit = request.getLimit();
        int sign = 1;
        int edge = 1;
        int currentValue = 0;
        int iterations = 0;

        while (currentValue < limit) {
            currentValue += sign;
            iterations += 1;
            if(currentValue * sign >= edge) {
                edge += 1;
                sign *= -1;
                //System.out.println("----");
            }
            //System.out.println(currentValue);
        }

        return new Response(200, "Done!", currentValue, iterations);
    }
}
