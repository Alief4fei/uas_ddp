module caseddp.first;

import std.stdio;
import std.string;
import std.ascii;
import std.regex;
import std.file;



void main(string[] args)
{
    string[] paths = ["arm_v9", "gpt5", "graphql", "m4_chip", "thunderbolt", "zen5"];
    int totalWords;
    string[][] articles;

    alias wordInArticle = int[string];
    int[wordInArticle] articleWords;

    foreach (string key; paths)
    {
        // string text_data = readText(key);
        // writeln(key);
        string text_data = parseInput(key);
        // writeln(text_data);
        auto re = regex(r"\[\d+\]");
        auto reNonAplha = regex(r"[^a-zA-Z\d\s:]");
        string filtered;
        filtered = replaceAll(text_data, re, "");
        filtered = replaceAll(filtered, reNonAplha, "");
        string[] splited_text_data = filtered.split();

        // writeln(splited_text_data);
        writeln(key, " have " , splited_text_data.length , " words.");
        totalWords += splited_text_data.length;
        articles ~= splited_text_data;
    }

    writeln("Total words: ", totalWords);
    wordInArticle charac;
    foreach (artc; articles)
    {
        foreach (cha; artc)
        {
            charac[cha] += 1;
        }
    }

    foreach (key, value; charac)
    {
        writeln(key);
        writeln("key");

    }

}


string parseInput(string path)
{
    string text = "";

    File f = File(path, "r");
    while (!f.eof())
    {
        string line = f.readln();
        text ~= line;
    }
    f.close();
    return text;
}