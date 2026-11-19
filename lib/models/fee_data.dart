import 'package:flutter/foundation.dart';

/// "Rs. 50,000" — a rupee amount with the reference design's thousands
/// grouping. Kept local so the model stays dependency-free (no `intl`).
String rs(int amount) {
  final String digits = amount.toString();
  final StringBuffer grouped = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  return 'Rs. $grouped';
}

/// One line of an invoice's fee breakdown, as the invoice sheet presents it.
@immutable
class FeeBreakdownLine {
  const FeeBreakdownLine({
    required this.label,
    required this.amount,
    this.note,
  });

  final String label;
  final int amount;

  /// Parenthetical shown after the amount, e.g. `(Route A)`.
  final String? note;

  /// "Rs. 8,000 (Route A)"
  String get display => note == null ? rs(amount) : '${rs(amount)} ($note)';
}

/// A fee the student owes or has already settled.
@immutable
class FeeInvoice {
  const FeeInvoice({
    required this.id,
    required this.title,
    required this.amount,
    required this.group,
    required this.lines,
    required this.dueDate,
    this.paidOn,
    this.paymentMode = kPendingPaymentMode,
    this.receiptNo = kUnissuedReceipt,
  });

  /// "INV-2083-01"
  final String id;

  /// "Annual Fee"
  final String title;

  final int amount;

  /// Bucket this invoice rolls up into on the summary card, e.g.
  /// "Tuition & Facilities". The summary groups by this label so its
  /// breakdown always sums from the invoice list beneath it.
  final String group;

  /// Itemised lines shown in the invoice detail sheet.
  final List<FeeBreakdownLine> lines;

  final String dueDate;

  /// Date of settlement; `null` while the invoice is outstanding.
  final String? paidOn;

  final String paymentMode;
  final String receiptNo;

  bool get isPaid => paidOn != null;

  /// Card subtitle — "Paid · 2083-04-12" or "Due: 2083-09-10".
  String get statusLine => isPaid ? 'Paid · $paidOn' : 'Due: $dueDate';

  /// The invoice marked as settled through [mode].
  FeeInvoice settled({
    required String on,
    required String mode,
    required String receipt,
  }) => FeeInvoice(
    id: id,
    title: title,
    amount: amount,
    group: group,
    lines: lines,
    dueDate: dueDate,
    paidOn: on,
    paymentMode: mode,
    receiptNo: receipt,
  );

  /// The invoice back in its unpaid state — used by the summary card's
  /// simulation controls.
  FeeInvoice asPending() => FeeInvoice(
    id: id,
    title: title,
    amount: amount,
    group: group,
    lines: lines,
    dueDate: dueDate,
  );
}

/// One row of the Transactions tab.
@immutable
class FeeTransaction {
  const FeeTransaction({
    required this.id,
    required this.invoiceTitle,
    required this.method,
    required this.timestamp,
    required this.amount,
    this.fresh = false,
  });

  /// "TXN-9021"
  final String id;

  final String invoiceTitle;

  /// "Online Khalti"
  final String method;

  /// "2083-04-12 · 10:15 AM"
  final String timestamp;

  final int amount;

  /// True for a row created in this session — rendered with the reference's
  /// highlighted "just paid" treatment.
  final bool fresh;
}

/// One selectable payment gateway on the payment sheet.
@immutable
class PaymentGateway {
  const PaymentGateway({
    required this.name,
    required this.displayName,
    required this.subtitle,
    required this.monogram,
  });

  /// Short name — toast copy and the invoice's Payment Mode row.
  final String name;

  /// "eSewa Mobile Wallet" — the row's title.
  final String displayName;

  /// Small caption under [displayName].
  final String subtitle;

  /// Monogram in the row's leading tile, e.g. "KH".
  final String monogram;
}

/// Payment Mode of an invoice nobody has paid yet.
const String kPendingPaymentMode = 'Pending Checkout';

/// Receipt number of an invoice nobody has paid yet.
const String kUnissuedReceipt = 'Unissued';

/// Invoice the summary card's simulation controls act on.
const String kTransportInvoiceId = 'INV-2083-03';

/// Date stamped onto a simulated settlement.
const String kSettlementDate = '2083-09-08';

/// Receipt number minted by a simulated settlement.
const String kSettlementReceipt = 'RCP-2083-9982';

/// Transaction id of the row a simulated payment prepends.
const String kSettlementTransactionId = 'TXN-9982';

/// Payment mode recorded when every fee is settled at once.
const String kCounterPaymentMode = 'School Counter';

