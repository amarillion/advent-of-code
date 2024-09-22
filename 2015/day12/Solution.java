package day12;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonPrimitive;
import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import java.util.stream.Stream;

public class Solution {

	private static String parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).findFirst().orElseThrow();
		}
	}

	private static long recursiveSum(JsonElement elt, boolean ignoreRed) {
		long result = 0;
		if (elt.isJsonArray()) {
			for(var child: elt.getAsJsonArray()) {
				result += recursiveSum(child, ignoreRed);
			}
		}
		else if (elt.isJsonObject()) {
			if (ignoreRed) {
				var hasRed =
						elt.getAsJsonObject().entrySet().stream()
								.map(Map.Entry::getValue)
								.filter(JsonElement::isJsonPrimitive)
								.map(JsonElement::getAsJsonPrimitive)
								.filter(JsonPrimitive::isString)
								.map(JsonPrimitive::getAsString)
								.filter("red"::equals)
								.findFirst();
				if (hasRed.isPresent()) {
					return 0;
				}
			}
			for(var entry: elt.getAsJsonObject().entrySet()) {
				result += recursiveSum(entry.getValue(), ignoreRed);
			}
		}
		else if (elt.isJsonPrimitive()) {
			var prim = elt.getAsJsonPrimitive();
			if (prim.isNumber()) {
				result += prim.getAsLong();
			}
		}
 		return result;
	}

	private static long solve1(String data) {
		JsonElement obj = JsonParser.parseString(data);
		return recursiveSum(obj, false);
	}

	private static long solve2(String data) {
		JsonElement obj = JsonParser.parseString(data);
		return recursiveSum(obj, true);
	}

	public static void main(String[] args) throws IOException {
		Util.assertEqual(solve1("{\"a\":{\"b\":4},\"c\":-1}"), 3);
		Util.assertEqual(solve1("[[[3]]]"), 3);
		Util.assertEqual(solve1("{\"a\":[-1,1]}"), 0);
		Util.assertEqual(solve1("[-1,{\"a\":1}]"), 0);

		Util.assertEqual(solve2("{\"d\":\"red\",\"e\":[1,2,3,4],\"f\":5}"), 0);
		Util.assertEqual(solve2("[1,\"red\",5]"), 6);

		String data = parse(Path.of("day12/input"));
		System.out.println(solve1(data));
		System.out.println(solve2(data));
	}
}
