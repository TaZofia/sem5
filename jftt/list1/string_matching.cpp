#include <string>
#include <fstream>
#include <iostream>
#include <vector>

std::vector<std::vector<int>> compute_transition_function(std::string& pattern) {
  int m = pattern.size();
  int alphabet = 256;
  std::vector<std::vector<int>> delta(m + 1, std::vector<int>(alphabet, 0));

  for(int q = 0; q <= m; q++) {
    for(int a = 0 ; a < alphabet ; a++) {
      int k = std::min(m + 1, q + 2);
      do {
        k--;
        std::string prefix = pattern.substr(0, k);
        std::string suffix = pattern.substr(0, q) + static_cast<char>(a);
        if(suffix.size() >= k && suffix.substr(suffix.size() - k) == prefix) {
          break;
        }
      } while( k > 0 );
      delta[q][a] = k;
    }
  }
  return delta;
}

void finite_automation_matcher(std::string& text, std::string& pattern) {
  int n = text.size();
  int m = pattern.size();
  std::vector<std::vector<int>> delta = compute_transition_function(pattern);
  int q = 0;
  for(int i = 0; i < n; i++) {
    q = delta[q][text[i]];
    if(q == m) {
      std::cout << "Pattern occurs with shift: " << i - m + 1 << std::endl;
    }
  }
}

//------------KMP----------------------
std::vector<int> compute_prefix_function(std::string& pattern) {
  int m = pattern.size();
  std::vector<int> pi(m);
  pi[0] = 0;
  int k = 0;
  for (int q = 1; q < m; q++) {
    while(k > 0 && pattern[k] != pattern[q]) {
      k = pi[k - 1];
    }
    if(pattern[k] == pattern[q]) {
      k++;
    }
    pi[q] = k;
  }
  return pi;
}

void kmp_matcher(std::string& text, std::string& pattern) {
  int n = text.size();
  int m = pattern.size();

  std::vector<int> pi = compute_prefix_function(pattern);
  int q = 0;

  for (int i = 0; i < n; i++) {
    while (q > 0 && pattern[q] != text[i]) {
      q = pi[q - 1];
    }
    if (pattern[q] == text[i]) {
      q++;
    }
    if (q == m) {
      std::cout << "Pattern occurs with shift: " << i - m + 1 << std::endl;
      q = pi[q - 1];
    }
  }
}

int main(int argc, char * argv[]) {

  if(argc != 4) {
    std::cout << "[ERROR] Wrong number of arguments!" << std::endl;
    return 1;
  }

  std::string mode = argv[1];
  std::string pattern = argv[2];
  std::string file_name = argv[3];

  std::ifstream file(file_name);

  if (!file.is_open()) {
    std::cout << "[ERROR] can't open file: " << file_name << std::endl;
    return 1;
  }

  file.seekg(0, std::ios::end);
  size_t size = file.tellg();
  file.seekg(0);

  std::string content(size, '\0');
  file.read(&content[0], size);

  file.close();

  std::cout << "Number of chars: " << size << std::endl;
  //std::cout << "File:\n" << content << std::endl << std::endl;

  if(mode == "FA") {
    finite_automation_matcher(content, pattern);
  } else if(mode == "KMP") {
    kmp_matcher(content, pattern);
  } else {
    std::cout << "[ERROR] Wrong mode!" << std::endl;
    return 1;
  }
  return 0;
}