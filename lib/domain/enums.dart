/// Tipo de gasto, usado nas análises (fixo × variável × pontual).
enum ExpenseType { fixed, variable, oneOff }

enum Frequency { weekly, monthly, yearly, custom }

enum IncomeKind { salary, extra, other }

enum AttachmentOwner { transaction, payment }

enum UploadStatus { localOnly, pending, uploaded, failed }

enum SyncState { disconnected, connected, syncing, synced, error }
