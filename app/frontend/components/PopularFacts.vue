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
    const data = await apiGet('/api/v1/popular_facts')
    facts.value = data.facts
  } catch {
    error.value = 'No pudimos cargar los más populares 😿'
  } finally {
    loading.value = false
  }
}

onMounted(loadFacts)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4">
    <h2 class="text-2xl font-bold mb-4">Top 10 Más Populares</h2>

    <p v-if="loading" class="text-gray-500">Cargando…</p>
    <p v-else-if="error" class="text-red-600">{{ error }}</p>
    <p v-else-if="facts.length === 0" class="text-gray-500">
      Todavía no hay facts populares
    </p>

    <ol v-else class="space-y-3 list-decimal list-inside">
      <li
        v-for="fact in facts"
        :key="fact.text"
        data-testid="popular-item"
        class="p-4 bg-white rounded-lg shadow flex justify-between items-start gap-3"
      >
        <span>{{ fact.text }}</span>
        <span data-testid="likes-count" class="text-sm text-gray-500 shrink-0">
          {{ fact.likes_count }} ♥
        </span>
      </li>
    </ol>
  </div>
</template>
