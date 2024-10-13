// import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';

class EditorMessage {
  final List<EditorMessageData> data;

  EditorMessage(this.data);

  toRichText() {
    // Convert the message data to a RichText widget
    List<TextSpan> children = [];
    for (var messageData in data) {
      children.add(
          TextSpan(
            text: messageData.text,
            style: TextStyle(
              color: messageData.data['color'] ?? Colors.black,
              fontSize: messageData.data['fontSize'] ?? 14.0,
              fontWeight: messageData.data['bold'] ? FontWeight.bold : FontWeight.normal,
              fontStyle: messageData.data['italic'] ? FontStyle.italic : FontStyle.normal,
              decoration: messageData.data['underline'] ? TextDecoration.underline : TextDecoration.none,
              foreground: Paint()..shader = messageData.data['gradient'],
              background: Paint()..shader = messageData.data['backgroundGradient'],
              backgroundColor: messageData.data['backgroundColor'] ?? Colors.transparent,
            ),
          )
      );
    }
    return RichText(text: TextSpan(children: children),);
  }
}

// EditorMessage iterator
class EditorMessageIterator {
  final EditorMessage message;
  int index = 0, offset = 0;

  EditorMessageIterator(this.message);

  EditorMessageData get current => message.data[index];

  EditorMessageData next(int count) {
    if (offset + count < current.text.length) {
      final result = EditorMessageData(current.text.substring(offset, offset + count), current.data);
      offset += count;
      return result;
    } else {
      final result = EditorMessageData(current.text.substring(offset), current.data);
      index++;
      offset = 0;
      return result;
    }
  }

  hasNext() {
    return index < message.data.length - 1 || offset < current.text.length - 1;
  }
}

class EditorMessageData {
  final String text;
  final Map<String, dynamic> data;

  EditorMessageData(this.text, this.data);
}

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

// EditorMessage is shadow for the value of the EditorContentController
class EditorContentController extends TextEditingController {
  EditorMessage message;

  EditorContentController(this.message);

  @override
  set value(TextEditingValue newValue) {
    // // We need to make diff between the old value and the new value
    // // and then update the message
    //
    // final oldText = super.value.text;
    // final newText = newValue.text;
    // final cursorAt = newValue.selection.baseOffset;
    // final iter = EditorMessageIterator(message);
    // final textDiff = diff(oldText, newText);
    //
    // while(iter.hasNext()) {
    //   for(var diff in textDiff) {
    //     if (diff.operation == DIFF_EQUAL) {
    //       iter.next(diff.text.length);
    //     } else if (diff.operation == DIFF_INSERT) {
    //       final data = iter.current.data;
    //       final text = iter.next(diff.text.length).text;
    //       message.data.insert(iter.index, EditorMessageData(text, data));
    //     } else if (diff.operation == DIFF_DELETE) {
    //       message.data.removeAt(iter.index);
    //     }
    //   }
    // }


    super.value = newValue;
  }

  //
  // @override
  // TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
  //   return message.toRichText().text!;
  // }
}

class _EditorState extends State<Editor> {
  final EditorContentController _controller = EditorContentController(EditorMessage([]));

  @override
  Widget build(BuildContext context) {
    // An editor that will build custom format representing the message
    // and then convert it to a RichText widget


    return EditableText(
      controller: _controller,
      backgroundCursorColor: Colors.blue,
      cursorColor: Colors.red,
      selectionColor: Colors.green,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
        decoration: TextDecoration.none,
      ),
      cursorWidth: 2.0,
      focusNode: FocusNode(),
      maxLines: null,

    );
  }
}