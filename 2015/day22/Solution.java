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
	boolean logging = false;

	void log(String str) {
		if (logging) {
			System.out.println(str);
		}
	}

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
//			boolean playerTurn,
			int poisonTurnsRemaining,
			int shieldTurnsRemaining,
			int rechargeTurnsRemaining
			) {
		
		GameState withDelta(int playerHp, int monsterHp, int mana, int poisonTurnsRemaining, int shieldTurnsRemaining, int rechargeTurnsRemaining) {
			GameState result = new GameState(
					this.playerHp + playerHp,
					this.monsterHp + monsterHp,
					this.mana + mana,
					this.poisonTurnsRemaining + poisonTurnsRemaining,
					this.shieldTurnsRemaining + shieldTurnsRemaining,
					this.rechargeTurnsRemaining + rechargeTurnsRemaining
			);
			assert (result.valid());
			return result;
		}

		boolean valid() {
			return this.playerHp() >= 0
			&& this.monsterHp() >= 0
			&& this.mana() >= 0
			&& this.poisonTurnsRemaining() >= 0
			&& this.shieldTurnsRemaining() >= 0
			&& this.rechargeTurnsRemaining() >= 0;
		}

		boolean isFinished() {
			return this.playerHp <= 0 || this.monsterHp <= 0;
		}

		GameState applyEffects() {
			GameState result = new GameState(
					this.playerHp,
					this.monsterHp ,
					this.mana,
					Math.max(0, this.poisonTurnsRemaining - 1),
					Math.max(0, this.shieldTurnsRemaining - 1),
					Math.max(0, this.rechargeTurnsRemaining - 1)
			);
			assert(result.valid());
			return result;
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
		if (state.shieldTurnsRemaining > 0) { spells.remove(Spell.SHIELD); }
		if (state.rechargeTurnsRemaining > 0) { spells.remove(Spell.RECHARGE); }
		if (state.poisonTurnsRemaining > 0) { spells.remove(Spell.POISON); }
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

	private GameState doSpell(Spell spell, GameState state) {
		log(String.format("Player casts %s\n", spell.toString()));
		var result = switch (spell) {
			case MAGIC_MISSILE -> state.withDelta(
				0, -4, -spell.cost, 0, 0, 0
			);
			case DRAIN -> state.withDelta(
				2, -2, -spell.cost, 0, 0, 0
			);
			case SHIELD -> state.withDelta(
				0, 0, -spell.cost, 0, 6, 0
			);
			case POISON -> state.withDelta(
				0, 0, -spell.cost, 6, 0, 0
			);
			case RECHARGE -> state.withDelta(
				0, 0, -spell.cost, 0, 0, 5
			);
		};
		if (result.monsterHp <= 0) {
			log("The boss is killed and the player wins");
		}
		return result;
	}

	private GameState handleEffects(GameState state) {
		int shieldTurnsRemaining = state.shieldTurnsRemaining;
		int rechargeTurnsRemaining = state.rechargeTurnsRemaining;
		int poisonTurnsRemaining = state.poisonTurnsRemaining;
		int mana = state.mana;
		int monsterHp = state.monsterHp;
		if (shieldTurnsRemaining > 0) {
			shieldTurnsRemaining--;
			log("Shield's timer is now: " + shieldTurnsRemaining);
			if (shieldTurnsRemaining == 0) {
				log("Shield wears off");
			}
		}
		if (rechargeTurnsRemaining > 0) {
			rechargeTurnsRemaining--;
			mana += 101;
			log("Recharge provides 101 mana, its timer is now: " + rechargeTurnsRemaining);
			if (rechargeTurnsRemaining == 0) {
				log("Recharge wears off");
			}
		}
		if (poisonTurnsRemaining > 0) {
			poisonTurnsRemaining--;
			log("Poison deals 3 damage, its timer is now: " + poisonTurnsRemaining);
			monsterHp -= 3;
			if (poisonTurnsRemaining == 0) {
				log("Poison wears off");
			}
			if (monsterHp <= 0) {
				log("The boss is killed and the player wins");
			}
		}
		return new GameState(state.playerHp, monsterHp, mana, poisonTurnsRemaining, shieldTurnsRemaining, rechargeTurnsRemaining);
	}

	private void printState(String turn, GameState state) {
		log(String.format("""
				-- %s turn --
				-- Player has %d hit points, %d armor, %d mana --
				-- Boss has %d hit points.
				""", turn, state.playerHp, state.shieldTurnsRemaining > 0 ? 7 : 0, state.mana, state.monsterHp));
	}

	private GameState doBossAttack(GameState state, int bossDamage) {
		int damage = (state.shieldTurnsRemaining > 0 ? Math.max(bossDamage - 7, 0) : bossDamage);
		log(String.format("Boss attacks for %d damage\n", damage));
		return new GameState(
				Math.max(0, state.playerHp - damage),
				state.monsterHp,
				state.mana,
				state.poisonTurnsRemaining,
				state.shieldTurnsRemaining,
				state.rechargeTurnsRemaining
		);
	}

	private GameState doTurn(GameState state, Spell spell) {
		printState("Player", state);

		GameState state2 = handleEffects(state);
		if (state2.isFinished()) {
			return state2;
		}

		GameState state3 = doSpell(spell, state2);
		if (state3.isFinished()) {
			return state3;
		}

		printState("Boss", state3);

		var state4 = handleEffects(state3);
		if (state4.isFinished()) {
			return state4;
		}

		var state5 = doBossAttack(state4, data.damage);
		if (state5.playerHp <= 0) {
			log("The player died");
		}

		return state5;
	}

	record Step<N, E> (E edge, N from, N to, int cost) {};

	record DijkstraResult<N, E>(Map<N, Step<N, E>> prev, N dest) {};
	static <N, E> DijkstraResult<N, E> dijkstra(N source, Function<N, Boolean> isDest, Function<N, Map<E, N>> getAdjacent, Function<E, Integer> getWeight) {

		Map<N, Integer> dist = new HashMap<>();
		Set<N> visited = new HashSet<>();
		var prev = new HashMap<N, Step<N, E>>();
		PriorityQueue<N> open = new PriorityQueue<>(Comparator.comparingInt(n -> dist.getOrDefault(n, -1)));

		open.add(source);
		dist.put(source, 0);

		final int MAX_ITERATIONS = 1000;
		var i = MAX_ITERATIONS;

		N current = null;

		while (!open.isEmpty()) {
			i--; // 0 -> -1 means Infinite.
			if (i == 0) break;

			current = open.poll();

			// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter

			for (var pair: getAdjacent.apply(current).entrySet()) {
				var edge = pair.getKey();
				var sibling = pair.getValue();

				if (!(visited.contains(sibling))) {
					var alt = dist.get(current) + getWeight.apply(edge);

					// any node that is !visited and has a distance assigned should be in open set.
					open.add (sibling); // may be already in there, that is OK.

					var oldDist = dist.getOrDefault(sibling, Integer.MAX_VALUE);

					if (alt < oldDist) {
						// set or update distance
						dist.put(sibling, alt);
						// build back-tracking map
						prev.put(sibling, new Step<>( edge, current, sibling, alt ));
					}
				}
			}

			// A visited node will never be checked again.
			visited.add(current);

			if (isDest.apply(current)) {
				break;
			}
		}

		return new DijkstraResult<>(prev, current);
	}

	private void printRecursive(DijkstraResult<GameState, Spell> dijkstraResult, GameState state, String indent) {
		// find all the child states...
		for (var step: dijkstraResult.prev.values()) {
			if (step.from == state) {
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

	private long solve1(int hitPoints, int mana) {
		long result = 0;

		var start = new GameState(hitPoints, data.hitpoints, mana, 0, 0, 0);

//		GameState current = start;
//		for (var sp : new Spell[] { Spell.SHIELD }) {
//			var next = doTurn(current, sp);
//			if (next.isFinished()) { break; }
//			current = next;
//		}

		var dijkstraResult = dijkstra(start,
				s -> s.monsterHp <= 0,
				this::allMoves,
				Solution::getSpellCost
			);

		var current = dijkstraResult.dest;
		while(dijkstraResult.prev.containsKey(current)) {
			System.out.println(current);
			var step = dijkstraResult.prev.get(current);
			System.out.printf("Step %s %d\n", step.edge.toString(), step.cost);
			current = step.from;
		}

//		debugPrint(dijkstraResult);
		printRecursive(dijkstraResult, start, "");

		return result;
	}

	public static void main(String[] args) throws IOException {
		assert(false);
//		var testRunner = new Solution(Path.of("day22/test-input"));
//		System.out.println(testRunner.solve1(10, 250));
		var runner = new Solution(Path.of("day22/input"));
		System.out.println(runner.solve1(50, 500));
	}
}

