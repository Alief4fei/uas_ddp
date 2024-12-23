module lib;

import std.stdio;
import std.string;
import std.ascii;
import std.regex;
import std.algorithm;
import std.file;
import std.array;
import std.range;
import std.conv;


string[] conjunctions = [
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

string[] filtered_text(string texts)
{
    auto removeD = regex(r"\[\d+\]");
    auto reNonAlpha = regex(r"[^a-zA-Z\d\s:]");

    string filtered;
    filtered = replaceAll(texts, removeD, " ");
    filtered = replaceAll(filtered, reNonAlpha, " ");

    string[] split_filteredText = filtered.toLower.split();

    return split_filteredText;
}

int[string] countWordOccur(string[] texts)
{
    int[string] word_occ;
    foreach (text; texts)
    {
        word_occ[text]++;
        
    }

    return word_occ;
   
}

int[char] countAlphaNum(string[] texts)
{
    int[char] alphaNum;
    foreach (text; texts)
    {
        foreach (char c; text)
        {
            if (c.isAlphaNum)  // Memastikan hanya karakter alfanumerik yang dihitung
            {
                alphaNum[c]++;
            }
        }
    }

    return alphaNum;
}

int[string] conj(string[] texts)
{
    int[string] list;
    foreach (word; texts)
    {
        if (conjunctions.canFind(word))
        {
            list[word]++;
        }
    }

    return list;
}

string findMostRelevantArticle(string query, string[][string] articles)
{
    string[] query_tokens = query.toLower.split();

    int[string] scores;

    foreach (file_name, words; articles)
    {
        foreach (token; query_tokens)
        {
            if (words.canFind(token))
            {
                scores[file_name]++;
            }
        }
    }

    string mostScoreFile;
    int highestScore = -1;
    foreach (file, score; scores) {
        if (score > highestScore) {
            highestScore = score;
            mostScoreFile = file;
        }
    }

    return mostScoreFile;
}

string createTitle(int[string] wordFreq) {
    string[] title;

    // Sort the words by frequency in descending order
    auto sortedWordFreq = wordFreq.byKeyValue.array.sort!((a, b) => a.value > b.value);

    foreach (e; sortedWordFreq) {
        // Skip conjunctions
        if (conjunctions.canFind(e.key))
            continue;

        // Add the word to the title if it's not already included
        if (!title.canFind(e.key)) {
            title ~= e.key;
        }

        // Stop after adding three words
        if (title.length >= 3)
            break;
    }
    return title.join(" ");
}
