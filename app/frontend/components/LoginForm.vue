<script setup>
import { ref } from 'vue'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const username = ref('')
const password = ref('')
const error = ref(null)

async function submit() {
  error.value = null
  try {
    await auth.login(username.value, password.value)
  } catch (err) {
    if (err.status === 429) {
      error.value =
        err.error ||
        'Demasiados intentos. Espera un momento e intenta de nuevo.'
    } else if (err.status === 401) {
      error.value = 'Usuario o contraseña incorrectos'
    } else {
      error.value = 'No pudimos conectar con el servidor'
    }
  }
}
</script>

<template>
  <div class="max-w-sm mx-auto p-6 bg-white rounded-lg shadow">
    <h2 class="text-xl font-bold mb-4">Ingresar</h2>

    <p v-if="error" class="mb-3 text-sm text-red-600">{{ error }}</p>

    <input
      v-model="username"
      placeholder="Username"
      class="w-full mb-3 px-3 py-2 border rounded"
    />
    <input
      v-model="password"
      type="password"
      placeholder="Contraseña"
      class="w-full mb-4 px-3 py-2 border rounded"
      @keyup.enter="submit"
    />
    <button
      class="w-full py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
      @click="submit"
    >
      Ingresar
    </button>
  </div>
</template>
