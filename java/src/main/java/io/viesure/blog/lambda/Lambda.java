package io.viesure.blog.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

public class Lambda implements RequestHandler<Request, Response> {

    @Override
    public Response handleRequest(Request request, Context context) {
        try {
            // workaround for body handling
            RequestBody requestBody = new ObjectMapper().readValue(request.getBody(), RequestBody.class);
            int limit = requestBody.limit;
            int sign = 1;
            int edge = 1;
            int currentValue = 0;
            int iterations = 0;

            while (currentValue < limit) {
                currentValue += sign;
                iterations += 1;
                if (currentValue * sign >= edge) {
                    edge += 1;
                    sign *= -1;
                    //System.out.println("----");
                }
                //System.out.println(currentValue);
            }

            return new Response(200, "Done!", currentValue, iterations);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

}
