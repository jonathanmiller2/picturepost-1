package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByLastNameDesc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        return e2.getLastName().compareToIgnoreCase(e1.getLastName());
    }
}

