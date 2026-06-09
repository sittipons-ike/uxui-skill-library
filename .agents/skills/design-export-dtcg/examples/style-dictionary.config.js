/**
 * Style Dictionary v4 config — DTCG token pipeline
 *
 * Usage:
 *   npm i -D style-dictionary@^4
 *   npx style-dictionary build
 *
 * Input:
 *   tokens.json  (DTCG-format design tokens at repo root)
 *
 * Output tree:
 *   build/
 *   ├── web/
 *   │   ├── tokens.css        (CSS custom properties)
 *   │   ├── _tokens.scss      (SCSS variables)
 *   │   └── tokens.ts         (TypeScript const map)
 *   ├── ios/Tokens.swift      (Swift static struct)
 *   ├── android/Tokens.kt     (Kotlin object for Compose)
 *   ├── flutter/tokens.dart   (Dart constants)
 *   └── tailwind/tailwind.tokens.js  (Tailwind theme extend)
 */

module.exports = {
  source: ['tokens.json'],
  platforms: {
    'web/css': {
      transformGroup: 'css',
      buildPath: 'build/web/',
      files: [
        {
          destination: 'tokens.css',
          format: 'css/variables',
          options: { outputReferences: true },
        },
      ],
    },
    'web/scss': {
      transformGroup: 'scss',
      buildPath: 'build/web/',
      files: [
        {
          destination: '_tokens.scss',
          format: 'scss/variables',
          options: { outputReferences: true },
        },
      ],
    },
    'web/ts': {
      transformGroup: 'js',
      buildPath: 'build/web/',
      files: [
        {
          destination: 'tokens.ts',
          format: 'javascript/esm',
        },
      ],
    },
    'ios/swift': {
      transformGroup: 'ios-swift',
      buildPath: 'build/ios/',
      files: [
        {
          destination: 'Tokens.swift',
          format: 'ios-swift/class.swift',
          options: { className: 'Tokens' },
        },
      ],
    },
    'android/compose': {
      transformGroup: 'compose',
      buildPath: 'build/android/',
      files: [
        {
          destination: 'Tokens.kt',
          format: 'compose/object',
          options: { className: 'Tokens', packageName: 'design.tokens' },
        },
      ],
    },
    'flutter/dart': {
      transformGroup: 'flutter',
      buildPath: 'build/flutter/',
      files: [
        {
          destination: 'tokens.dart',
          format: 'flutter/class.dart',
          options: { className: 'Tokens' },
        },
      ],
    },
    tailwind: {
      transformGroup: 'js',
      buildPath: 'build/tailwind/',
      files: [
        {
          destination: 'tailwind.tokens.js',
          format: 'javascript/module-flat',
        },
      ],
    },
  },
};
