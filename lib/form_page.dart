import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// Design tokens — vivid, modern palette
// ─────────────────────────────────────────────────────────────
class T {
  // Surfaces
  static const bg = Color(0xFFF6F5FF);          // soft lavender white
  static const card = Colors.white;
  static const fill = Color(0xFFF1F0FA);        // lavender-tinted input fill

  // Text
  static const ink = Color(0xFF1A1A2E);         // deep navy
  static const muted = Color(0xFF7A7A99);       // muted violet-grey

  // Accents
  static const primary = Color(0xFF6C5CE7);     // vibrant indigo
  static const primaryDark = Color(0xFF5A4BD1);
  static const gradientA = Color(0xFF6C5CE7);   // indigo
  static const gradientB = Color(0xFFA29BFE);   // soft violet
  static const accent = Color(0xFFFF6B9D);      // warm pink pop
  static const line = Color(0xFFE8E6F5);

  static const radius = 16.0;
  static const gap = 18.0;

  static const gradient = LinearGradient(
    colors: [gradientA, gradientB],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class FormDraft {
  final Map<String, TextEditingController> _text = {};
  final Map<String, String> _choice = {};

  TextEditingController ctrl(String k) =>
      _text.putIfAbsent(k, () => TextEditingController());

  String value(String k) => _choice[k] ?? _text[k]?.text.trim() ?? '';
  bool isFilled(String k) => value(k).isNotEmpty;

  void setChoice(String k, String? v) {
    if (v != null) _choice[k] = v;
  }

  Map<String, String> toMap() => {
        for (final e in _text.entries) e.key: e.value.text.trim(),
        ..._choice,
      };

  void clear() {
    for (final c in _text.values) {
      c.clear();
    }
    _choice.clear();
  }

  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
  }
}

InputDecoration _dec({String? hint, Widget? suffix}) => InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: T.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: const TextStyle(color: T.muted, fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(T.radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(T.radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(T.radius),
        borderSide: const BorderSide(color: T.primary, width: 1.6),
      ),
    );

Widget fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: T.primary,
        ),
      ),
    );

Widget appField(FormDraft draft, String label, {String? hint}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel(label),
        TextField(
          controller: draft.ctrl(label),
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            color: T.ink,
          ),
          decoration: _dec(hint: hint),
        ),
      ],
    );

Widget dateField(BuildContext ctx, FormDraft draft, String label) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel(label),
        TextField(
          controller: draft.ctrl(label),
          readOnly: true,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            color: T.ink,
          ),
          decoration: _dec(
            hint: 'Select date',
            suffix: const Icon(Icons.calendar_today_outlined,
                size: 18, color: T.primary),
          ),
          onTap: () async {
            final now = DateTime.now();
            final p = await showDatePicker(
              context: ctx,
              initialDate: now,
              firstDate: DateTime(1930),
              lastDate: now,
            );
            if (p != null) {
              draft.ctrl(label).text =
                  '${p.year}-${p.month.toString().padLeft(2, '0')}-${p.day.toString().padLeft(2, '0')}';
            }
          },
        ),
      ],
    );

void toast(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        backgroundColor: T.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}

bool check(BuildContext c, FormDraft d, List<String> keys) {
  for (final k in keys) {
    if (!d.isFilled(k)) {
      toast(c, 'Please fill in: $k');
      return false;
    }
  }
  return true;
}

class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.current, required this.labels});

  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          _dot(i + 1),
          if (i < labels.length - 1)
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: i + 1 < current ? T.primary : T.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _dot(int n) {
    final done = n < current;
    final active = n == current;
    final filled = done || active;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: filled ? T.gradient : null,
        color: filled ? null : T.card,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? Colors.transparent : T.line,
          width: 1.5,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: T.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Text(
              '$n',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : T.muted,
              ),
            ),
    );
  }
}

