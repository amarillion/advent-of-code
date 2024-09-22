package common;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class Map2D<K, V> {
	private final Map <K, Map<K, V>> data = new HashMap<>();

	public void put(K from, K to, V value) {
		if (!data.containsKey(from)) {
			data.put(from, new HashMap<>());
		}
		data.get(from).put(to, value);
	}

	public V get(K from, K to) {
		return data.get(from).get(to);
	}

	public Set<K> keySet() {
		return data.keySet();
	}
}
