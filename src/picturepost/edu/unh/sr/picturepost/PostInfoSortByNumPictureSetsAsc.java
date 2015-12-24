package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByNumPictureSetsAsc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        if (e1.getNumPictureSets() > e2.getNumPictureSets()) return 1;
        if (e1.getNumPictureSets() < e2.getNumPictureSets()) return -1;
        return 0;
    }
}

