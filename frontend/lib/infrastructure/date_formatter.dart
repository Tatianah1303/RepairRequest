class DateFormatter {
  static String format(String isoDate) {
    final dateTime = DateTime.tryParse(isoDate);
    if (dateTime == null) return isoDate;
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
        "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
