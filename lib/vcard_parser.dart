library vcard_parser;

class VcardParser {
  static const VCARD_BEGIN_SIGN = 'BEGIN: VCARD';

  static const VCARD_END_SIGN = 'END: VCARD';

  static const VCARD_FIELD_SEPARATORS = [';', '='];
  static const VCARD_TAG_SEPARATOR = ' \ n ';

  static const VCARD_TAG_KE_VALUE_SEPARATOR = ':';

  static const List<String> VCARD_TAG_VALUE_IGONE_SEPARATOR = [',', ' '];
  static const VCARD_TAGS = [
    'ADR',
    'AGENT',
    'BDAY',
    'CATEGORIES',
    'CLASS',
    'EMAIL',
    'FN',
    'GEO',
    'IMPP',
    'KEY',
    'LABEL',
    'LOGO',
    'MAILER',
    'N',
    'NAME',
    'NICKNAME',
    'NOTE',
    'ORG',
    'PHOTO',
    'PRODID',
    'PROFILE',
    'REV',
    'ROLE',
    'SORT-STRING'
        'SOUND',
    'SOURCE',
    'TEL',
    'TITLE',
    'TZ',
    'UID',
    'URL',
    'VERSION',
  ];

  String? content;
  Map<String, Object> tags = new Map<String, Object>();

  VcardParser(String content) {
    this.content = content;
    print(content);
  }

  Map<String, Object> parse() {
    Map<String, Object> tags = new Map<String, Object>();

    // Remove;; and split the text content into lines
    List<String> lines = (content ?? '').replaceAll(";;", "").split(VCARD_TAG_SEPARATOR);
    lines.forEach((field) {
      String? key;
      Object value;

      // Extract the label and value in each row
      List<String> tagAndValue = field.split(VCARD_TAG_KE_VALUE_SEPARATOR);
      if (tagAndValue.length != 2) {
        return;
      }

      key = tagAndValue[0].trim();
      value = tagAndValue[1].trim().replaceAll(VCARD_TAG_VALUE_IGONE_SEPARATOR[0], VCARD_TAG_VALUE_IGONE_SEPARATOR[1]);

      // If the field is complex, the data needs to be further parsed
      if (key.contains(VCARD_FIELD_SEPARATORS[0])) {
        value = parseFields(field.trim());
      }

      // Add or merge data
      if (tags.containsKey(key)) {
        List<Map<String, String>> oldValues = [];
        // If it has not been merged before, use List to save the old and new data
        if (tags[key] is Map) {
          Map<String, String> oldValue = tags[key] as Map<String, String>? ?? {};
          oldValues.add(oldValue);
          oldValues.add(value as Map<String, String>? ?? {});
          value = oldValues;
        } else {
          // It has been merged before, then the new data will be appended to the old data
          oldValues = tags[key] as List<Map<String, String>>? ?? [];
          oldValues.add(value as Map<String, String>? ?? {});
          value = oldValues;
        }
      }
      // Add the parsed field to tags
      tags[key] = value;
    });

    this.tags = tags;
    return tags;
  }

  /*
    Parsing field
   */
  Object parseFields(String line) {
    Object field = new Object();
    List<String> rawFields = line.split(VCARD_FIELD_SEPARATORS[0]);

    // In the original field obtained by segmentation, the 0th element is the key, so it is ignored
    rawFields.getRange(1, rawFields.length).forEach((rawField) {
      List<String> items = [];
      List<String> rawItems = rawField.split(VCARD_FIELD_SEPARATORS[0]);
      if (rawItems.length == 1) {
        rawItems = rawField.split(VCARD_FIELD_SEPARATORS[1]);
      }

      // Extract the key and value of the item
      if (rawItems.length > 0) {
        rawItems.forEach((itemValue) {
          items = itemValue.split(VCARD_TAG_KE_VALUE_SEPARATOR);
        });
      }

      // The key and value of the item are stored in an array, so the number of elements is 2
      if (items.length == 2) {
        field = {
          'name': items.elementAt(0),
          'value': items.elementAt(1).replaceAll(VCARD_TAG_VALUE_IGONE_SEPARATOR[0], VCARD_TAG_VALUE_IGONE_SEPARATOR[1])
        };
      }
    });
    return field;
  }
}
