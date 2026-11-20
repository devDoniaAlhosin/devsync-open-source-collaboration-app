class MatchingCacheConfig {
  final Duration ttl;

  final bool enabled;

  const MatchingCacheConfig({
    this.ttl = const Duration(hours: 1),
    this.enabled = true,
  });

  const MatchingCacheConfig.disabled() : ttl = Duration.zero, enabled = false;

  const MatchingCacheConfig.withTtl(this.ttl) : enabled = true;
}
