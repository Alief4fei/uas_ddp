module caseddp.coba;

import std.stdio;
import std.string;
import std.file;
import std.regex;
import std.array;
import std.conv;
import std.algorithm;
import std.range;
import std.uni;

struct ArticleInfo {
    string title;
    int wordCount;
    int totalWordCount;
    int[string] wordOccurrences;
    int totalOccurrences;
    int[string] alphanumericOccurrences;
    string[] conjunctions;
}

struct DataStructure {
    ArticleInfo[] articles;
    int totalWords;
    int[string] totalWordOccurrences;
    int[string] totalAlphanumericOccurrences;
    int[string] totalConjunctionOccurrences;
}

DataStructure parseArticles(string[] paths, string[] knownconjunction) {
    DataStructure data;
    
    foreach (string filePath; paths) {
        string textData = readText(filePath);
        ArticleInfo article;
        article.title = filePath;
        
        // Clean up text
        auto reRemoveRefs = regex(r"\[\d+\]");
        auto reNonAlphaNum = regex(r"[^a-zA-Z\d\s:]");
        string filtered_text = replaceAll(textData, reRemoveRefs, "");
        string filtered2_text = replaceAll(filtered_text, reNonAlphaNum, " ");
        string[] words = filtered2_text.split.map!(toLower).array;
        article.wordCount = cast(int) words.length;  // Convert to int
        data.totalWords += cast(int) words.length;  // Convert to int
        
        // Calculate word occurrences
        foreach (string word; words) {
            article.wordOccurrences[word] += 1;
            data.totalWordOccurrences[word] += 1;
            if (knownconjunction.canFind(word)) {
                article.conjunctions ~= word;
                data.totalConjunctionOccurrences[word] += 1;
            }
        }
        
        // Calculate alphanumeric occurrences
        foreach (char c; filtered_text.toLower()) {
            if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
                article.alphanumericOccurrences[c.to!string] += 1;
                data.totalAlphanumericOccurrences[c.to!string] += 1;
            }
        }
        
        data.articles ~= article;
    }
    
    return data;
}

string searchArticle(DataStructure data, string query) {
    string[] queryWords = query.split.map!(toLower).array;
    int[string] queryWordCount;
    
    foreach (string word; queryWords) {
        queryWordCount[word] += 1;
    }
    
    string bestMatch;
    int bestMatchScore = 0;
    
    foreach (article; data.articles) {
        int score = 0;
        foreach (key, count; queryWordCount) {
            if (key in article.wordOccurrences) {  // Check if key exists in wordOccurrences
                score += article.wordOccurrences[key] * count;
            }
        }
        if (score > bestMatchScore) {
            bestMatch = article.title;
            bestMatchScore = score;
        }
    }
    
    return bestMatch;
}

void main(string[] args) {
    string[] paths = ["arm_v9", "gpt5", "graphql", "m4_chip", "thunderbolt", "zen5"];
    string[] knownconjunction = [
        "a", "of", "in", "s", "is", "are", "to", "after", "albeit", "although", "and",
        "as", "because", "before", "but", "for", "if", "nor", "or", "since", "so",
        "than", "that", "though", "till", "unless", "until", "when", "where", "whereas",
        "whether", "while", "with", "yet", "though", "lest", "once", "whenever",
        "wherever", "whilst", "otherwise", "inasmuch", "inasmuch as", "providing",
        "provided", "scarcely", "whereupon", "hereupon", "notwithstanding", "now",
        "because", "although", "even", "either", "neither", "even though",
        "whether or not", "rather", "nor", "both", "but only", "not only",
        "though that", "so that", "till now", "unless that", "while now", "on", "hence",
        "thus", "therefore", "consequently", "meanwhile", "moreover", "furthermore",
        "besides", "afterwards", "thereupon", "accordingly", "yet when", "once before",
        "even so", "since when", "henceforth", "even then", "so long as", "given",
        "granted", "forasmuch", "inasfar", "seeing", "seeing that", "even if",
        "just as", "as though", "even when", "notwithstanding", "only if", "beforehand",
        "as of now"
    ];

    DataStructure data = parseArticles(paths, knownconjunction);

    writeln("Total words = ", data.totalWords);
    writeln("-----------------------------------------------------");
    writeln("Total word occurrences:");
    writeln(data.totalWordOccurrences);
    // foreach (kv; data.totalWordOccurrences.byKeyValue.array.sort!((a, b) => a.key < b.key)) {
    //     writeln("  ", kv.key, ": ", kv.value);
    // }
    writeln("-----------------------------------------------------");
    writeln("Total alphanumeric occurrences:");
    writeln(data.totalAlphanumericOccurrences);
    // foreach (kv; data.totalAlphanumericOccurrences.byKeyValue.array.sort!((a, b) => a.key < b.key)) {
    //     writeln("  ", kv.key, ": ", kv.value);
    // }
    writeln("-----------------------------------------------------");
    writeln("Total conjunction occurrences:");
    writeln(data.totalConjunctionOccurrences);
    // foreach (kv; data.totalConjunctionOccurrences.byKeyValue.array.sort!((a, b) => a.key < b.key)) {
    //     writeln("  ", kv.key, ": ", kv.value);
    // }
    writeln("Total conjunctions = ", data.totalConjunctionOccurrences.values.sum);

    // Search query
    string query;
    writeln("Enter your search query (at least 2 words): ");
    query = stdin.readln().strip();

    if (query.split.length >= 2) {
        string bestMatch = searchArticle(data, query);
        writeln("The most appropriate article for your query is: ", bestMatch);
    } else {
        writeln("Please enter at least 2 words for the query.");
    }
}
