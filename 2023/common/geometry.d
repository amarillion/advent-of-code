module common.geometry;

import common.vec;

/** 
 * Returns: Cross product in 3D.
 */
vec!(3, V) cross(V)(vec!(3, V) a, vec!(3, V) b) {
	vec!(3, V) c;
	c.x = a.y * b.z - a.z * b.y;
	c.y = a.z * b.x - a.x * b.z;
	c.z = a.x * b.y - a.y * b.x;
	return c;
}

/** 
 * Returns: dot product of two vectors. 
 */
V dot(int N, V)(vec!(N, V) a, vec!(N, V) b) {
	V sum = 0;
	foreach(i; 0..N) {
		sum += a.val[i] * b.val[i];
	}
	return sum;
}
