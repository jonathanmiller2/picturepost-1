package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByNameDesc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        return e2.getName().compareToIgnoreCase(e1.getName());
    }
}

