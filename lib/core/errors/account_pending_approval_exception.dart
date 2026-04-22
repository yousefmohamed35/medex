/// Thrown when the account exists but is not yet approved by an admin.
class AccountPendingApprovalException implements Exception {
  final String? serverMessage;

  AccountPendingApprovalException([this.serverMessage]);

  @override
  String toString() => serverMessage ?? 'Account pending admin approval';
}
