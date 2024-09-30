package common;

import java.util.ArrayList;
import java.util.function.Consumer;

public class Grid<T> {
	private final T[] data;
	public final int width;
	public final int height;

	public Grid(int width, int height) {
		//noinspection unchecked
		data = (T[])new Object[width * height];
		this.width = width;
		this.height = height;
	}

	public Grid(Grid<T> other) {
		this.width = other.width;
		this.height = other.height;
		data = other.data.clone();
	}

	public boolean outOfRange(int x, int y) {
		return (x < 0 || x >= width || y < 0 || y >= height);
	}

	private int index(int x, int y) {
		return x + (y * width);
	}

	public void set(int x, int y, T value) {
		if (outOfRange(x, y)) throw new Error("Coordinates out of range");
		data[index(x, y)] = value;
	}

	public T get(int x, int y) {
		if (outOfRange(x, y)) throw new Error("Coordinates out of range");
		return data[index(x, y)];
	}

	public void visitNeighbors(int x, int y, Consumer<T> func) {
		for (int xx = Math.max(0, x - 1); xx < Math.min(width, x + 2); ++xx) {
			for (int yy = Math.max(0, y - 1); yy < Math.min(height, y + 2); ++yy) {
				if (x == xx && y == yy) continue;
				func.accept(get(xx, yy));
			}
		}
	}

	public void forEach(Supplier3<Integer, Integer, T> callback) {
		for (int y = 0; y < height; ++y) {
			for(int x = 0; x < width; ++x) {
				callback.apply(x, y, get(x, y));
			}
		}
	}

}
