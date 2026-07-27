<script setup>
import { ref, onMounted } from 'vue'
import { apiGet, apiPost } from '../api/client'

const PAGE_SIZE = 10

const facts = ref([])
const loading = ref(true)
const error = ref(null)
const canGoPrev = ref(false)
const canGoNext = ref(false)

let liked = new Set()
let cursor = 1
let lastPage = null
let carry = []
let history = []

async function likedTexts() {
  try {
    const data = await apiGet('/api/v1/liked_facts')
    return new Set(data.facts.map((fact) => fact.text))
  } catch {
    return new Set()
  }
}

function hasMoreSource() {
  return carry.length > 0 || lastPage === null || cursor <= lastPage
}

async function fillScreen(count = PAGE_SIZE) {
  let buffer = carry
  carry = []

  while (buffer.length < count && (lastPage === null || cursor <= lastPage)) {
    const data = await apiGet(`/api/v1/cat_facts?page=${cursor}`)
    lastPage = data.last_page
    cursor += 1
    buffer = buffer.concat(data.facts.filter((fact) => !liked.has(fact.text)))
  }

  carry = buffer.slice(count)
  return buffer.slice(0, count)
}

async function loadFirstScreen() {
  loading.value = true
  error.value = null
  try {
    liked = await likedTexts()
    cursor = 1
    lastPage = null
    carry = []
    history = []
    facts.value = await fillScreen()
    canGoPrev.value = false
    canGoNext.value = hasMoreSource()
  } catch {
    error.value = 'No pudimos cargar los cat facts 😿'
  } finally {
    loading.value = false
  }
}

async function nextScreen() {
  loading.value = true
  error.value = null
  try {
    history.push({ facts: facts.value, cursor, lastPage, carry })
    facts.value = await fillScreen()
    canGoPrev.value = true
    canGoNext.value = hasMoreSource()
  } catch {
    error.value = 'No pudimos cargar los cat facts 😿'
  } finally {
    loading.value = false
  }
}

function prevScreen() {
  const previous = history.pop()
  if (!previous) return

  facts.value = previous.facts
  cursor = previous.cursor
  lastPage = previous.lastPage
  carry = previous.carry
  canGoPrev.value = history.length > 0
  canGoNext.value = true
}

async function like(fact) {
  try {
    await apiPost('/api/v1/likes', {
      fact: { text: fact.text, length: fact.length },
    })
    liked.add(fact.text)
    const remaining = facts.value.filter((f) => f.text !== fact.text)
    const needed = PAGE_SIZE - remaining.length

    facts.value =
      needed > 0 && hasMoreSource()
        ? remaining.concat(await fillScreen(needed))
        : remaining
    canGoNext.value = hasMoreSource()
  } catch {
    error.value = 'No pudimos guardar el like'
  }
}

onMounted(loadFirstScreen)
</script>

<template>
  <div class="max-w-2xl mx-auto px-4">
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-2xl font-bold">Cat Facts</h2>
      <div class="flex items-center gap-3 text-sm">
        <button
          data-testid="prev-page"
          class="text-blue-600 underline disabled:text-gray-300 disabled:no-underline"
          :disabled="!canGoPrev"
          @click="prevScreen"
        >
          Anterior
        </button>
        <button
          data-testid="next-page"
          class="text-blue-600 underline disabled:text-gray-300 disabled:no-underline"
          :disabled="!canGoNext"
          @click="nextScreen"
        >
          Siguiente
        </button>
      </div>
    </div>

    <p v-if="loading" class="text-gray-500">Cargando facts…</p>
    <p v-else-if="error" class="text-red-600">{{ error }}</p>
    <p v-else-if="facts.length === 0" class="text-gray-500">
      Le diste like a todos los cat facts disponibles 🐾
    </p>

    <ul v-else class="space-y-3">
      <li
        v-for="fact in facts"
        :key="fact.text"
        data-testid="fact-item"
        class="p-4 bg-white rounded-lg shadow flex justify-between items-start gap-3"
      >
        <span>{{ fact.text }}</span>
        <button
          data-testid="like-button"
          class="text-gray-400 shrink-0"
          @click="like(fact)"
        >
          ♥
        </button>
      </li>
    </ul>
  </div>
</template>
