#!/usr/bin/env tsx

class Monkey {
	items: number[];
	op: (x: number) => number;
	modulo: number;
	ifTrue: number;
	ifFalse: number;
}

const TEST_INPUT: Monkey[] = [{
	items: [79, 98],
	op: x => x * 19,
	modulo: 23, ifTrue: 2, ifFalse: 3
}, {
	items: [54, 65, 75, 74],
	op: x => x + 6,
	modulo: 19, ifTrue: 2, ifFalse: 0,
}, {
	items: [79, 60, 97],
	op: x => x * x,
	modulo: 13, ifTrue: 1, ifFalse: 3
}, {
	items: [74],
	op: x => x + 3,
	modulo: 17, ifTrue: 0, ifFalse: 1
}];

const INPUT: Monkey[] = [{ 
	items: [54, 89, 94],
	op: x => x * 7,
	modulo: 17,
	ifTrue:5,
	ifFalse:3,
}, { 
	items: [66, 71],
	op: x => x + 4,
	modulo: 3,
	ifTrue: 0,
	ifFalse: 3,
}, { 
	items: [ 76, 55, 80, 55, 55, 96, 78 ],
  	op: x => x + 2,
	modulo: 5,
	ifTrue: 7,
	ifFalse: 4,
}, { 
	items: [ 93, 69, 76, 66, 89, 54, 59, 94 ],
  	op:  x => x + 7,
	modulo: 7,
	ifTrue: 5,
	ifFalse: 2,
}, { 
	items: [ 80, 54, 58, 75, 99 ],
	op: x => x * 17,
	modulo: 11,
	ifTrue: 1,
	ifFalse: 6,
}, {
	items: [ 69, 70, 85, 83 ],
	op: x => x + 8,
	modulo: 19,
	ifTrue: 2,
	ifFalse: 7,
}, {
	items: [ 89 ],
	op: x => x + 6,
	modulo: 2,
	ifTrue: 0,
	ifFalse: 1
}, { 
	items: [ 62, 80, 58, 57, 93, 56 ],
	op: x => x * x,
	modulo: 13,
	ifTrue: 6,
	ifFalse: 4
}];

function doRound(round: number, monkeys: Monkey[], activity: Map<number, number>, worryReduction: boolean, filter: number, log: boolean) {
	if (log) console.log(`ROUND ${round}`);
	let mi = 0;
	for (const m of monkeys) {
		if (log) console.log(`Monkey ${mi}:`);
		while (m.items.length > 0) {
			let i = m.items.shift();
			if (log) console.log(`  Monkey inspects an item with worry level ${i}`);
			// TODO: use function to modify map
			activity.set(mi, activity.get(mi) + 1);
			i = m.op(i);
			if (log) console.log(`    New worry level: ${i}`);
			if (worryReduction) {
				i = Math.floor(i / 3);
				if (log) console.log(`    Divided by three: ${i}`);
			}
			i %= filter; // alternative worry reduction
			const divisible = (i % m.modulo) === 0;
			if (log) console.log(`    Current worry level ${divisible ? "" : "not "} divisible by ${m.modulo}`);
			const target = divisible ? m.ifTrue : m.ifFalse;
			if (log) console.log(`    Item with worry level ${i} is thrown to monkey ${target}`);
			monkeys[target].items.push(i);
		}
		mi++;
	}
}

function run(monkeys: Monkey[], max_rounds: number, worryReduction = true) {
	const filter = monkeys.reduce((acc, cur) => acc *= cur.modulo, 1);
	console.log("Filter: ", filter);

	//TODO: use DefaultMap
	const activity = new Map<number, number>();
	for (let mi = 0; mi < monkeys.length; ++mi) {
		activity.set(mi, 0);
	}

	for (let round = 1; round <= max_rounds; ++round) {
		doRound(round, monkeys, activity, worryReduction, filter, round === 1);

		if (round == 1 || round == 20 || round % 1000 == 0) {
			console.log(`End of round ${round}`);
			for (let mi = 0; mi < monkeys.length; ++mi) {
				console.log(`Monkey ${mi} inspected items ${activity.get(mi)} times`);
			}
		}
	
	}

	const activities = [...activity.values()].sort((a, b) => b - a)
	console.log(activities);
	console.log("Total: ", activities[0] * activities[1]);
}

// run(TEST_INPUT, 20);
// run(INPUT, 20);


// TODO: make a deep copy of Monkeys array, so it can be re-used.
run(TEST_INPUT, 10_000, false);
run(INPUT, 10_000, false);
