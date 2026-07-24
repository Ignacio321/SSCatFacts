import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'
import prettier from 'eslint-config-prettier'
import globals from 'globals'

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/recommended'],
  prettier,
  {
    languageOptions: {
      globals: { ...globals.browser },
    },
  },
  {
    ignores: ['public/**', 'node_modules/**', 'vendor/**', 'tmp/**'],
  },
]