/// Placeholder for `FieldValue.serverTimestamp()` in writes that are queued
/// locally first (outbox): the domain stays free of Firestore sentinels and
/// the uploader swaps it for the real one. Rules compare such fields with
/// `request.time`.
final class ServerTime {
  const ServerTime._();
}

const serverTime = ServerTime._();