const List<FeeInvoice> kFeeInvoices = <FeeInvoice>[
  FeeInvoice(
    id: 'INV-2083-01',
    title: 'Annual Fee',
    amount: 20000,
    group: 'Tuition & Facilities',
    lines: <FeeBreakdownLine>[
      FeeBreakdownLine(label: 'Tuition & Curriculum Fee', amount: 12000),
      FeeBreakdownLine(label: 'Development Fund', amount: 5000),
      FeeBreakdownLine(label: 'Student Activities & Sports', amount: 3000),
    ],
    dueDate: '2083-04-12',
    paidOn: '2083-04-12',
    paymentMode: 'Online Khalti',
    receiptNo: 'RCP-2083-9912',
  ),
  FeeInvoice(
    id: 'INV-2083-02',
    title: 'Exam Fee',
    amount: 10000,
    group: 'Tuition & Facilities',
    lines: <FeeBreakdownLine>[
      FeeBreakdownLine(label: 'Tuition & Curriculum Fee', amount: 7000),
      FeeBreakdownLine(label: 'Development Fund', amount: 1500),
      FeeBreakdownLine(label: 'Student Activities & Sports', amount: 1500),
    ],
    dueDate: '2083-06-15',
    paidOn: '2083-06-15',
    paymentMode: 'eSewa Digital Wallet',
    receiptNo: 'RCP-2083-8842',
  ),
  FeeInvoice(
    id: kTransportInvoiceId,
    title: 'Transport Fee',
    amount: 10000,
    group: 'Transportation & Bus',
    lines: <FeeBreakdownLine>[
      FeeBreakdownLine(
        label: 'Tuition & Curriculum Fee',
        amount: 8000,
        note: 'Route A',
      ),
      FeeBreakdownLine(
        label: 'Development Fund',
        amount: 1000,
        note: 'Maintenance',
      ),
      FeeBreakdownLine(
        label: 'Student Activities & Sports',
        amount: 1000,
        note: 'Insurance',
      ),
    ],
    dueDate: '2083-09-10',
  ),
  FeeInvoice(
    id: 'INV-2083-04',
    title: 'Library Fee',
    amount: 5000,
    group: 'Lab, Exam & Library',
    lines: <FeeBreakdownLine>[
      FeeBreakdownLine(
        label: 'Tuition & Curriculum Fee',
        amount: 3500,
        note: 'Catalog & Digital',
      ),
      FeeBreakdownLine(label: 'Development Fund', amount: 1000),
      FeeBreakdownLine(
        label: 'Student Activities & Sports',
        amount: 500,
        note: 'Pass',
      ),
    ],
    dueDate: '2083-03-10',
    paidOn: '2083-03-10',
    paymentMode: 'Bank Transfer (Counter)',
    receiptNo: 'RCP-2083-7102',
  ),
];

const List<FeeTransaction> kFeeTransactions = <FeeTransaction>[
  FeeTransaction(
    id: 'TXN-9021',
    invoiceTitle: 'Annual Fee',
    method: 'Online Khalti',
    timestamp: '2083-04-12 · 10:15 AM',
    amount: 20000,
  ),
  FeeTransaction(
    id: 'TXN-8742',
    invoiceTitle: 'Exam Fee',
    method: 'eSewa Digital Wallet',
    timestamp: '2083-06-15 · 11:24 AM',
    amount: 10000,
  ),
  FeeTransaction(
    id: 'TXN-7102',
    invoiceTitle: 'Library Fee',
    method: 'Bank Transfer',
    timestamp: '2083-03-10 · 02:40 PM',
    amount: 5000,
  ),
];

const List<PaymentGateway> kPaymentGateways = <PaymentGateway>[
  PaymentGateway(
    name: 'eSewa',
    displayName: 'eSewa Mobile Wallet',
    subtitle: 'Instant direct clearance',
    monogram: 'eS',
  ),
  PaymentGateway(
    name: 'Khalti',
    displayName: 'Khalti Digital Wallet',
    subtitle: 'Pay with Khalti PIN',
    monogram: 'KH',
  ),
  PaymentGateway(
    name: 'ConnectIPS',
    displayName: 'connectIPS / Bank Account',
    subtitle: 'Direct debit transfer',
    monogram: 'IPS',
  ),
  PaymentGateway(
    name: 'SCT / Visa Card',
    displayName: 'Debit / Credit Card',
    subtitle: 'Visa / Mastercard / SCT',
    monogram: 'CARD',
  ),
];
