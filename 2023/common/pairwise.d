module common.pairwise;

import std.range: isRandomAccessRange, hasLength;
import std.traits: ForeachType, Unqual, isNarrowString;
import std.typecons: Tuple, tuple;

struct Pairwise(Range) {
	alias R = Unqual!Range;
	alias Pair = Tuple!(ForeachType!R, "a", ForeachType!R, "b");
	R _input;
	size_t i, j;

	this(Range r_) {
		this._input = r_;
		j = 1;
	}

	@property bool empty() {
		return j >= _input.length;
	}

	@property Pair front() {
		return Pair(_input[i], _input[j]);
	}

	void popFront() {
		if (j + 1 >= _input.length) {
			i++;
			j = i + 1;
		} else {
			j++;
		}
	}
}

/** 
 * 
 * Params:
 *   r = a range of things
 * Returns: 
 * Tuples of all non-self, non-overlapping pairs.
 * For example:
 * [1,2,3].pairwise = [tuple(1,2),tuple(1,3),tuple(2,3)] 
 * derived from discussion here: https://issues.dlang.org/show_bug.cgi?id=6788
 *
 * TODO: Could be generalized to allCombinations!N

 * for example: allCombinations!3[1,2,3,4] = [(1,2,3),(1,2,4),(1,3,4),(2,3,4)]
 * and: alias pairwise = allCombinations!2
 */
Pairwise!Range pairwise(Range)(Range r)
if (isRandomAccessRange!Range && hasLength!Range && !isNarrowString!Range) {
	return typeof(return)(r);
}

unittest {
	import std.algorithm : equal;
	assert([1,2,3].pairwise.equal([tuple(1,2),tuple(1,3),tuple(2,3)]));
	assert([1,2,3,4].pairwise.equal([tuple(1,2),tuple(1,3),tuple(1,4),tuple(2,3),tuple(2,4),tuple(3,4)]));
}