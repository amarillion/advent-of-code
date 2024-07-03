#!/usr/bin/env tsx
import { readFileSync } from 'fs'; 
const input = readFileSync(process.argv[2]).toString('utf-8'); 

const CARD_RANK = 'AKQJT98765432';
const CARD_RANK_WITH_JOKERS = 'AKQT98765432J';

function parse(raw: string) {
	return raw
		.split('\n')
		.filter(e => e !== '')
		.map(line => { 
			const fields = line.split(' '); 
			return { 
				hand: fields[0], 
				bid: Number(fields[1]),
			};
		});
}

// counts frequency of each card. For example, given a hand '32T3K', returns { '3': 2, '2': 1, 'T': 1, 'K': 1 }
function cardFrq(hand: string) {
	const frq: Record<string, number> = {};
	for(const card of hand) {
		if (card in frq) {
			frq[card] += 1;
		}
		else {
			frq[card] = 1;
		}
	}
	return frq;
}


function getType(hand: string) {
	// Take the /values/ returned by cardFrq, sort them descending, and flatten to a string.
	// This will result in the following possibilies
	//      "5": FIVE OF A KIND
	//      "41": FOUR OF A KIND
	//      "32": FULL HOUSE
	//      "311": THREE OF A KIND
	//      "221": TWO PAIR
	//      "2111": ONE PAIR
	//      "11111": HIGH CARD
	// These results will sort correctly naturally.
	return Object.values(cardFrq(hand)).sort().reverse().join('');
}

function getTypeWithJokers(hand: string) {
	const frq = cardFrq(hand); // start with the same frequency map
	// take Jokers out
	const numJokers = frq['J'] || 0;
	frq['J'] = 0; // delete also possible, but that could mess up case of 'JJJJJ'
	const frqVals = Object.values(frq).sort().reverse();
	frqVals[0] = frqVals[0] + numJokers; 	// Move Jokers to the first digit.
	return frqVals.filter(i => i !== 0).join(''); // 'J' is potentially 0, filter out these zeroes.
}

type Row = {
	hand: string,
	bid: number
};
type RowWithType = Row & { type: string };

function byRowRank(a: RowWithType, b: RowWithType) {
	let result = a.type.localeCompare(b.type); // first compare type
	for(let i = 0; i < 5; ++i) {
		if (result !== 0) return result; // if we haven't found a difference yet
		result = CARD_RANK.indexOf(b.hand[i]) - CARD_RANK.indexOf(a.hand[i]); // compare the cards at position i
	}
	return result;
}

function byRowRankWithJokers(a: RowWithType, b: RowWithType) {
	let result = a.type.localeCompare(b.type); // first compare type
	for(let i = 0; i < 5; ++i) {
		if (result !== 0) return result; // if we haven't found a difference yet
		result = CARD_RANK_WITH_JOKERS.indexOf(b.hand[i]) - CARD_RANK_WITH_JOKERS.indexOf(a.hand[i]); // compare the cards at position i
	}
	return result;
}

function solve(data : Row[], getTypeFunc: (hand: string) => string, comparisonFunc: (a: RowWithType, b: RowWithType) => number) {
	return data
		.map(row => ({ ...row, type: getTypeFunc(row.hand) })) // calculate the hand type for each hand. More efficient /before/ sort than during.
		.sort(comparisonFunc) // use our comparison function to sort
		.reduce((prev, cur, idx) => prev + (cur.bid) * (idx + 1), 0); //calculate the sum of card.bid * (idx + 1) using reduce
}

const data = parse(input);
console.log(solve(data, getType, byRowRank));
console.log(solve(data, getTypeWithJokers, byRowRankWithJokers));