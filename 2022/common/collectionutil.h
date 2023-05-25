#include <vector>
#include <iostream>

/**
 * Print a vector<T> to a stream, enclosed by [] and delimited by ,
 * T must have operator<< defined.
 */
template<typename T>
std::ostream &operator<< (std::ostream &os, const std::vector<T> &v) {
	char sep = '[';
	for (const auto &item: v) {
		os << sep << item;
		sep = ',';
	}
	os << ']';
	return os;
}
