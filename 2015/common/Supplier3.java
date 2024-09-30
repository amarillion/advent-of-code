package common;

@FunctionalInterface
public interface Supplier3<T, U, V> {
	void apply(T t, U u, V v);
}