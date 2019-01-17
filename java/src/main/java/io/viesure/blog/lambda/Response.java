package io.viesure.blog.lambda;

public class Response {

    private int statusCode;
    private String status;
    private int result;
    private int iterations;

    public Response(int statusCode, String status, int result, int iterations) {
        this.statusCode = statusCode;
        this.status = status;
        this.result = result;
        this.iterations = iterations;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getResult() {
        return result;
    }

    public void setResult(int result) {
        this.result = result;
    }

    public int getIterations() {
        return iterations;
    }

    public void setIterations(int iterations) {
        this.iterations = iterations;
    }
}
