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

void main(string[] args) {
    string[] paths = ["arm_v9", "gpt5", "graphql", "m4_chip", "thunderbolt", "zen5"];
    string filtered_text;
    string filtered2_text;
    string alphaNum_text;
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
    int total_words;
    int[string] total_alphaNumFreq;
    int[string] total_wordfreq;
    int[string] total_conjfreq;

    foreach (string key; paths) {
        string text_data = readText(key);
        auto re1 = regex(r"\[\d+\]");
        auto reNonAlphaNum = regex(r"[^a-zA-Z\d\s:]");
        filtered_text = replaceAll(text_data, re1, "");
        filtered2_text = replaceAll(filtered_text, reNonAlphaNum, " ");
        string[] split_filteredText = filtered2_text.split.map!(toLower).array;

        writeln("-----------------------------------------------------");
        writeln("Article ", key, " has:");
        writeln("Amount of words: ", split_filteredText.length, " words");

        total_words += split_filteredText.length;

        int[string] word_freq;
        string[] conjunction;
        // Word frequency and conjunction detection
        foreach (string word; split_filteredText) {
            word_freq[word] += 1;
            total_wordfreq[word] += 1;
            if (knownconjunction.canFind(word)) {
                conjunction ~= word;
            }
        }

        foreach (string conj; conjunction) {
            total_conjfreq[conj] += 1;
        }

        // Sort by values and exclude conjunctions
        auto sort_wordF = word_freq.byKeyValue.array.sort!((a, b) => a.value > b.value).filter!(
            kv => !knownconjunction.canFind(kv.key)).take(3);
        foreach (kv; sort_wordF) {
            writeln(kv.key, ": ", kv.value);
        }

        writeln("-----------------------------------------------------");
        writeln("Word frequency:");
        writeln(word_freq);
        writeln("-----------------------------------------------------");
        writeln("Conjunctions:");
        writeln(total_conjfreq);
        writeln("Total conjunctions: ", conjunction.length);
        writeln("-----------------------------------------------------");

        // Alphanumeric frequency
        auto alphaNum = regex(r"[^a-zA-Z\d]");
        alphaNum_text = replaceAll(filtered_text.toLower(), alphaNum, "");

        writeln("Alphanumeric occurrences:");
        int[string] alphaNum_freq;
        foreach (char c; alphaNum_text) {
            alphaNum_freq[c.to!string] += 1;
            total_alphaNumFreq[c.to!string] += 1;
        }

        writeln(alphaNum_freq);
        writeln("-----------------------------------------------------");
        writeln();
    }

    // Print total occurrences
    writeln("All text:");
    writeln("Total words = ", total_words);
    writeln("-----------------------------------------------------");
    writeln("Total word occurrences:");
    writeln(total_wordfreq);
    writeln("-----------------------------------------------------");
    writeln("Total alphanumeric occurrences:");
    writeln(total_alphaNumFreq);
    writeln("-----------------------------------------------------");
    writeln("Total conjunction occurrences:");
    writeln(total_conjfreq);
    writeln("Total conjunctions = ", total_conjfreq.values.sum);
}
