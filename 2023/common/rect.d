module common.rect;

import common.vec;
import common.coordrange;

/** 
 * An n-dimensional box.
 */
struct Box(int N, T) {
	vec!(N, T) pos;
	vec!(N, T) size;

	@property 
	CoordRange!(vec!(N, T)) coordrange() {
		return CoordRange!(vec!(N, T))(pos, pos + size);
	}
}

alias Rect(T) = Box!(2, T);
alias Cuboid(T) = Box!(3, T);
alias Hyperrect(T) = Box!(4, T);