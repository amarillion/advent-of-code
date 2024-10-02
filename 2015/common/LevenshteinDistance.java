package common;


public class LevenshteinDistance {

	/**
	 * Calculate similarity between two strings, expressed as the edit distance
	 * - the number of edits, deletions or insertions needed to go from String s to String t
	 *
	 * adapted from: https://en.wikipedia.org/wiki/Levenshtein_distance
	 * I created this for 2015 day 19, but ended up not needing it.
	 */
	private static int levenshteinDistance(String s, String t) {
		// create two work vectors of integer distances
		int sLength = s.length();
		int tLength = t.length();

		int[] previousRow = new int[tLength + 1];

		// initialize current Row
		// this row is A[0][i]: edit distance from an empty s to t;
		// that distance is the number of characters to append to s to make t.
		for (int i = 0; i < previousRow.length; ++i) {
			previousRow[i] = i;
		}

		int[] currentRow = new int[tLength + 1];

		for (int i = 0; i < sLength; ++i) {
			// calculate the current row distances from the previous row v0

			// first element of v1 is A[i + 1][0]
			// edit distance is delete (i + 1) chars from s to match empty t
			currentRow[0] = i + 1;

			// fill in the rest of the row
			for (int j = 0; j < tLength; ++j) {
				// calculating costs for A[i + 1][j + 1]
				int deletionCost = previousRow[j + 1] + 1;
				int insertionCost = currentRow[j] + 1;
				int substitutionCost = (s.charAt(i) == t.charAt(j)) ? previousRow[j] : previousRow[j] + 1;
				currentRow[j + 1] = Math.min(deletionCost, Math.min(insertionCost, substitutionCost));
			}

			// swap current row to previous row for next iteration
			// swap is cheaper than new array allocation. currentRow will be overwritten anyway.
			var temp = previousRow;
			previousRow = currentRow;
			currentRow = temp;
		}
		return previousRow[tLength];
	}
}
