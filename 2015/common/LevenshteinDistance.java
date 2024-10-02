package common;

// adapted from: https://en.wikipedia.org/wiki/Levenshtein_distance
// I created this for 2015 day 19, but ended up not needing it.
public class LevenshteinDistance {

	private static int levenshteinDistance(String s, String t) {
		// create two work vectors of integer distances
		int m = s.length();
		int n = t.length();

		int[] v0 = new int[n + 1];

		// initialize v0 (the previous row of distances)
		// this row is A[0][i]: edit distance from an empty s to t;
		// that distance is the number of characters to append to  s to make t.
		for (int i = 0; i < n + 1; ++i) {
			v0[i] = i;
		}

		int[] v1 = new int[n + 1];

		for (int i = 0; i < m; ++i) {

			// calculate v1 (current row distances) from the previous row v0

			// first element of v1 is A[i + 1][0]
			//   edit distance is delete (i + 1) chars from s to match empty t
			v1[0] = i + 1;

			// use formula to fill in the rest of the row
			for (int j = 0; j < n; ++j) {
				// calculating costs for A[i + 1][j + 1]
				int deletionCost = v0[j + 1] + 1;
				int insertionCost = v1[j] + 1;
				int substitutionCost = (s.charAt(i) == t.charAt(j)) ? v0[j] : v0[j] + 1;
				v1[j + 1] = Math.min(deletionCost, Math.min(insertionCost, substitutionCost));
			}

			// copy v1 (current row) to v0 (previous row) for next iteration
			// swap is cheaper than new array allocation. V1 will be overwritten anyway.
			var temp = v0;
			v0 = v1;
			v1 = temp;
		}
		return v0[n];
	}

}
