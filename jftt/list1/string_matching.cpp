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




int main(int argc, char * argv[]) {

  std::string mode = argv[1];
  std::string pattern = argv[2];
  std::string file_name = argv[3];

  std::ifstream file(file_name);

  if (!file.is_open()) {
    std::cout << "[ERROR] can't open file" << file_name << std::endl;
    return 1;
  }

  file.seekg(0, std::ios::end);
  size_t size = file.tellg();
  file.seekg(0);

  std::string content(size, '\0');
  file.read(&content[0], size);

  file.close();

  std::cout << "Number of chars: " << size << std::endl;
  std::cout << "File:\n" << content << std::endl;

  if(mode == "FA") {
    finite_automation_matcher(content, pattern);
  }

  return 0;
}