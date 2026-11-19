import 'package:flutter/material.dart';

/// One stop on the bus route.
@immutable
class TransportStop {
  const TransportStop({
    required this.name,
    required this.time,
    this.isPickup = false,
  });

  final String name;

  /// Scheduled time, shown under non-pickup stops.
  final String time;

  /// The student's own stop — highlighted and carrying the live status line.
  final bool isPickup;
}

/// One snapshotted point in the live-progress simulation.
///
/// The reference models the route as three milestones (depot, pickup, school);
/// advancing moves the bus pin, the progress bar, the ETA badge, the speed
/// readout and the stop-info bubble together.
@immutable
class TransportMilestone {
  const TransportMilestone({
    required this.progress,
    required this.activeStop,
    required this.eta,
    required this.speed,
    required this.infoTitle,
    required this.infoDetail,
    required this.infoDistance,
    required this.pickupStatus,
    required this.toast,
  });

  /// Fraction of the route the bus has covered, 0–1.
  final double progress;

  /// Index into [kTransportStops] the bus pin floats above.
  final int activeStop;

  /// ETA badge copy, e.g. "ETA: 2 mins".
  final String eta;

  /// Live speed readout, e.g. "28 km/h".
  final String speed;

  /// Stop-info bubble: the stop name, its parenthetical detail and distance.
  final String infoTitle;
  final String infoDetail;
  final String infoDistance;

  /// Status under the pickup stop, e.g. "Arriving Now".
  final String pickupStatus;

  /// Confirmation shown when this milestone becomes current.
  final String toast;
}

/// Every fixed detail the Transport screen reads.
@immutable
class TransportInfo {
  const TransportInfo({
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.driverDial,
    required this.attendantName,
    required this.attendantInitials,
    required this.attendantDial,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.onTimeLabel,
    required this.pickupPoint,
    required this.pickupBadge,
  });

  final String busNumber;

  final String driverName;

  /// Local-format number shown in the card, e.g. "9841234567".
  final String driverPhone;

  /// International number shown in the call sheet, e.g. "+977 9841234567".
  final String driverDial;

  final String attendantName;
  final String attendantInitials;
  final String attendantDial;

  final String from;
  final String to;

  final String departureTime;

  /// On-time badge copy; split over two lines by the card.
  final String onTimeLabel;

  final String pickupPoint;

  /// Badge beside the pickup point, e.g. "Your Stop".
  final String pickupBadge;
}

/// One category on the emergency sheet.
@immutable
class EmergencyReason {
  const EmergencyReason({
    required this.emoji,
    required this.label,
    required this.message,
  });

  final String emoji;

  /// Short button label, e.g. "Breakdown".
  final String label;

  /// Full reason sent with the alert.
  final String message;
}

const TransportInfo kTransport = TransportInfo(
  busNumber: 'Bus No. 3',
  driverName: 'Ram Sharma',
  driverPhone: '9841234567',
  driverDial: '+977 9841234567',
  attendantName: 'Sanjay Chaudhary',
  attendantInitials: 'SC',
  attendantDial: '+977 9801239876',
  from: 'Biratnagar',
  to: 'School',
  departureTime: '7:20 AM',
  onTimeLabel: 'ON TIME',
  pickupPoint: 'Main Chowk',
  pickupBadge: 'Your Stop',
);

/// Route stops, in travel order.
const List<TransportStop> kTransportStops = <TransportStop>[
  TransportStop(name: 'Depot', time: '7:00 AM'),
  TransportStop(name: 'Main Chowk', time: '7:20 AM', isPickup: true),
  TransportStop(name: 'School', time: '7:45 AM'),
];

/// The three simulation milestones. Index 1 (the pickup stop) is the default.
const List<TransportMilestone> kTransportMilestones = <TransportMilestone>[
  TransportMilestone(
    progress: 0.15,
    activeStop: 0,
    eta: 'ETA: 12 mins',
    speed: '32 km/h',
    infoTitle: 'Depot',
    infoDetail: '(Departed 7:05 AM)',
    infoDistance: '2.4 km away',
    pickupStatus: 'Upcoming',
    toast: 'Depot: Departed 7:00 AM on schedule',
  ),
  TransportMilestone(
    progress: 0.5,
    activeStop: 1,
    eta: 'ETA: 2 mins',
    speed: '28 km/h',
    infoTitle: 'Main Chowk',
    infoDetail: '(Scheduled 7:20 AM)',
    infoDistance: '0.2 km away',
    pickupStatus: 'Arriving Now',
    toast: 'Main Chowk: Your pickup point (Arriving Now)',
  ),
  TransportMilestone(
    progress: 0.85,
    activeStop: 2,
    eta: 'ETA: 1 min',
    speed: '30 km/h',
    infoTitle: 'School',
    infoDetail: '(Campus Gate)',
    infoDistance: 'Approaching Entry',
    pickupStatus: 'Passed',
    toast: 'School: Destination ETA 7:45 AM',
  ),
];

/// Categories selectable on the emergency sheet.
const List<EmergencyReason> kEmergencyReasons = <EmergencyReason>[
  EmergencyReason(
    emoji: '⏱️',
    label: 'Bus Delayed',
    message: 'Bus Delayed (Traffic/Route)',
  ),
  EmergencyReason(
    emoji: '⚠️',
    label: 'Breakdown',
    message: 'Accident / Breakdown',
  ),
  EmergencyReason(
    emoji: '🎒',
    label: 'Lost Item',
    message: 'Lost Belonging on Bus',
  ),
  EmergencyReason(
    emoji: '🚑',
    label: 'Medical Help',
    message: 'Medical / Urgent Need',
  ),
];
