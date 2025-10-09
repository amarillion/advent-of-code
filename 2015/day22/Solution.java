package dayX;

import common.Util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Solution {

	private record Data(int hitpoints, int damage) {}

	private static Data parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			var values = s
				.filter(l -> !l.isEmpty())
				.map(l -> l.split(": "))
				.collect(Collectors.toMap(l -> l[0], l -> Integer.parseInt(l[1])));
			return new Data(values.get("Hit Points"), values.get("Damage"));
		}
	}

	record Spell(String name);
	final var SPELLS = new Spell[]{
			Spell("Magic Missile", 53, 4),

	};
	private static long solve1(Data data, int hitPoints, int mana) {
		long result = 0;

		return result;
	}

	public static void main(String[] args) throws IOException {
	}
}
