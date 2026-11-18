import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const MarkdownEditorApp());
}

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Desktop Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();

  bool _isSyncingScroll = false;

  // نص افتراضي للبدء
  final String _initialText = '''
# مرحباً بك في محرر Markdown 👋

هذا محرر سطح مكتب مبني بالكامل باستخدام **Flutter** و **Dart**.

## الميزات المتوفرة في هذا الكود:
* معاينة حية وفورية أثناء الكتابة.
* **تمرير متزامن** بين لوحة الكتابة ولوحة العرض.
* شريط أدوات سريع لإدراج التنسيقات.

### مثال لكود برمجي:
```dart
void main() {
  print('Hello Flutter Desktop!');
}
```

> جرب الكتابة في اليسار وشاهد النتيجة هنا فوراً!
''';

  @override
  void initState() {
    super.initState();
    _textController.text = _initialText;

    // ربط التمرير المتزامن
    _editorScrollController.addListener(() => _syncScroll(_editorScrollController, _previewScrollController));
    _previewScrollController.addListener(() => _syncScroll(_previewScrollController, _editorScrollController));
  }

  // دالة مزامنة التمرير بناءً على النسبة المئوية
  void _syncScroll(ScrollController source, ScrollController target) {
    if (_isSyncingScroll || !source.hasClients || !target.hasClients) return;

    final maxSource = source.position.maxScrollExtent;
    final maxTarget = target.position.maxScrollExtent;
    if (maxSource <= 0 || maxTarget <= 0) return;

    _isSyncingScroll = true;
    final percentage = source.offset / maxSource;
    target.jumpTo(percentage * maxTarget);
    _isSyncingScroll = false;
  }

  // دالة لإدراج تنسيق سريع في مكان المؤشر
  void _insertFormatting(String prefix, [String suffix = '']) {
    final text = _textController.text;
    final selection = _textController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final selectedText = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + prefix.length + selectedText.length),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _editorScrollController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محرر Markdown'),
        actions: [
          IconButton(
            tooltip: 'عنوان رئيسي',
            icon: const Icon(Icons.title),
            onPressed: () => _insertFormatting('# '),
          ),
          IconButton(
            tooltip: 'خط عريض (Bold)',
            icon: const Icon(Icons.format_bold),
            onPressed: () => _insertFormatting('**', '**'),
          ),
          IconButton(
            tooltip: 'خط مائل (Italic)',
            icon: const Icon(Icons.format_italic),
            onPressed: () => _insertFormatting('*', '*'),
          ),
          IconButton(
            tooltip: 'كود برمجي',
            icon: const Icon(Icons.code),
            onPressed: () => _insertFormatting('`', '`'),
          ),
          IconButton(
            tooltip: 'قائمة نقطية',
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () => _insertFormatting('- '),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // القسم الأيسر: محرر النصوص
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                scrollController: _editorScrollController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'اكتب نص Markdown هنا...',
                ),
                onChanged: (_) => setState(() {}), // تحديث المعاينة فوراً
              ),
            ),
          ),

          // خط فاصل بين الشاشتين
          const VerticalDivider(width: 2, thickness: 2),

          // القسم الأيمن: المعاينة المباشرة
          Expanded(
            child: Container(
              color: const Color(0xFF121212),
              child: Markdown(
                controller: _previewScrollController,
                data: _textController.text,
                selectable: true,
                padding: const EdgeInsets.all(20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
