package day22;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Solution {

	private record Data(int hitpoints, int damage) {}
	boolean isHard;

	private static Data parse(Path file) throws IOException {
		try (Stream<String> s = Files.lines(file)) {
			var values = s
				.filter(l -> !l.isEmpty())
				.map(l -> l.split(": "))
				.collect(Collectors.toMap(l -> l[0], l -> Integer.parseInt(l[1])));
			return new Data(values.get("Hit Points"), values.get("Damage"));
		}
	}

	Solution(Path file) throws IOException {
		this.data = parse(file);
	}

	record GameState(
			int playerHp,
			int monsterHp,
			int mana,
			int poisonTurnsRemaining,
			int shieldTurnsRemaining,
			int rechargeTurnsRemaining
			) {
		
		GameState withDelta(int playerHp, int monsterHp, int mana, int poisonTurnsRemaining, int shieldTurnsRemaining, int rechargeTurnsRemaining) {
			return new GameState(
					this.playerHp + playerHp,
					this.monsterHp + monsterHp,
					this.mana + mana,
					this.poisonTurnsRemaining + poisonTurnsRemaining,
					this.shieldTurnsRemaining + shieldTurnsRemaining,
					this.rechargeTurnsRemaining + rechargeTurnsRemaining
			);
		}

		public GameState(int playerHp, int monsterHp, int mana, int poisonTurnsRemaining, int shieldTurnsRemaining, int rechargeTurnsRemaining) {
			this.playerHp = playerHp;
			this.monsterHp = monsterHp;
			this.mana = mana;
			this.poisonTurnsRemaining = poisonTurnsRemaining;
			this.shieldTurnsRemaining = shieldTurnsRemaining;
			this.rechargeTurnsRemaining = rechargeTurnsRemaining;
			if (!(mana >= 0
					&& poisonTurnsRemaining() >= 0
					&& shieldTurnsRemaining() >= 0
					&& rechargeTurnsRemaining() >= 0)) throw new IllegalArgumentException(String.format("Invalid state: " + this));
		}

		boolean isFinished() {
			return this.playerHp <= 0 || this.monsterHp <= 0;
		}

		GameState handleEffects() {
			if (isFinished()) return this;

			int shieldTurnsRemaining = this.shieldTurnsRemaining;
			int rechargeTurnsRemaining = this.rechargeTurnsRemaining;
			int poisonTurnsRemaining = this.poisonTurnsRemaining;
			int mana = this.mana;
			int monsterHp = this.monsterHp;
			if (shieldTurnsRemaining > 0) {
				shieldTurnsRemaining--;
			}
			if (rechargeTurnsRemaining > 0) {
				rechargeTurnsRemaining--;
				mana += 101;
			}
			if (poisonTurnsRemaining > 0) {
				poisonTurnsRemaining--;
				monsterHp -= 3;
			}
			return new GameState(playerHp, monsterHp, mana, poisonTurnsRemaining, shieldTurnsRemaining, rechargeTurnsRemaining);
		}

		public GameState hardMode(boolean isHard) {
			if (isFinished()) return this;
			if (isHard) {
				return this.withDelta(-1, 0, 0, 0, 0, 0);
			}
			return this;
		}

		private GameState doSpell(Spell spell) {
			if (isFinished()) return this;

			return switch (spell) {
				case MAGIC_MISSILE -> this.withDelta(
						0, -4, -spell.cost, 0, 0, 0
				);
				case DRAIN -> this.withDelta(
						2, -2, -spell.cost, 0, 0, 0
				);
				case SHIELD -> this.withDelta(
						0, 0, -spell.cost, 0, 6, 0
				);
				case POISON -> this.withDelta(
						0, 0, -spell.cost, 6, 0, 0
				);
				case RECHARGE -> this.withDelta(
						0, 0, -spell.cost, 0, 0, 5
				);
			};
		}

		private GameState doBossAttack(int bossDamage) {
			if (isFinished()) return this;

			int damage = (shieldTurnsRemaining > 0 ? Math.max(bossDamage - 7, 0) : bossDamage);
			return new GameState(
				Math.max(0, playerHp - damage),
				monsterHp,
				mana,
				poisonTurnsRemaining,
				shieldTurnsRemaining,
				rechargeTurnsRemaining
			);
		}

	}

	enum Spell {
		MAGIC_MISSILE(53),
		DRAIN(73),
		SHIELD(113),
		POISON(173),
		RECHARGE(229);

		final int cost;
		Spell(int cost) {
			this.cost = cost;
		}
	}

	private static Set<Spell> availableMoves(GameState state) {
		if (state.isFinished()) { return Set.of(); }

		Set<Spell> spells = new HashSet<>();
		for (var spell: Spell.values()) {
			if (state.mana >= spell.cost) { spells.add(spell); }
		}
		if (state.shieldTurnsRemaining > 1) { spells.remove(Spell.SHIELD); }
		if (state.rechargeTurnsRemaining > 1) { spells.remove(Spell.RECHARGE); }
		if (state.poisonTurnsRemaining > 1) { spells.remove(Spell.POISON); }
		return spells;
	}

	Data data;

	private Map<Spell, GameState> allMoves(GameState state) {
		var result = new HashMap<Spell, GameState>();
		for (var spell: availableMoves(state)) {
			var newState = doTurn(state, spell);
			result.put(spell, newState);
		}
		return result;
	}

	private static int getSpellCost(Spell spell) {
		return spell.cost;
	}

	private GameState doTurn(GameState state, Spell spell) {
		return state
			.hardMode(isHard)
			.handleEffects()
			.doSpell(spell)
			.handleEffects()
			.doBossAttack(data.damage);
	}

	record Step<N, E> (E edge, N from, N to, int cost) {};

	record DijkstraResult<N, E>(Map<N, Step<N, E>> prev, N dest) {};
	static <N, E> DijkstraResult<N, E> dijkstra(N source, Function<N, Boolean> isDest, Function<N, Map<E, N>> getAdjacent, Function<E, Integer> getWeight) {

		Map<N, Integer> dist = new HashMap<>();
		Set<N> visited = new HashSet<>();
		var prev = new HashMap<N, Step<N, E>>();
		PriorityQueue<N> open = new PriorityQueue<>(Comparator.comparingInt(dist::get));

		dist.put(source, 0);
		open.add(source);

		N dest = null;

		while (!open.isEmpty()) {
			N current = open.poll();

			// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter
			for (var pair: getAdjacent.apply(current).entrySet()) {
				var edge = pair.getKey();
				var sibling = pair.getValue();

				if (!(visited.contains(sibling))) {
					var alt = dist.get(current) + getWeight.apply(edge);
					var oldDist = dist.getOrDefault(sibling, Integer.MAX_VALUE);

					if (alt < oldDist) {
						// set or update distance
						dist.put(sibling, alt);
						// build back-tracking map
						prev.put(sibling, new Step<>( edge, current, sibling, alt ));
					}

					// any node that is !visited and has a distance assigned should be in open set.
					open.add (sibling); // may be already in there, that is OK.
				}
			}

			// A visited node will never be checked again.
			visited.add(current);

			if (isDest.apply(current)) {
				dest = current;
				break;
			}
		}

		return new DijkstraResult<>(prev, dest);
	}

	private void printRecursive(DijkstraResult<GameState, Spell> dijkstraResult, GameState state, String indent) {
		// find all the child states...
		for (var step: dijkstraResult.prev.values()) {
			if (step.from.equals(state)) {
				System.out.printf("%s%s: %d %s%n", indent, step.edge, step.cost, step.to);
				printRecursive(dijkstraResult, step.to, indent + "  ");
			}
		}
	}

	private <N, E> void debugPrint(DijkstraResult<N, E> dijkstraResult) {
		var sortedKeys = new ArrayList<>(dijkstraResult.prev.keySet());
		sortedKeys.sort(Comparator.comparingInt(a -> dijkstraResult.prev.get(a).cost));

		for (var key : sortedKeys) {
			var edge = dijkstraResult.prev.get(key);
			System.out.printf("%s: %s %d%n", key, edge.edge, edge.cost);
		}
		System.out.println(dijkstraResult.dest);
	}

	private long solve(int hitPoints, int mana, boolean isHard) {
		this.isHard = isHard;
		var start = new GameState(hitPoints, data.hitpoints, mana, 0, 0, 0);
		var dijkstraResult = dijkstra(start,
				s -> s.monsterHp <= 0,
				this::allMoves,
				Solution::getSpellCost
			);

		// trackback...
//		var current = dijkstraResult.dest;
//		while(dijkstraResult.prev.containsKey(current)) {
//			System.out.println(current);
//			var step = dijkstraResult.prev.get(current);
//			System.out.printf("Step %s %d\n", step.edge.toString(), step.cost);
//			current = step.from;
//		}

//		debugPrint(dijkstraResult);
//		printRecursive(dijkstraResult, start, "");
		return dijkstraResult.prev.get(dijkstraResult.dest).cost;
	}

	public static void main(String[] args) throws IOException {
		var testRunner = new Solution(Path.of("day22/test-input"));
		System.out.println(testRunner.solve(10, 250, false));
		var runner = new Solution(Path.of("day22/input"));
		System.out.println(runner.solve(50, 500, false));
		System.out.println(runner.solve(50, 500, true));
	}
}
