#include <iostream>
#include <string>
using namespace std;

int main() {
    // one line 
    /// one line doc
    //! also one line doc
    string name;/*kot*/string kot;
    cout << "Enter your name: ";
    /*
    multi "
    line //comment
    */

    /** 
    multi /*! 
    line doc //comment
    */

    cin >> name;
    cout << "Hello " << name << "!" << endl;

    /*! 
    multi 
    line doc //comment
    */

    cout << "Pulapka \" \\
                // a \
                /* a */ \
                "
       << endl;
    return 0;
}
//\
ala