class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.step,
    required this.stepLabels,
    required this.heading,
    required this.subtitle,
    required this.body,
    required this.actions,
  });

  final int step;
  final List<String> stepLabels;
  final String heading;
  final String subtitle;
  final List<Widget> body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      appBar: AppBar(
        backgroundColor: T.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: T.gradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'R',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Registration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: T.ink,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: StepBar(current: step, labels: stepLabels),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => T.gradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text(
                          heading,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: T.muted,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...body,
                    ],
                  ),
                ),
                _footer(actions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer(List<Widget> actions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        color: T.bg,
        border: Border(top: BorderSide(color: T.line)),
      ),
      child: Row(children: actions),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final draft = FormDraft();

  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PersonalDetailsPage(draft: draft);
}

const _steps = ['Details', 'Subjects', 'Review'];

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key, required this.draft});
  final FormDraft draft;

  static const _required = ['Name', 'Section', 'Course'];

  @override
  Widget build(BuildContext context) {
    return PageShell(
      step: 1,
      stepLabels: _steps,
      heading: 'Tell us\nabout you.',
      subtitle: 'A few details to get started.',
      body: [
        appField(draft, 'Name', hint: 'Full name'),
        const SizedBox(height: T.gap),
        appField(draft, 'Section', hint: 'e.g. BSIT-1A'),
        const SizedBox(height: T.gap),
        appField(draft, 'Course', hint: 'e.g. BS Information Technology'),
      ],
      actions: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (!check(context, draft, _required)) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FamilyEducationPage(draft: draft),
                ),
              );
            },
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class FamilyEducationPage extends StatelessWidget {
  const FamilyEducationPage({super.key, required this.draft});
  final FormDraft draft;

  static const _required = ['Subject 1', 'Time 1', 'Subject 2', 'Time 2'];

  @override
  Widget build(BuildContext context) {
    return PageShell(
      step: 2,
      stepLabels: _steps,
      heading: 'Your subjects.',
      subtitle: 'Add the subjects you\'re enrolled in and their schedule.',
      body: [
        appField(draft, 'Subject 1', hint: 'e.g. IT 101'),
        const SizedBox(height: T.gap),
        appField(draft, 'Time 1', hint: 'e.g. 8:00 – 9:30 AM'),
        const SizedBox(height: T.gap),
        appField(draft, 'Subject 2', hint: 'e.g. IT 102'),
        const SizedBox(height: T.gap),
        appField(draft, 'Time 2', hint: 'e.g. 10:00 – 11:30 AM'),
      ],
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (!check(context, draft, _required)) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkReferencesPage(draft: draft),
                ),
              );
            },
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class WorkReferencesPage extends StatefulWidget {
  const WorkReferencesPage({super.key, required this.draft});
  final FormDraft draft;

  @override
  State<WorkReferencesPage> createState() => _WorkReferencesPageState();
}

class _WorkReferencesPageState extends State<WorkReferencesPage> {
  bool saving = false;

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await FirebaseFirestore.instance.collection('students').add({
        ...widget.draft.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      toast(context, 'Saved successfully');
      widget.draft.clear();
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (_) {
      if (!mounted) return;
      toast(context, 'Failed to save. Please try again.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    final rows = <(String, String)>[
      ('Name', d.value('Name')),
      ('Section', d.value('Section')),
      ('Course', d.value('Course')),
      ('Subject 1', d.value('Subject 1')),
      ('Time 1', d.value('Time 1')),
      ('Subject 2', d.value('Subject 2')),
      ('Time 2', d.value('Time 2')),
    ];

    return PageShell(
      step: 3,
      stepLabels: _steps,
      heading: 'Everything\nlook right?',
      subtitle: 'Review your information before saving.',
      body: [
        Container(
          decoration: BoxDecoration(
            color: T.card,
            borderRadius: BorderRadius.circular(T.radius),
            border: Border.all(color: T.line),
            boxShadow: [
              BoxShadow(
                color: T.primary.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _row(rows[i].$1, rows[i].$2),
                if (i < rows.length - 1)
                  const Divider(
                    height: 1,
                    color: T.line,
                    indent: 18,
                    endIndent: 18,
                  ),
              ],
            ],
          ),
        ),
      ],
      actions: [
        OutlinedButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save'),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: T.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value.isEmpty ? '—' : value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: T.ink,
                ),
              ),
            ),
          ],
        ),
      );
}