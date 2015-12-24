package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByTStampMostRecentPictureSetAsc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        if (e1.getTStampMostRecentPictureSet() == null && e2.getTStampMostRecentPictureSet() == null) return 0;
        if (e1.getTStampMostRecentPictureSet() == null) return -1;
        if (e2.getTStampMostRecentPictureSet() == null) return 1;
        return e1.getTStampMostRecentPictureSet().compareTo(e2.getTStampMostRecentPictureSet());
    }
}

