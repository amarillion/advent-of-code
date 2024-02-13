module common.sparsegrid;

import common.coordrange;
import std.conv;

/** 
 * A sparse infinite grid: a grid backed by a map of [ position vector : value ]. 
 * This means that there is no need to predefine the bounds of the grid.
 * Unoccupied elements consume no memory, so the grid can grow huge as long as it is sparse.
 */
class SparseInfiniteGrid(T, U) {

	U[T] data;
	T min;
	T max;

	private U emptyValue;

	/** 
	 * Initialize an infinite grid
	 * Params:
	 *   _emptyValue = the default value for the underlying map. 
	 *                 Retrieving an uninitialized spot in the grid will return this value. 
	 *                 Setting the default value will remove a spot from the grid.
	 */	
	this(char _emptyValue = U.init) {
		emptyValue = _emptyValue;
	}

	U get(T p) {
		return p in data ? data[p] : emptyValue;
	}

	void set(T p, U val) {
		// we'll save a bit of space by not storing default values
		if (val == emptyValue) {
			data.remove(p);
		}
		else {	
			min.lowestCorner(p);
			max.highestCorner(p);
			data[p] = val;
		}
	}

	void modify(T p, U delegate(U) modifier) {
		set(p, modifier(get(p)));
	}

	string format(string cellSep = ", ", string lineSep = "\n", string blockSep = "\n\n") {
		char[] result;
		int i = 0;
		const T size = (max - min) + 1;
		const int lineSize = size.x;
		const int blockSize = size.x * size.y;
		bool firstBlock = true;
		bool firstLine = true;
		bool firstCell = true;
		foreach (base; CoordRange!T(min, max + 1)) {
			if (i % blockSize == 0 && !firstBlock) {
				result ~= blockSep;
				firstLine = true;
			}
			if (i % lineSize == 0 && !firstLine) {
				result ~= lineSep;
				firstCell = true;
			}
			if (!firstCell) result ~= cellSep;
			result ~= to!string(get(base));
			i++;
			
			firstBlock = false;
			firstLine = false;
			firstCell = false;
		}
		return result.idup;
	}

	override string toString() {
		return format();
	}

	void transform(U delegate(T) transformCell) {
		auto newData = new SparseInfiniteGrid!(T, U)();
		foreach (p; CoordRange!T(min - 1, max + 2)) {
			newData.set(p, transformCell(p));
		}
		data = newData.data;
		min = newData.min;
		max = newData.max;		
	}
}
