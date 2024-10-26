package day21;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.function.BiFunction;
import java.util.function.Consumer;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Solution {

	private static record CharacterData(int hp, int damage, int armor) {}

	private static CharacterData parse(Path file) throws IOException {
		var raw = new HashMap<String, Integer>();
		try (Stream<String> s = Files.lines(file)) {
			s.filter(l -> !l.isEmpty()).forEach(l -> {
				var fields = l.split(": ");
				raw.put(fields[0], Integer.parseInt(fields[1]));
			});
		}
		return new CharacterData(
				raw.get("Hit Points"),
				raw.get("Damage"),
				raw.get("Armor")
		);
	}

	static private boolean canPlayerWin(CharacterData player, CharacterData boss) {
		int playerHp = player.hp;
		int bossHp = boss.hp;
		while(true) {
			bossHp -= Math.max(1, (player.damage - boss.armor));
//			System.out.printf("Player deals %d-%d damage; the boss goes down to %d hp%n", player.damage, boss.armor, bossHp);
			if (bossHp <= 0) return true;
			playerHp -= Math.max(1, (boss.damage - player.armor));
//			System.out.printf("Boss deals %d-%d damage; the player goes down to %d hp%n", boss.damage, player.armor, playerHp);
			if (playerHp <= 0) return false;
		}
	}

	record Item (String name, int gold, int damage, int armor) { }

	static final Item[] WEAPONS = {
		new Item("Dagger", 8, 4, 0),
		new Item("Shortsword", 10, 5, 0),
		new Item("Warhammer", 25, 6, 0),
		new Item("Longsword", 40, 7, 0),
		new Item("Greataxe", 74, 8, 0)
	};
	static final Item[] ARMOR = {
		new Item("Leather", 13, 0, 1),
		new Item("Chainmail", 31, 0, 2),
		new Item("Splintmail", 53, 0, 3),
		new Item("Bandedmail", 75, 0, 4),
		new Item("Platemail", 102, 0, 5),
		new Item("NONE", 0, 0, 0),
	};
	static final Item[] RINGS = {
		new Item("Damage +1", 25, 1, 0),
		new Item("Damage +2", 50, 2, 0),
		new Item("Damage +3", 100, 3, 0),
		new Item("Defense +1", 20, 0, 1),
		new Item("Defense +2", 40, 0, 2),
		new Item("Defense +3", 80, 0, 3),
		new Item("NONE", 0, 0, 0),
		new Item("NONE", 0, 0, 0),
	};

	private static boolean simulate(List<Item> shoppingCart, CharacterData boss) {
		int armor = 0;
		int damage = 0;
		for(var item: shoppingCart) {
			armor += item.armor;
			damage += item.damage;
		}
		var player = new CharacterData(100, damage, armor);
		return canPlayerWin(player, boss);
	}

	private static void allCombinations(Consumer<List<Item>> callback) {
		for (var wpn : WEAPONS) {
			for (var armor : ARMOR) {
				for (var ring1 : RINGS) {
					for (var ring2 : RINGS) {
						if (ring1 == ring2) continue;
						var shoppingCart = new ArrayList<Item>();
						// choose exactly one of...
						shoppingCart.add(wpn);
						// choose 0-1 of...
						shoppingCart.add(armor);
						// choose 0-2 of...
						shoppingCart.add(ring1);
						shoppingCart.add(ring2);
						callback.accept(shoppingCart);
					}
				}
			}
		}
	}

	private static int[] solve(CharacterData boss) {
		final int[] result = {0, 0};
		final boolean[] first = {true, true};
		allCombinations((shoppingCart) -> {
			int goldSpent = shoppingCart.stream().mapToInt(i -> i.gold).sum();
			boolean playerWins = simulate(shoppingCart, boss);
			int slot = playerWins ? 0 : 1;
			// System.out.println("Battle with " + shoppingCart.stream().map(i -> i.name).collect(Collectors.joining(", ")) + " gold remain: " + outcome);
			if (first[slot]) {
				result[slot] = goldSpent;
				first[slot] = false;
			}
			else {
				result[slot] = playerWins ? Math.min(result[slot], goldSpent) : Math.max(result[slot], goldSpent);
			}
		});
		return result;
	}

	public static void main(String[] args) throws IOException {
		var data = parse(Path.of("day21/input"));
		var result = solve(data);
		System.out.printf("%d%n%d%n", result[0], result[1]);
	}
}
