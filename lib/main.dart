import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EduNoteApp());
}

const _ink = Color(0xFF243A32);
const _mutedInk = Color(0xFF78837D);
const _paper = Color(0xFFFAFAF7);
const _green = Color(0xFF3E6B57);
const _line = Color(0xFFE9EDE8);
const _logoAsset =
    'logo/notes-icon-in-trendy-flat-style-isolated-on-white-background-notes-silhouette-symbol-for-your-website-design-logo-app-ui-illustration-eps10-free-vector.jpg';
const _legacyDefaultSubjects = {
  'Biology',
  'History',
  'Math',
  'Literature',
  'Other',
};
const _subjectColors = [
  Color(0xFFE9F0E6),
  Color(0xFFF4EBDD),
  Color(0xFFE9EAF4),
  Color(0xFFF3E8E7),
  Color(0xFFE8F0F0),
];

class EduNoteApp extends StatelessWidget {
  const EduNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _paper,
        colorScheme: ColorScheme.fromSeed(seedColor: _green, surface: _paper),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: _ink,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -1,
          ),
          titleLarge: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          bodyMedium: TextStyle(color: _mutedInk, height: 1.45),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
      home: const _AssemblySplash(),
    );
  }
}

class _AssemblySplash extends StatefulWidget {
  const _AssemblySplash();

  @override
  State<_AssemblySplash> createState() => _AssemblySplashState();
}

