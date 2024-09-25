package common;

public class StringUtils {

	public static String join(String sep, int[] array) {
		if (array == null) return "null";
		StringBuilder result = new StringBuilder();
		boolean first = true;
		for (int i = 0; i < array.length; ++i) {
			if (!first) { result.append(sep); }
			else { first = false; }
			result.append(array[i]);
		}
		return result.toString();
	}

}
