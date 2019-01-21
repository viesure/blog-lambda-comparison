package io.viesure.blog.lambda;

public class Response {

    private int statusCode;
    private String body;

    public Response(int statusCode, String status, int result, int iterations) {
        this.statusCode = statusCode;
        this.body = String.format("{\"status\": \"%s\", \"result\": %d, \"iterations\": %d}", status, result, iterations);
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getBody() {
        return body;
    }
}
