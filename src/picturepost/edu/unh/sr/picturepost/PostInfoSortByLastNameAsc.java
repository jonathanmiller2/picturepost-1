package edu.unh.sr.picturepost;

import java.util.*;


public class PostInfoSortByLastNameAsc implements Comparator<PostInfo> {

    public int compare(PostInfo e1, PostInfo e2) {
        return e1.getLastName().compareToIgnoreCase(e2.getLastName());
    }
}

