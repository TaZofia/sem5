#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <locale>
#include <codecvt>
#include <unordered_set>
#include <algorithm>

using namespace std;

// ==================== FA ====================
vector<vector<int>> computeTransitionFunction(const wstring &pattern) {
    int m = pattern.size();
    unordered_set<wchar_t> alphabet(pattern.begin(), pattern.end());
    vector<vector<int>> transition(m + 1, vector<int>(65536, 0));

    for (int q = 0; q <= m; ++q) {
        for (wchar_t a : alphabet) {
            int k = min(m, q + 1);
            while (k > 0 && !(pattern.substr(0, k) == (pattern.substr(0, q) + a).substr((q + 1) - k, k))) {
                k--;
            }
            transition[q][a] = k;
        }
    }
    return transition;
}

vector<int> finiteAutomatonMatcher(const wstring &pattern, const wstring &text) {
    vector<vector<int>> transition = computeTransitionFunction(pattern);
    int m = pattern.size();
    int q = 0;
    vector<int> positions;

    for (size_t i = 0; i < text.size(); ++i) {
        q = transition[q][text[i]];
        if (q == m) {
            positions.push_back(i - m + 1);
        }
    }
    return positions;
}

// ==================== KMP ====================
vector<int> computePrefixFunction(const wstring &pattern) {
    int m = pattern.size();
    vector<int> pi(m, 0);
    int k = 0;

    for (int q = 1; q < m; ++q) {
        while (k > 0 && pattern[k] != pattern[q]) {
            k = pi[k - 1];
        }
        if (pattern[k] == pattern[q]) {
            k++;
        }
        pi[q] = k;
    }
    return pi;
}

vector<int> kmpMatcher(const wstring &pattern, const wstring &text) {
    int m = pattern.size();
    int n = text.size();
    vector<int> pi = computePrefixFunction(pattern);
    int q = 0;
    vector<int> positions;

    for (int i = 0; i < n; ++i) {
        while (q > 0 && pattern[q] != text[i]) {
            q = pi[q - 1];
        }
        if (pattern[q] == text[i]) {
            q++;
        }
        if (q == m) {
            positions.push_back(i - m + 1);
            q = pi[q - 1];
        }
    }
    return positions;
}

// ==================== Main ====================
int main(int argc, char* argv[]) {
    if (argc != 4) {
        cerr << "Usage: FA|KMP <pattern_file> <text_file>\n";
        return 1;
    }

    string mode_str = argv[1];
    string pattern_file = argv[2];
    string text_file = argv[3];

    wstring_convert<codecvt_utf8<wchar_t>> converter;

    ifstream pf(pattern_file, ios::binary);
    string pattern_content((istreambuf_iterator<char>(pf)), istreambuf_iterator<char>());
    wstring pattern = converter.from_bytes(pattern_content);

    ifstream tf(text_file, ios::binary);
    string text_content((istreambuf_iterator<char>(tf)), istreambuf_iterator<char>());
    wstring text = converter.from_bytes(text_content);

    vector<int> matches;
    if (mode_str == "FA") {
        matches = finiteAutomatonMatcher(pattern, text);
    } else if (mode_str == "KMP") {
        matches = kmpMatcher(pattern, text);
    } else {
        cerr << "Invalid mode, use FA or KMP.\n";
        return 1;
    }

    for (int pos : matches) {
        wcout << pos << endl;
    }

    return 0;
}
