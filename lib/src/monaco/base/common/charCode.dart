// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/charCode.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `const enum CharCode` inlines at compile
// time; Dart carries the same named constants as `static const` on a class so
// call sites `CharCode.X` are unchanged. Member names and values are identical.
// ---------------------------------------------------------------------------

/// An inlined enum containing useful character codes (to be used with String.charCodeAt).
class CharCode {
  const CharCode._();

  static const int Null = 0;
  ///
  /// The `\b` character.
  static const int Backspace = 8;
  ///
  /// The `\t` character.
  static const int Tab = 9;
  ///
  /// The `\n` character.
  static const int LineFeed = 10;
  ///
  /// The `\r` character.
  static const int CarriageReturn = 13;
  static const int Space = 32;
  ///
  /// The `!` character.
  static const int ExclamationMark = 33;
  ///
  /// The `"` character.
  static const int DoubleQuote = 34;
  ///
  /// The `#` character.
  static const int Hash = 35;
  ///
  /// The `$` character.
  static const int DollarSign = 36;
  ///
  /// The `%` character.
  static const int PercentSign = 37;
  ///
  /// The `&` character.
  static const int Ampersand = 38;
  ///
  /// The `'` character.
  static const int SingleQuote = 39;
  ///
  /// The `(` character.
  static const int OpenParen = 40;
  ///
  /// The `)` character.
  static const int CloseParen = 41;
  ///
  /// The `*` character.
  static const int Asterisk = 42;
  ///
  /// The `+` character.
  static const int Plus = 43;
  ///
  /// The `,` character.
  static const int Comma = 44;
  ///
  /// The `-` character.
  static const int Dash = 45;
  ///
  /// The `.` character.
  static const int Period = 46;
  ///
  /// The `/` character.
  static const int Slash = 47;
  static const int Digit0 = 48;
  static const int Digit1 = 49;
  static const int Digit2 = 50;
  static const int Digit3 = 51;
  static const int Digit4 = 52;
  static const int Digit5 = 53;
  static const int Digit6 = 54;
  static const int Digit7 = 55;
  static const int Digit8 = 56;
  static const int Digit9 = 57;
  ///
  /// The `:` character.
  static const int Colon = 58;
  ///
  /// The `;` character.
  static const int Semicolon = 59;
  ///
  /// The `<` character.
  static const int LessThan = 60;
  ///
  /// The `=` character.
  static const int Equals = 61;
  ///
  /// The `>` character.
  static const int GreaterThan = 62;
  ///
  /// The `?` character.
  static const int QuestionMark = 63;
  ///
  /// The `@` character.
  static const int AtSign = 64;
  static const int A = 65;
  static const int B = 66;
  static const int C = 67;
  static const int D = 68;
  static const int E = 69;
  static const int F = 70;
  static const int G = 71;
  static const int H = 72;
  static const int I = 73;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int Q = 81;
  static const int R = 82;
  static const int S = 83;
  static const int T = 84;
  static const int U = 85;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;
  ///
  /// The `[` character.
  static const int OpenSquareBracket = 91;
  ///
  /// The `\` character.
  static const int Backslash = 92;
  ///
  /// The `]` character.
  static const int CloseSquareBracket = 93;
  ///
  /// The `^` character.
  static const int Caret = 94;
  ///
  /// The `_` character.
  static const int Underline = 95;
  ///
  /// The ``(`)`` character.
  static const int BackTick = 96;
  static const int a = 97;
  static const int b = 98;
  static const int c = 99;
  static const int d = 100;
  static const int e = 101;
  static const int f = 102;
  static const int g = 103;
  static const int h = 104;
  static const int i = 105;
  static const int j = 106;
  static const int k = 107;
  static const int l = 108;
  static const int m = 109;
  static const int n = 110;
  static const int o = 111;
  static const int p = 112;
  static const int q = 113;
  static const int r = 114;
  static const int s = 115;
  static const int t = 116;
  static const int u = 117;
  static const int v = 118;
  static const int w = 119;
  static const int x = 120;
  static const int y = 121;
  static const int z = 122;
  ///
  /// The `{` character.
  static const int OpenCurlyBrace = 123;
  ///
  /// The `|` character.
  static const int Pipe = 124;
  ///
  /// The `}` character.
  static const int CloseCurlyBrace = 125;
  ///
  /// The `~` character.
  static const int Tilde = 126;
  ///
  /// The &nbsp; (no-break space) character.
  /// Unicode Character 'NO-BREAK SPACE' (U+00A0)
  static const int NoBreakSpace = 160;
  ///
  /// Unicode Character 'LINE SEPARATOR' (U+2028)
  /// http://www.fileformat.info/info/unicode/char/2028/index.htm
  static const int LINE_SEPARATOR = 0x2028;
  ///
  /// Unicode Character 'PARAGRAPH SEPARATOR' (U+2029)
  /// http://www.fileformat.info/info/unicode/char/2029/index.htm
  static const int PARAGRAPH_SEPARATOR = 0x2029;
  ///
  /// Unicode Character 'NEXT LINE' (U+0085)
  /// http://www.fileformat.info/info/unicode/char/0085/index.htm
  static const int NEXT_LINE = 0x0085;
  ///
  /// UTF-8 BOM
  /// Unicode Character 'ZERO WIDTH NO-BREAK SPACE' (U+FEFF)
  /// http://www.fileformat.info/info/unicode/char/feff/index.htm
  static const int UTF8_BOM = 65279;
}
