package day23;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

public class Solution {

	Solution(Path file) throws IOException {
		program = readProgram(file);
	}

	final List<Instruction> program;

	private List<Instruction> readProgram(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			return s.filter(l -> !l.isEmpty()).map(Instruction::parse).toList();
		}
	}

	// registers
	Map<String, Integer> registers = new HashMap<>();
	int ip = 0;

	record Instruction(String opcode, String register, int offset, String line) {

		static Instruction parse(String line) {
			String[] fields = line.split("[ ,]+");
			if (fields[0].startsWith("j")) {
				return new Instruction(fields[0], fields[1], Integer.parseInt(fields[fields.length - 1]), line);
			}
			else {
				return new Instruction(fields[0], fields[1], 0, line);
			}
		}
	};

	private void runInstruction(Instruction instr) {
		switch(instr.opcode) {
			case "hlf": registers.put(instr.register, registers.get(instr.register) / 2); ip++; break;
			case "tpl": registers.put(instr.register, registers.get(instr.register) * 3); ip++; break;
			case "inc": registers.put(instr.register, registers.get(instr.register) + 1); ip++; break;
			case "jmp": ip += instr.offset; break;
			case "jie": if (registers.get(instr.register) % 2 == 0) { ip += instr.offset; } else { ip++; } break;
			case "jio": if (registers.get(instr.register) == 1) { ip += instr.offset; } else { ip++; } break;
		}
	}

	private long runProgram(int aStart) {
		ip = 0;
		registers.put("a", aStart);
		registers.put("b", 0);
		while (ip < program.size()) {
//			System.out.printf("IP: %d A: %d B: %d INSTR: %s\n", ip, registers.get("a"), registers.get("b"), program.get(ip).line);
			Instruction instr = program.get(ip);
			runInstruction(instr);
		}
		return registers.get("b");
	}

	public static void main(String[] args) throws IOException {
		var testRunner = new Solution(Path.of("day23/test-input"));
		Util.assertEqual(testRunner.runProgram(0), 2);

		var runner = new Solution(Path.of("day23/input"));
		System.out.println(runner.runProgram(0));
		System.out.println(runner.runProgram(1));
	}
}

