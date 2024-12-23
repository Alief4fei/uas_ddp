module main.d;

import std.stdio;
import std.string;
import std.file;
import lib;
import std.conv;
import std.string;
import std.array;
import std.algorithm;





void main(string[] args) {
    string[] paths = ["arm_v9", "gpt5", "graphql", "m4_chip", "thunderbolt", "zen5"];
    int wordTotal, word_occTotal;
    int[string][string] word_occurences_per_article;
    int[string] conjTotal;
    int[string] wordOccurences_all;
    int[char] alphaNum_all;
    string[][string] textArticles;

    foreach (string file; paths)
    {
        string[] artc = filtered_text(readText(file));
        textArticles[file] = artc;

        int[string] conj = conj(artc);

        // PROBLEM 1
        // Amount Word per article
        writefln("In article %s", file);

        writefln("There is %d words", artc.length);
        wordTotal += artc.length.to!int;
        writeln("--------------------------------------------------------------------------------");

        // Word Occurences
        int[string] word_occurences = countWordOccur(artc);

        writefln("This article has %d different word, with word occurences : ", word_occurences.length);
        writeln(word_occurences);
        word_occTotal += word_occurences.length.to!int;

        word_occurences_per_article[file] = word_occurences;

        foreach (key, value; word_occurences)
        {
        wordOccurences_all[key] += value;
        }
        
        writeln("--------------------------------------------------------------------------------");
        // Conjunction
        int count_conj = conj.length.to!int;
        writefln("This article has %d different conjunction, with frequency per conjunction :", count_conj);
        foreach (key, value; conj) {
            conjTotal[key] += value; 
            }
        writeln(conj);
        writeln("--------------------------------------------------------------------------------");
        // Alphanumeric occurences
        int[char] alphanumeric = countAlphaNum(artc);
        writefln("This article has %d different alphanumeric, with alphanumeric occurences : ", alphanumeric.length);
        writeln(alphanumeric);

        foreach (key, value; alphanumeric) { 
            alphaNum_all[key] += value; 
            }

        writeln("================================================================================");
    }

    writefln("Total amount words for all article is %s words", wordTotal);
    writefln("For all article have %s different words, with frequency per word :", word_occTotal);
    writeln(wordOccurences_all);
    writeln("--------------------------------------------------------------------------------");
    writefln("For all article have %s different word conjunction, with frequency per conjunction :", conjTotal.length);
    writeln(conjTotal);
    writeln("--------------------------------------------------------------------------------");
    writefln("For all article have %s different alphanumeric, with frequency per alphanumeric :", alphaNum_all.length);
    writeln(alphaNum_all);






    writeln("=======================================Problem 2=================================================");
    string query;
    while (query.empty) {
        write("Type the words you want to search for (at least 2 words): ");
        readf("%s\n", query);

        string[] splitQuery = query.split();

        // Check if the query has at least 2 words
        if (splitQuery.length >= 2) {
            // Combine the first 2 words into the query
            query = splitQuery[0 .. 2].join(" ");
        } else {
            writeln("Please enter at least 2 words for the query.");
            query = ""; // Reset the query to continue the loop
        }
    }

    writeln("Your search query is: ", query);

    string getRelevantArticle = findMostRelevantArticle(query, textArticles);
    writeln("The most relevant article is: ", getRelevantArticle);

    string title = createTitle(word_occurences_per_article[getRelevantArticle]);
        writefln("The most appropriate article for query \"%s\" is: %s",
            query, getRelevantArticle);
        writefln("With the article title is \"%s\"", title);

}