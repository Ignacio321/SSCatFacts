<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from './stores/auth'
import LoginForm from './components/LoginForm.vue'
import RegisterForm from './components/RegisterForm.vue'
import FactsList from './components/FactsList.vue'
import FavoriteFacts from './components/FavoriteFacts.vue'
import PopularFacts from './components/PopularFacts.vue'

const auth = useAuthStore()
const showRegister = ref(false)
const view = ref('facts')

const tabs = [
  { key: 'facts', label: 'Cat Facts' },
  { key: 'favorites', label: 'Mis favoritos' },
  { key: 'popular', label: 'Más populares' },
]

onMounted(() => auth.fetchCurrentUser())
</script>

<template>
  <div class="min-h-screen bg-gray-100 py-10">
    <p v-if="auth.loading" class="text-center text-gray-500">Cargando…</p>

    <template v-else-if="!auth.isLoggedIn">
      <component :is="showRegister ? RegisterForm : LoginForm" />
      <p class="text-center mt-4 text-sm">
        <button
          data-testid="toggle-register"
          class="text-blue-600 underline"
          @click="showRegister = !showRegister"
        >
          {{ showRegister ? 'Ya tengo cuenta' : 'Crear una cuenta' }}
        </button>
      </p>
    </template>

    <template v-else>
      <div
        class="max-w-2xl mx-auto flex justify-between items-center mb-6 px-4"
      >
        <span
          >Hola, <strong>{{ auth.user.username }}</strong> 🐱</span
        >
        <div class="flex items-center gap-4">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :data-testid="`tab-${tab.key}`"
            class="text-sm underline"
            :class="
              view === tab.key ? 'text-blue-800 font-semibold' : 'text-blue-600'
            "
            @click="view = tab.key"
          >
            {{ tab.label }}
          </button>
          <button
            class="text-sm text-blue-600 underline"
            @click="auth.logout()"
          >
            Salir
          </button>
        </div>
      </div>
      <FavoriteFacts v-if="view === 'favorites'" />
      <PopularFacts v-else-if="view === 'popular'" />
      <FactsList v-else />
    </template>
  </div>
</template>
