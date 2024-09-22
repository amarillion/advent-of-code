package common;

public class Util {
	public static void assertEqual(long observed, long expected) {
		if (observed != expected) throw new Error("Assertion failed");
	}

	public static void assertEqual(String observed, String expected) {
		if (!observed.equals(expected)) throw new Error("Assertion failed");
	}

	public static void assertTrue(boolean assertion) {
		if (!assertion) throw new Error("Expected true");
	}

	public static void assertTrue(boolean assertion, String message) {
		if (!assertion) throw new Error(message);
	}

	public static void assertFalse(boolean assertion) {
		if (assertion) throw new Error("Expected false");
	}

	public static void assertFalse(boolean assertion, String message) {
		if (assertion) throw new Error(message);
	}

}
