import { defineStore } from 'pinia'
import { apiGet, apiPost, apiDelete } from '../api/client'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    loading: true,
  }),

  getters: {
    isLoggedIn: (state) => state.user !== null,
  },

  actions: {
    async fetchCurrentUser() {
      try {
        this.user = await apiGet('/api/v1/me')
      } catch {
        this.user = null
      } finally {
        this.loading = false
      }
    },

    async login(username, password) {
      this.user = await apiPost('/api/v1/session', { username, password })
    },

    async logout() {
      await apiDelete('/api/v1/session')
      this.user = null
    },

    setUser(user) {
      this.user = user
    },
  },
})
