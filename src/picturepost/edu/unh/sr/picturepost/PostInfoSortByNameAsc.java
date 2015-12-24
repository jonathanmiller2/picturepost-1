package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByNameAsc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        return e1.getName().compareToIgnoreCase(e2.getName());
    }
}

