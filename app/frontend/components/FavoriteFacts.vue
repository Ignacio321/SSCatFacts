<script setup>
import { ref, onMounted } from 'vue'
import { apiGet, apiDelete } from '../api/client'

const facts = ref([])
const loading = ref(true)
const error = ref(null)
const currentPage = ref(1)
const lastPage = ref(1)

async function loadFacts(page = 1) {
  loading.value = true
  error.value = null
  try {
    const data = await apiGet(`/api/v1/liked_facts?page=${page}`)
    facts.value = data.facts
    currentPage.value = data.current_page
    lastPage.value = data.last_page
  } catch {
    error.value = 'No pudimos cargar tus favoritos 😿'
  } finally {
    loading.value = false
  }
}

async function unlike(fact) {
  try {
    await apiDelete(`/api/v1/likes/${fact.like_id}`)
    const isLastOnPage = facts.value.length === 1 && currentPage.value > 1
    await loadFacts(isLastOnPage ? currentPage.value - 1 : currentPage.value)
  } catch {
    error.value = 'No pudimos quitar el favorito'
  }
}

onMounted(() => loadFacts())
</script>

<template>
  <div class="max-w-2xl mx-auto px-4">
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-2xl font-bold">Mis Favoritos</h2>
      <div class="flex items-center gap-3 text-sm">
        <button
          data-testid="prev-page"
          class="text-blue-600 underline disabled:text-gray-300 disabled:no-underline"
          :disabled="currentPage <= 1"
          @click="loadFacts(currentPage - 1)"
        >
          Anterior
        </button>
        <button
          data-testid="next-page"
          class="text-blue-600 underline disabled:text-gray-300 disabled:no-underline"
          :disabled="currentPage >= lastPage"
          @click="loadFacts(currentPage + 1)"
        >
          Siguiente
        </button>
      </div>
    </div>

    <p v-if="loading" class="text-gray-500">Cargando favoritos…</p>
    <p v-else-if="error" class="text-red-600">{{ error }}</p>
    <p v-else-if="facts.length === 0" class="text-gray-500">
      Todavía no tienes favoritos
    </p>

    <ul v-else class="space-y-3">
      <li
        v-for="fact in facts"
        :key="fact.like_id"
        data-testid="favorite-item"
        class="p-4 bg-white rounded-lg shadow flex justify-between items-start gap-3"
      >
        <span>{{ fact.text }}</span>
        <button
          data-testid="unlike-button"
          class="text-red-600 shrink-0"
          @click="unlike(fact)"
        >
          ♥
        </button>
      </li>
    </ul>
  </div>
</template>
