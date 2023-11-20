export class Node<T> {
	prev: Node<T>;
	next: Node<T>;
	value: T

	constructor(value: T) {
		this.value = value;
	}
}

/**
 * A circular doubly-linked list.
 */
export class Dlist<T> {

	head: Node<T>|null = null;
	
	push(value: T) {
		const node = new Node(value);
		if (this.head == null) {
			this.head = node;
			node.next = node;
			node.prev = node;
		}
		else {
			const begin = this.head.next;
			
			this.head.next = node;
			node.prev = this.head;
			node.next = begin;
			begin.prev = node;
			
			this.head = node;
	
		}
		return node;
	}

	*iterate() {
		const begin = this.head.next;
		let current = begin;
		do {
			yield current;
			current = current.next;
		}
		while (current !== begin)
	}
	
	find(predicate: (t: T) => boolean) {
		const begin = this.head.next;
		let current = begin;
		while (!predicate(current.value)) {
			current = current.next;
			if (current === begin) { return null; } // not found after complete cycle.
		}
		return current;
	}

}

export function skip<T>(ptr: Node<T>, num: number) {
	let current = ptr;
	for (let i = 0; i < num; ++i) {
		current = current.next;
	}
	return current;
}
