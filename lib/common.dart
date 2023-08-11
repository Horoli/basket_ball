library common;

import 'dart:collection';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// import 'dart:io';
import 'dart:ui' as ui;
import 'dart:core';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:tnd_core/tnd_core.dart'; // 각종 유틸 확인
import 'package:tnd_pkg_widget/tnd_pkg_widget.dart'; // 공용 위젯
import 'package:shared_preferences/shared_preferences.dart';

part 'splash.dart';

part 'common_widget.dart';
part 'global.dart';

part 'model/foul.dart';

part 'view/home.dart';
part 'view/foul_management.dart';
part 'view/operation_board.dart';
