package edu.unh.sr.picturepost;


public class IncompleteImageArchiveInUploadException extends RuntimeException {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String message;
    IncompleteImageArchiveInUploadException(String msg) {
        message = msg;
    }
    public String getMessage() {
        return this.message;
    }
    public String toString() {
        return this.message;
    }
}
