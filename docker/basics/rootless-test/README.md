This context is prepared by `22-docker-rootless.sh` in a private temporary
directory. It adds the native gosu 1.17 binary from the repository's existing
`postgres-test/{amd64,arm64}` assets after checking its pinned SHA256. It does
not require a PostgreSQL image, database or previous lesson run.

Upstream: https://github.com/tianon/gosu/tree/1.17
Release binaries: https://github.com/tianon/gosu/releases/tag/1.17
Installation and signature verification: https://github.com/tianon/gosu/blob/1.17/INSTALL.md

The tutorial checks a pinned checksum; it does not claim to perform GPG
signature verification. `gosu-LICENSE` is the unchanged upstream Apache 2.0
license. The upstream release has no NOTICE file. The binary also contains
Go and dependency code; its upstream source and module dependency notices
are available at the tagged source above. No gosu source or binary is
modified. The first-party demonstration scripts have separate GPL notices.
