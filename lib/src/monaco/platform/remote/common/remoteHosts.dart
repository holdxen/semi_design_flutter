// 1:1 port of vscode/src/vs/platform/remote/common/remoteHosts.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c

import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/uri.dart' show URI;

/// 1:1: `export function getRemoteAuthority`
String? getRemoteAuthority(URI uri) =>
    uri.scheme == Schemas.vscodeRemote ? uri.authority : null;

/// 1:1: `export function getRemoteName`
///
/// Dart has no overloads: `undefined` -> `null`.
String? getRemoteName(String? authority) {
  if (authority == null || authority.isEmpty) {
    return null;
  }
  final int pos = authority.indexOf('+');
  if (pos < 0) {
    // e.g. localhost:8000
    return authority;
  }
  return authority.substring(0, pos);
}

/// Returns the suffix part of the authority after the '+' character.
/// For remote connections, this is typically the server/tunnel identifier.
/// Examples:
/// - For tunnels: `tunnel+myTunnel` returns `myTunnel`
/// - For SSH: `ssh+myserver` returns `myserver`
/// - For localhost: `localhost:8000` returns `undefined`
///
/// 1:1: `export function getRemoteServerRootPath`
String? getRemoteServerRootPath(String? authority) {
  if (authority == null || authority.isEmpty) {
    return null;
  }
  final int pos = authority.indexOf('+');
  if (pos < 0) {
    return null;
  }
  return authority.substring(pos + 1);
}

/// Object-literal return `{ host: string; port: number }` -> value class.
class AuthorityWithPort {
  final String host;
  final int port;

  const AuthorityWithPort(this.host, this.port);
}

/// 1:1: `export function parseAuthorityWithPort`
AuthorityWithPort parseAuthorityWithPort(String authority) {
  final _Authority authorityParts = _parseAuthority(authority);
  final int? port = authorityParts.port;
  if (port == null) {
    throw StateError(
        'Invalid remote authority: $authority. It must either be a remote of form <remoteName>+<arg> or a remote host of form <host>:<port>.');
  }
  return AuthorityWithPort(authorityParts.host, port);
}

/// 1:1: `export function parseAuthorityWithOptionalPort`
AuthorityWithPort parseAuthorityWithOptionalPort(
    String authority, int defaultPort) {
  final _Authority parsed = _parseAuthority(authority);
  int? port = parsed.port;
  if (port == null) {
    port = defaultPort;
  }
  return AuthorityWithPort(parsed.host, port);
}

/// Object-literal return of private `parseAuthority`.
class _Authority {
  final String host;
  final int? port;

  const _Authority(this.host, this.port);
}

/// 1:1: private `function parseAuthority`
_Authority _parseAuthority(String authority) {
  // check for ipv6 with port
  final RegExpMatch? m1 =
      RegExp(r'^(\[[0-9a-z:]+\]):(\d+)$').firstMatch(authority);
  if (m1 != null) {
    return _Authority(m1.group(1)!, int.parse(m1.group(2)!, radix: 10));
  }

  // check for ipv6 without port
  final RegExpMatch? m2 = RegExp(r'^(\[[0-9a-z:]+\])$').firstMatch(authority);
  if (m2 != null) {
    return _Authority(m2.group(1)!, null);
  }

  // anything with a trailing port
  final RegExpMatch? m3 = RegExp(r'(.*):(\d+)$').firstMatch(authority);
  if (m3 != null) {
    return _Authority(m3.group(1)!, int.parse(m3.group(2)!, radix: 10));
  }

  // doesn't contain a port
  return _Authority(authority, null);
}

/// 1:1: `const loopbackHosts = new Set([...])`
final Set<String> loopbackHosts = <String>{
  'localhost',
  '127.0.0.1',
  '::1',
  '[::1]',
  '0000:0000:0000:0000:0000:0000:0000:0001',
  '[0000:0000:0000:0000:0000:0000:0000:0001]',
};

/// Returns whether the given host (as found in a direct `<host>:<port>` remote
/// authority) refers to the local loopback interface. The check is intentionally
/// strict: only `localhost` and the IPv4/IPv6 loopback literals are considered
/// local. Any other host (a routable IP address or a hostname) is treated as a
/// connection that leaves the local machine.
///
/// 1:1: `export function isLoopbackHost`
bool isLoopbackHost(String host) => loopbackHosts.contains(host.toLowerCase());
