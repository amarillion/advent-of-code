#include <functional>

void forArea(int x1, int y1, int w, int h, const std::function<void(int, int)> &func) {
	for (int y =  y1; y < y1 + h; ++y) {
		for (int x = x1; x < x1 + w; ++x) {
			func(x, y);
		}
	}
}

bool someArea(int x1, int y1, int w, int h, const std::function<bool(int, int)> &predicate) {
	for (int y =  y1; y < y1 + h; ++y) {
		for (int x = x1; x < x1 + w; ++x) {
			if (predicate(x, y)) return true;
		}
	}
	return false;
}