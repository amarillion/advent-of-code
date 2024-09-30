package common;

@FunctionalInterface
public interface Function3<T, U, V, R> {
	R apply(T t, U u, V v);
}