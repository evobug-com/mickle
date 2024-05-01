import 'package:flat_buffers/flex_buffers.dart' as flex_buffers;
import 'utils.dart';

part 'request.g.dart';

/*
* The builder key order must be the same as the packet.rs#PacketRequest enum
* Keys are serialized as camelCase in the buffer
* */