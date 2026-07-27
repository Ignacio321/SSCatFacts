<script setup>
import { ref, onMounted } from 'vue'
import { apiGet } from '../api/client'

const facts = ref([])
const loading = ref(true)
const error = ref(null)

async function loadFacts() {
  loading.value = true
  error.value = null
  try {
    const data = await apiGet('/api/v1/cat_facts')
    facts.value = data.facts
  } catch {
    error.value = 'No pudimos cargar los cat facts 😿'
  } finally {
    loading.value = false
  }
}

onMounted(loadFacts)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4">
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-2xl font-bold">Cat Facts</h2>
      <button
        data-testid="reload-facts"
        class="text-sm text-blue-600 underline"
        @click="loadFacts"
      >
        Cargar otros
      </button>
    </div>

    <p v-if="loading" class="text-gray-500">Cargando facts…</p>
    <p v-else-if="error" class="text-red-600">{{ error }}</p>

    <ul v-else class="space-y-3">
      <li
        v-for="fact in facts"
        :key="fact.text"
        data-testid="fact-item"
        class="p-4 bg-white rounded-lg shadow flex justify-between items-start gap-3"
      >
        <span>{{ fact.text }}</span>
        <!-- el botón de like llega en feature/likes -->
      </li>
    </ul>
  </div>
</template>
