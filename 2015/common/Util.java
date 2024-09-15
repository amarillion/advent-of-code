package common;

public class Util {
	public static void assertEqual(long observed, long expected) {
		System.out.println(observed);
		if (observed != expected) throw new Error("Assertion failed");
	}
}
