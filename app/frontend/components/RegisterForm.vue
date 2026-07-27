<script setup>
import { ref } from 'vue'
import { apiPost } from '../api/client'

const username = ref('')
const password = ref('')
const errors = ref([])
const success = ref(false)

async function submit() {
  errors.value = []
  try {
    await apiPost('/api/v1/users', {
      user: { username: username.value, password: password.value },
    })
    success.value = true
  } catch (e) {
    errors.value = e.errors ?? ['Algo salió mal, intenta de nuevo']
  }
}
</script>

<template>
  <div class="max-w-sm mx-auto p-6 bg-white rounded-lg shadow">
    <h2 class="text-xl font-bold mb-4">Crear cuenta</h2>

    <p v-if="success" class="text-green-600">¡Cuenta creada! 🐱</p>

    <template v-else>
      <ul v-if="errors.length" class="mb-3 text-sm text-red-600">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>

      <input
        v-model="username"
        placeholder="Username"
        class="w-full mb-3 px-3 py-2 border rounded"
      />
      <input
        v-model="password"
        type="password"
        placeholder="Contraseña (mín. 8 caracteres)"
        class="w-full mb-4 px-3 py-2 border rounded"
      />
      <button
        class="w-full py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
        @click="submit"
      >
        Registrarme
      </button>
    </template>
  </div>
</template>
