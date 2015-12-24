package edu.unh.sr.picturepost;


public class BatchUploadException extends RuntimeException {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String message;
    BatchUploadException(String msg) {
        message = msg;
    }
    public String getMessage() {
        return this.message;
    }
    public String toString() {
        return this.message;
    }
}
