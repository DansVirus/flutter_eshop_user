const String currencySymbol = '€';
const String imageDirectory = 'UserPictures/';

const cities = [
  'Athens',
  'Thessaloniki',
  'Volos',
  'Patra',
  'Lamia',
  'Korinthos',
  'Alexandroupoli',
  'Irakleio',
  'Aridaia',
  'Giannitsa',
  'Pella'
];

abstract class OrderStatus {
  static const String pending = 'Pending';
  static const String processing = 'Processing';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';
  static const String returned = 'Returned';
}

abstract class PaymentMethod {
  static const String cod = 'Cash on Delivery';
  static const String online = 'Online Payment';
}