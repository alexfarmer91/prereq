/// Minimal RFC 4180 CSV reading/writing — enough for Supabase/psql exports
/// (quoted fields, embedded commas, quotes and newlines). No dependencies.
library;

/// Parse CSV text into rows of fields.
List<List<String>> parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var i = 0;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    // Skip blank lines (a single empty field).
    if (!(row.length == 1 && row.first.isEmpty)) rows.add(row);
    row = <String>[];
  }

  while (i < text.length) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      endField();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      endRow();
    } else {
      field.write(c);
    }
    i++;
  }
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// Parse CSV with a header row into maps keyed by column name.
List<Map<String, String>> parseCsvRecords(String text) {
  final rows = parseCsv(text.startsWith('﻿') ? text.substring(1) : text);
  if (rows.isEmpty) return [];
  final header = rows.first.map((h) => h.trim()).toList();
  return [
    for (final r in rows.skip(1))
      {
        for (var c = 0; c < header.length; c++)
          header[c]: c < r.length ? r[c] : '',
      },
  ];
}

String _escape(Object? value) {
  final s = value?.toString() ?? '';
  if (s.contains(RegExp(r'[",\r\n]'))) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

/// Serialize rows (first row = header) to CSV.
String toCsv(List<List<Object?>> rows) =>
    '${rows.map((r) => r.map(_escape).join(',')).join('\n')}\n';
