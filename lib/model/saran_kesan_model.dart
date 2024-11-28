import 'package:hive/hive.dart';

part 'saran_kesan_model.g.dart'; // Jangan lupa buat file .g.dart

@HiveType(typeId: 0)
class SaranKesan {
  @HiveField(0)
  final String saran;

  @HiveField(1)
  final String kesanPesan;

  SaranKesan({required this.saran, required this.kesanPesan});
}
