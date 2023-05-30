#include <vector>
#include <iostream>
#include <set>
#include <map>
#include <array>

/**
 * Print a vector<T> to a stream, enclosed by [] and delimited by ,
 * T must have operator<< defined.
 */
template<typename T>
std::ostream &operator<< (std::ostream &os, const std::vector<T> &v) {
	os << '[';
	bool first = true;
	for (const auto &item: v) {
		if (first) { first = false; } else { os <<  ','; }
		os << item;
	}
	os << ']';
	return os;
}

/**
 * Print a set<T> to a stream, enclosed by [] and delimited by ,
 * T must have operator<< defined.
 */
template<typename T>
std::ostream &operator<< (std::ostream &os, const std::set<T> &v) {
	os << '[';
	bool first = true;
	for (const auto &item: v) {
		if (first) { first = false; } else { os <<  ','; }
		os << item;
	}
	os << ']';
	return os;
}

/**
 * Print a map<K, V> to a stream, as k => v and delimited by ,
 * K and V must have operator<< defined.
 */
template<typename K, typename V>
std::ostream &operator<< (std::ostream &os, const std::map<K, V> &map) {
	bool first = true;
	os << "{ ";
	for (const auto &[k, v]: map) {
		if (first) { first = false; } else { os <<  ", "; }
		os << k << " => " << v;
	}
	os << " }";
	return os;
}
