import 'package:logger/logger.dart';

class Logs {
  Logs._internal();

  final Logger _logger = Logger();

  static Logs _instance = Logs._internal();

  static Logger get log => _instance._logger;
}