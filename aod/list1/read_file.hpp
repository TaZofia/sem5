#ifndef READ_FILE_HPP
#define READ_FILE_HPP

#include <string>
#include <utility>
#include <vector>

class FileReader {
  std::string filename;

public:
    explicit FileReader(const std::string& filename) {
      this->filename = filename;
    }

    char is_directed();
    int number_of_vertices();
    int number_of_edges();
    std::vector<std::pair<int, int>> get_edges();
};

#endif