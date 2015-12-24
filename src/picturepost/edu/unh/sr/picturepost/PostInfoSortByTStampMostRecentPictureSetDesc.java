package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByTStampMostRecentPictureSetDesc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        if (e1.getTStampMostRecentPictureSet() == null && e2.getTStampMostRecentPictureSet() == null) return 0;
        if (e1.getTStampMostRecentPictureSet() == null) return 1;
        if (e2.getTStampMostRecentPictureSet() == null) return -1;
        return e2.getTStampMostRecentPictureSet().compareTo(e1.getTStampMostRecentPictureSet());
    }
}

