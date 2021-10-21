class Convert {
  DateTime toDateTime(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);

      return dateTime;
    } catch (e) {
      return null;
    }
  }
}
