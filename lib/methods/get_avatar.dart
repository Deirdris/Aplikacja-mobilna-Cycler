import 'package:intl/intl.dart';

final _numberFormatter = NumberFormat('0.0');

String getAvatar(String imageURL) => imageURL != "" ? imageURL : "https://firebasestorage.googleapis.com/v0/b/projekt-kolarstwo.appspot.com/o/avatars%2Fdefault.png?alt=media&token=f1498949-47e5-4af3-962d-c0290685c66c";