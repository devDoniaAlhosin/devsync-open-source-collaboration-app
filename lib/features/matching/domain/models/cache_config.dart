/// Configuration for matching cache behavior.
///
/// Controls cache TTL (time-to-live) and whether caching is enabled.
class MatchingCacheConfig {
  /// Cache time-to-live duration.
  ///
  /// Default: 1 hour
  final Duration ttl;

  /// Whether caching is enabled.
  ///
  /// Default: true
  final bool enabled;

  const MatchingCacheConfig({
    this.ttl = const Duration(hours: 1),
    this.enabled = true,
  });

  /// Create a disabled cache configuration.
  const MatchingCacheConfig.disabled() : ttl = Duration.zero, enabled = false;

  /// Create a custom TTL configuration.
  const MatchingCacheConfig.withTtl(this.ttl) : enabled = true;
}
