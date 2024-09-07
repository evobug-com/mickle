// # Connection Status
//
// The Connection Status enum represents the status of a connection.
// It is used to indicate whether a connection is connected, connecting, or disconnected.

enum ConnectionStatus {
  /// The connection is disconnected.
  /// This status is used when the connection is not established.
  disconnected,

  /// The connection is connecting.
  /// This status is used when the connection is being established.
  connecting,

  /// The connection is connected.
  /// This status is used when the connection is established and ready to send and receive messages.
  connected,

  /// The connection is authenticating.
  /// This status is used when the connection is authenticating.
  authenticating,

  /// The connection is authenticated.
  /// This status is used when the connection is authenticated.
  authenticated,

  /// The connection has an error.
  /// This status is used when the connection has an error.
  error
}