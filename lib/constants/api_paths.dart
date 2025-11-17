const isDev = false;
const isUat = false;
const String baseUrl = isDev
    ? ""
    : isUat
    ? ""
    : "";
const String login = "${baseUrl}Users/";
const String signup = "${baseUrl}Users/";
const String event = "${baseUrl}Users/";
