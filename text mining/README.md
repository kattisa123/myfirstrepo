# Emotion-based Book Recommendation System

##Description

Implementation of a (very small) proof of concept for a “emotion-based” recommendation system as part of the DMKM Text Mining course assignment.

##Input
File `texts.txt` contains texts and file `titles.txt` (surprise) contains titles of the books of the imaginary digital library. In real scenario they would have been
in the database, I just had some problems loading text with titles to R. Texts
and titles in each file are separated by line breaks. You can add or delete
texts, as long as titles and texts correspond.
##Lexicon
Lexicon is taken from large and famous [NRC Word-Emotion Association Lexicon](http://saifmohammad.com/WebPages/NRC-Emotion-Lexicon.htm).
##Script
The script is devided in two parts, the result (recommendation) is given at
the end of each. First part is the main part of the assignment. It assumes
that the user profile is known. It creates lexicones for each emotion from the
large one, reads and cleans the texts, calculates the emotion scores (based
on the normalised number of matches with each emotion) and compares
them to known user profile. The implementation corresponds to the one I
proposed on the exam.

Second part is the additional feature you asked - automatic evaluation of
the user profile, based on the known id’s of the books he read already. The
script chooses most related book from the list of remaining (unread) books.

P.S. Default user profile parameters can be changed at line 131.
