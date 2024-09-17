package day7;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.stream.Stream;

public class Solution {

	public static class Context {
		private final Map<String, Integer> data = new HashMap<>();
		private final Map<String, Integer> overrides = new HashMap<>();

		boolean containsKey(String key) {
			return overrides.containsKey(key) || data.containsKey(key);
		}

		void put(String key, Integer value) {
			data.put(key, value);
		}

		void override(String key, Integer value) {
			overrides.put(key, value);
		}

		Integer get(String key) {
			return overrides.containsKey(key) ? overrides.get(key) : data.get(key);
		}
	}

	interface Instruction {
		void calc(Context context);
		boolean inputsActive(Context context);
		default int valueOf(Context context, String operand) {
			if (operand == null) {
				return 0;
			}
			else if (operand.matches("\\d+")) {
				return Integer.parseInt(operand);
			}
			else {
				if (!context.containsKey(operand)) { throw new Error("Key '" + operand + "' not found"); }
				return context.get(operand);
			}
		}
	}

	record Operator(
		String opA,
		String opcode,
		String opB,
		String result
	) implements Instruction {
		public boolean inputsActive(Context context) {
			return
					(opA == null || opA.matches("\\d+") || context.containsKey((opA)))
					&&
					(opB == null || opB.matches("\\d+") || context.containsKey((opB)));
		}
		public void calc(Context context) {
			int intA = valueOf(context, opA);
			int intB = valueOf(context, opB);
			int val = switch(opcode) {
				case "NOT" -> ~intB;
				case "AND" -> intA & intB;
				case "OR" -> intA | intB;
				case "LSHIFT" -> intA << intB;
				case "RSHIFT" -> intA >> intB;
				default -> throw new Error();
			};
			context.put(result, val & 0xFFFF);
		}

	};

	record Assign(
		String operand,
		String result
	) implements Instruction {
		public boolean inputsActive(Context context) {
			return
					(operand == null || operand.matches("\\d+") || context.containsKey((operand)));
		}

		public void calc(Context context) {
			context.put(result, valueOf(context, operand));
		}
	};

	private static Instruction parseLine(String line) {
		String[] fields = line.split(" ");
		return switch (line) {
			case String s when s.matches("\\w+ (LSHIFT|RSHIFT|OR|AND) \\w+ -> \\w+") -> new Operator(fields[0], fields[1], fields[2], fields[4]);
			case String s when s.matches("NOT \\w+ -> \\w+") -> new Operator(null, fields[0], fields[1], fields[3]);
			case String s when s.matches("\\w+ -> \\w+") -> new Assign(fields[0], fields[2]);
			default -> throw new Error("Does not match: [" + line + "]");
		};
	}

	private static List<Instruction> parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(Solution::parseLine).toList();
		}
	}

	private static void solve(List<Instruction> data, Context context) {
		Queue<Instruction> remain = new LinkedList<>(data);

		while (!remain.isEmpty()) {
			Instruction i = remain.poll();
			if (i.inputsActive(context)) {
				i.calc(context);
			}
			else {
				// add again to back of queue
				remain.add(i);
			}
		}


	}

	private static long solve1(List<Instruction> data, String resultKey) {
		Context context = new Context();
		solve(data, context);
		return context.get(resultKey);
	}

	private static long solve2(List<Instruction> data) {
		Context context = new Context();
		solve(data, context);
		int intermediate = context.get("a");
		context = new Context();
		context.override("b", intermediate);
		solve(data, context);
		return context.get("a");
	}

	public static void main(String[] args) throws IOException {
		var testData = parse(Path.of("day7/test-input"));
		Util.assertEqual(solve1(testData, "i"), 65079);
		var data = parse(Path.of("day7/input"));
		System.out.println(solve1(data, "a"));
		System.out.println(solve2(data));
	}
}
