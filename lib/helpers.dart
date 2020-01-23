

String getDateTimeFromString(String datetime){
  return datetime.substring(0, 10);
}

String getUsernameFromUrl (String url){
  return url.substring(44, url.length - 1);
}
