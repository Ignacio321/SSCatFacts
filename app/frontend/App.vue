<script setup>
import { ref } from 'vue'

const count = ref(0)
</script>

<template>
  <div
    class="min-h-screen flex flex-col items-center justify-center gap-4 bg-gray-100"
  >
    <h1 class="text-3xl font-bold text-gray-800">Rails + Vue + Tailwind 🎉</h1>
    <button
      class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
      @click="count++"
    >
      Clicks: {{ count }}
    </button>
  </div>
</template>
