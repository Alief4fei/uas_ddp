module caseddp.main2;

import conjunction;

import std.stdio;
import std.string;
import std.ascii;
import std.regex;
import std.algorithm;
import std.file;
import std.array;
import std.range;
import std.conv;

void main(string[] args)
{
    string[] paths = [
        "gpt5", "graphql", "m4_chip", "thunderbolt",
        "zen5", "arm_v9"
    ];

    int amountTotal, wordOccTotal;
    int[string][string] wordOccurencesAll;
    int[char] alphanumAll;
    string[][string] textArticles;

    writeln(
        "=================================================PROBLEM 1=================================================");

    foreach (string file; paths)
    {
        string[] input = clearFormatText(readText(file));
        textArticles[file] = input;

        int[string] list_conj = listConj(input);
        string[] inputWithoutConj = clearConj(input);

        // PROBLEM 1
        // Amount Word per article
        writefln("In article %s", file);

        writefln("There is %d words", input.length);
        amountTotal += input.length.to!int;

        // Word Occurences
        int[string] wordOccurences = countWordOcc(input);

        writefln("Word Occurences total: %d", wordOccurences.length);
        wordOccTotal += wordOccurences.length.to!int;

        wordOccurencesAll[file] = wordOccurences;

        string mostFrequentWord;
        int maxOccurrences = 0;

        foreach (key, value; wordOccurences)
        {
            if (value > maxOccurrences)
            {
                maxOccurrences = value;
                mostFrequentWord = key;
            }
        }

        writefln("The most frequent word: \"%s\" with %d occurrences", mostFrequentWord, maxOccurrences);

        // Conjunction
        int countConj = list_conj.length.to!int;
        writefln("There's %d conjunctions", countConj);

        // Alphanumeric occurences
        int[char] alphanumeric = countAlphanumeric(inputWithoutConj);
        writefln("Alphanumeric occurences total: %d", alphanumeric.length);

        foreach (key; alphanumeric.keys)
        {
            alphanumAll[key] += alphanumeric[key];
        }

        writeln("--------------------------------------------------------------------------------");
    }

    writefln("Total amount words for all article is %s words", amountTotal);
    writefln("Total word occurences for all article is %s words", wordOccTotal);
    writefln("Total alphanumeric for all article is %s letters", alphanumAll.length);

    // Problem 2
    writeln(
        "=================================================PROBLEM 2=================================================");

    string query2;
    while (query2.empty)
    {
        write("Type the word you want to search for: ");
        readf("%s\n", query2);

        string[] splitQuery = query2.split();

        // check the user query is two or less 
        if (splitQuery.length >= 2)
        {
            query2 = splitQuery[0 .. 2].join(" ");
        }
        else
        {
            query2 = [];
        }
    }

    string getRelevantArticle = findMostRelevantArticle(query2, textArticles);
    if (!getRelevantArticle.empty)
    {
        writeln(getRelevantArticle);

        string title = createTitle(wordOccurencesAll[getRelevantArticle]);
        writefln("The most appropriate article for query \"%s\" is: %s",
            query2, getRelevantArticle);
        writefln("With the article title is \"%s\"", toTitleStyle(title));
    }
    else
    {
        writeln("No appropriate article found");
    }

    // Problem 3
    writeln(
        "=================================================PROBLEM 3=================================================");

    string query3;
    while (query3.empty)
    {
        write("Type the word you want to find similarities with: ");
        readf("%s\n", query3);

        string[] splitQuery = query3.split();

        // check the user query is one or less 
        if (splitQuery.length < 1)
        {
            query3 = [];
        }
        else if (splitQuery.length > 1)
        {
            query3 = splitQuery[0 .. 1].join("");
        }
    }
    int[string] similarWords = checkSimilar(query3, textArticles);

    auto sortedSimilarWords = similarWords.byKeyValue.array.sort!((a, b) => a.value < b.value).take(
        5);

    if (sortedSimilarWords.length > 0)
    {
        writeln("5 most similar words");
        foreach (e; sortedSimilarWords)
        {
            writefln("%s with %d difference letter", e.key, e.value);
        }
    }
    else
    {
        writeln("Not found similar word");
    }
}

int[string] checkSimilar(string query, string[][string] textArticles)
{
    query = query.toLower;
    int[string] similarWords;
    size_t queryLen = query.length;

    foreach (string[] words; textArticles.values)
    {
        foreach (string word; words)
        {
            bool isSimiliar = false;
            size_t j = 0;
            int differenceCount;

            foreach (ch; word)
            {
                if (j < queryLen && ch == query[j])
                {
                    j++;
                }

                if (j == queryLen)
                {
                    isSimiliar = true;
                    break;
                }
            }

            if (isSimiliar)
            {
                differenceCount = (word.length - queryLen).to!int;
                similarWords[word] = differenceCount;
            }
        }
    }

    return similarWords;
}

string findMostRelevantArticle(string query, string[][string] articles)
{
    string[] queryTokens = query.toLower.split();

    int[string] scores;

    foreach (file_name, words; articles)
    {
        foreach (token; queryTokens)
        {
            if (words.canFind(token))
            {
                scores[file_name]++;
            }
        }
    }

    string mostScoreFile;
    foreach (file, score; scores)
    {
        if (mostScoreFile.empty || score > scores[mostScoreFile])
        {
            mostScoreFile = file;
        }
    }

    return mostScoreFile;
}

bool startsWithSimilar(string a, string b)
{
    return a.startsWith(b) || b.startsWith(a);
}

string toTitleStyle(string title)
{
    return title.split().map!(e => (to!string(e[0]).toUpper() ~ e[1 .. $])).join(" ");
}

string createTitle(int[string] wordOcc)
{
    string[] title;

    auto sortedWowordOcc = wordOcc.byKeyValue.array.sort!((a, b) => a.value > b.value);

    foreach (e; sortedWowordOcc)
    {
        if (conjunctions.canFind(e.key))
            continue;

        if (title.length == 0 || !title.canFind(e.key))
        {
            bool skip = false;

            foreach (string tl; title)
            {
                if (startsWithSimilar(tl, e.key))
                {
                    skip = true;
                    break;
                }
            }

            if (!skip)
                title ~= e.key;
            if (title.length >= 3)
                break;
        }
    }
    return title.join(" ");
}

int[char] countAlphanumeric(string[] texts)
{
    int[char] alphaNum;

    foreach (text; texts)
    {
        foreach (word; text)
        {
            alphaNum[word]++;
        }
    }

    return alphaNum;
}

int[string] countWordOcc(string[] texts)
{
    int[string] wordOcc;

    foreach (text; texts)
    {
        wordOcc[text]++;
    }

    return wordOcc;
}

int[string] listConj(string[] texts)
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

string[] clearConj(string[] texts)
{
    string[] result = texts.filter!(word => !conjunctions.canFind(word)).array;

    return result;
}

string[] clearFormatText(string texts)
{
    auto reRef = regex(r"\[\d+\]");
    auto reNonAplha = regex(r"[^a-zA-Z\d\s:]");

    string filtered;
    filtered = replaceAll(texts, reRef, " ");
    filtered = replaceAll(filtered, reNonAplha, " ");

    string[] splited_text_data = filtered.toLower.split();

    return splited_text_data;
}