class _AssemblySplashState extends State<_AssemblySplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );
    _assembleLogo();
  }

  Future<void> _assembleLogo() async {
    await _controller.forward();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const NotesHomePage(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _logoSlice({
    required int index,
    required double top,
    required double size,
    required Offset startingOffset,
  }) {
    final start = index * 0.13;
    final progress = Interval(
      start,
      0.64 + start,
      curve: Curves.easeOutBack,
    ).transform(_controller.value);

    return Positioned(
      top: top + startingOffset.dy * (1 - progress),
      left: startingOffset.dx * (1 - progress),
      width: size,
      height: size / 3,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: -top,
              left: 0,
              width: size,
              height: size,
              child: Opacity(
                key: Key('splash-fragment-$index'),
                opacity: progress.clamp(0, 1),
                child: Image.asset(
                  _logoAsset,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const logoSize = 216.0;
    const sliceHeight = logoSize / 3;
    return Scaffold(
      key: const Key('splash-screen'),
      backgroundColor: _paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => SizedBox(
                width: logoSize,
                height: logoSize,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: Image.asset(_logoAsset, fit: BoxFit.cover),
                      ),
                    ),
                    _logoSlice(
                      index: 0,
                      top: 0,
                      size: logoSize,
                      startingOffset: const Offset(-150, -24),
                    ),
                    _logoSlice(
                      index: 1,
                      top: sliceHeight,
                      size: logoSize,
                      startingOffset: const Offset(150, 0),
                    ),
                    _logoSlice(
                      index: 2,
                      top: sliceHeight * 2,
                      size: logoSize,
                      startingOffset: const Offset(-120, 24),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.58, 0.9, curve: Curves.easeIn),
              ),
              child: const Text(
                'EDUNOTE',
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.subject,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final String subject;
  final DateTime updatedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'subject': subject,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    subject: json['subject'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  static const _storageKey = 'edunote_data';

  List<Note> _notes = [];
  List<String> _subjects = [];
  String _selectedSubject = 'All notes';
  String _searchQuery = '';
  bool _searchOpen = false;
  bool _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      final storedData = preferences.getString(_storageKey);
      if (storedData != null) {
        final data = jsonDecode(storedData) as Map<String, dynamic>;
        final savedSubjects = (data['subjects'] as List<dynamic>)
            .cast<String>()
            .where((subject) => !_legacyDefaultSubjects.contains(subject))
            .toList();
        final savedNotes = (data['notes'] as List<dynamic>)
            .map((item) => Note.fromJson(item as Map<String, dynamic>))
            .toList();
        if (!mounted) return;
        setState(() {
          _subjects = savedSubjects;
          _notes = savedNotes;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _persist({
    required List<Note> notes,
    required List<String> subjects,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode({
        'subjects': subjects,
        'notes': notes.map((note) => note.toJson()).toList(),
      }),
    );
    if (!saved) throw StateError('Your changes could not be saved.');
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _subjects = subjects;
    });
  }

  Future<void> _openEditor([Note? note]) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(
          note: note,
          subjects: List.of(_subjects),
          onCreateSubject: _createSubject,
          onDelete: note == null ? null : () => _deleteNote(note),
        ),
      ),
    );
    if (result == null) return;
    final notes = List<Note>.of(_notes);
    final index = notes.indexWhere((item) => item.id == result.id);
    if (index == -1) {
      notes.insert(0, result);
    } else {
      notes[index] = result;
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    try {
      await _persist(notes: notes, subjects: _subjects);
    } catch (error) {
      _showError('Could not save your note: $error');
    }
  }

  Future<String?> _createSubject(String value) async {
    final subject = value.trim();
    if (subject.isEmpty) return null;
    final existing = _subjects.where(
      (item) => item.toLowerCase() == subject.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first;

    final subjects = [..._subjects, subject];
    try {
      await _persist(notes: _notes, subjects: subjects);
      return subject;
    } catch (error) {
      _showError('Could not save the subject: $error');
      return null;
    }
  }

  Future<void> _deleteNote(Note note) async {
    final notes = _notes.where((item) => item.id != note.id).toList();
    try {
      await _persist(notes: notes, subjects: _subjects);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      _showError('Could not delete the note: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<Note> get _visibleNotes {
    final query = _searchQuery.trim().toLowerCase();
    return _notes.where((note) {
      final matchesSubject =
          _selectedSubject == 'All notes' || note.subject == _selectedSubject;
      final matchesSearch =
          query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query);
      return matchesSubject && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new-note-button'),
        onPressed: _loading || _loadError != null ? null : () => _openEditor(),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New note',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _green))
                : _loadError != null
                ? _LoadErrorView(onRetry: _loadNotes)
                : _buildNotesPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesPage() {
    final notes = _visibleNotes;
    return CustomScrollView(
      key: const Key('notes-home'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      _logoAsset,
                      key: const Key('app-logo'),
                      semanticLabel: 'EduNote logo',
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    'EDUNOTE',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _searchOpen ? 'Close search' : 'Search notes',
                    onPressed: () {
                      setState(() {
                        _searchOpen = !_searchOpen;
                        if (!_searchOpen) _searchQuery = '';
                      });
                    },
                    icon: Icon(
                      _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                      color: _ink,
                    ),
                  ),
                ],
              ),
              if (_searchOpen) ...[
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'Search your notes',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ],
              const SizedBox(height: 34),
              Text(
                'A little space for\nbig ideas.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 9),
              Text(
                _notes.isEmpty
                    ? 'Keep your class notes together, simply.'
                    : '${_notes.length} ${_notes.length == 1 ? 'note' : 'notes'} saved in your space.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _SubjectChip(
                      label: 'All notes',
                      selected: _selectedSubject == 'All notes',
                      onTap: () =>
                          setState(() => _selectedSubject = 'All notes'),
                    ),
                    ..._subjects.map(
                      (subject) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _SubjectChip(
                          label: subject,
                          selected: _selectedSubject == subject,
                          onTap: () =>
                              setState(() => _selectedSubject = subject),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Your notes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1EC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${notes.length}',
                      style: const TextStyle(
                        color: _mutedInk,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ]),
          ),
        ),
        if (notes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyNotesView(
              hasNotes: _notes.isNotEmpty,
              onCreate: () => _openEditor(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.crossAxisExtent > 650 ? 2 : 1;
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _NoteCard(
                      note: notes[index],
                      onTap: () => _openEditor(notes[index]),
                    ),
                    childCount: notes.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 178,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : _mutedInk,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      selectedColor: _green,
      side: BorderSide(color: selected ? _green : _line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _subjectColors[note.subject.hashCode.abs() %
                              _subjectColors.length],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      note.subject,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: _mutedInk,
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (note.body.isNotEmpty) ...[
                const SizedBox(height: 5),
                Expanded(
                  child: Text(
                    note.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _mutedInk,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ] else
                const Spacer(),
              Text(
                _formatDate(note.updatedAt),
                style: const TextStyle(color: _mutedInk, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotesView extends StatelessWidget {
  const _EmptyNotesView({required this.hasNotes, required this.onCreate});

  final bool hasNotes;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0E9),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Icon(
                Icons.sticky_note_2_outlined,
                color: _green,
                size: 30,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              hasNotes ? 'No notes in this subject' : 'Start with a blank page',
              style: const TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasNotes
                  ? 'Try another subject to find what you need.'
                  : 'Add a thought, a lesson, or a reminder.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mutedInk, fontSize: 13),
            ),
            if (!hasNotes) ...[
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Create your first note'),
                style: TextButton.styleFrom(foregroundColor: _green),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: _green, size: 36),
            const SizedBox(height: 14),
            const Text(
              'Your notes could not be loaded.',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({
    super.key,
    required this.note,
    required this.subjects,
    required this.onCreateSubject,
    required this.onDelete,
  });

  final Note? note;
  final List<String> subjects;
  final Future<String?> Function(String) onCreateSubject;
  final Future<void> Function()? onDelete;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late List<String> _subjects;
  late String _selectedSubject;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
    _subjects = List.of(widget.subjects);
    _selectedSubject = _subjects.contains(widget.note?.subject)
        ? widget.note!.subject
        : _subjects.isEmpty
        ? ''
        : _subjects.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateSubjectDialog(),
    );
    if (value == null || !mounted) return;

    final subject = await widget.onCreateSubject(value);
    if (subject == null || !mounted) return;
    setState(() {
      if (!_subjects.contains(subject)) _subjects.add(subject);
      _selectedSubject = subject;
    });
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedSubject.isEmpty) return;
    final now = DateTime.now();
    Navigator.of(context).pop(
      Note(
        id: widget.note?.id ?? now.microsecondsSinceEpoch.toString(),
        title: title,
        body: _bodyController.text.trim(),
        subject: _selectedSubject,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.note == null ? 'New note' : 'Edit note',
          style: const TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              tooltip: 'Delete note',
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_subjects.isEmpty)
                  OutlinedButton.icon(
                    key: const Key('create-subject-button'),
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Name your first subject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _green,
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(color: _line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: const Key('subject-selector'),
                          initialValue: _selectedSubject,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            prefixIcon: Icon(Icons.sell_outlined),
                          ),
                          items: _subjects
                              .map(
                                (subject) => DropdownMenuItem(
                                  value: subject,
                                  child: Text(subject),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSubject = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        key: const Key('create-subject-button'),
                        tooltip: 'Create subject',
                        onPressed: _addSubject,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _green,
                          side: const BorderSide(color: _line),
                          fixedSize: const Size(54, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
                TextField(
                  key: const Key('note-title-field'),
                  controller: _titleController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 100,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Give your note a title',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: TextField(
                    key: const Key('note-body-field'),
                    controller: _bodyController,
                    expands: true,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Write something worth remembering...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  key: const Key('save-note-button'),
                  onPressed:
                      _titleController.text.trim().isEmpty ||
                          _selectedSubject.isEmpty
                      ? null
                      : _saveNote,
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save note',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this note?'),
        content: const Text('This note will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep note'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onDelete?.call();
  }
}

class _CreateSubjectDialog extends StatefulWidget {
  const _CreateSubjectDialog();

  @override
  State<_CreateSubjectDialog> createState() => _CreateSubjectDialogState();
}

class _CreateSubjectDialogState extends State<_CreateSubjectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a subject'),
      content: TextField(
        key: const Key('create-subject-field'),
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'e.g. Chemistry'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Add subject'),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}
