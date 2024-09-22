package common;

import java.util.Iterator;

public class AllPermutations<E> implements Iterable<E[]> {

	private final E[] original;
	public AllPermutations(E[] original) {
		this.original = original.clone();
	}

	@Override
	public Iterator<E[]> iterator() {
		return new Iterator<>() {
			private final E[] current = original.clone();
			private final int[] c = new int[original.length];
			private int idx = 1;

			@Override
			public boolean hasNext() {
				return idx < current.length;
			}

			// Heap's algorithm
			// https://stackoverflow.com/a/37580979/3306
			@Override
			public E[] next() {
				// losing a bit of efficiency here in favor of safety by cloning the array for each iteration.
				E[] result = current.clone();
				while (idx < current.length && c[idx] >= idx) {
					c[idx] = 0;
					++idx;
				}
				if (idx < current.length) {
					if (c[idx] < idx) {
						// Swap choice dependent on parity of k (even or odd)
						int k = (idx % 2 == 0) ? 0 : c[idx];
						E temp = current[idx];
						current[idx] = current[k];
						current[k] = temp;
						++c[idx];
						idx = 1;
					}
				}
				return result;
			}
		};
	}
}
