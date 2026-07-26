import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import App from './App.vue'
import LoginForm from './components/LoginForm.vue'
import RegisterForm from './components/RegisterForm.vue'
import { useAuthStore } from './stores/auth'

function mountApp(authState = {}) {
  const wrapper = mount(App, {
    global: {
      plugins: [
        createTestingPinia({
          createSpy: vi.fn,
          initialState: {
            auth: { user: null, loading: false, ...authState },
          },
        }),
      ],
    },
  })
  return { wrapper, auth: useAuthStore() }
}

describe('App', () => {
  it('fetches the current user on mount', () => {
    const { auth } = mountApp()

    expect(auth.fetchCurrentUser).toHaveBeenCalled()
  })

  it('shows a loading state initially', () => {
    const { wrapper } = mountApp({ loading: true })

    expect(wrapper.text()).toContain('Cargando')
  })

  it('shows the login form when logged out', () => {
    const { wrapper } = mountApp()

    expect(wrapper.findComponent(LoginForm).exists()).toBe(true)
  })

  it('toggles to the register form', async () => {
    const { wrapper } = mountApp()

    await wrapper.find('[data-testid="toggle-register"]').trigger('click')

    expect(wrapper.findComponent(RegisterForm).exists()).toBe(true)
  })

  it('greets the user when logged in', () => {
    const { wrapper } = mountApp({ user: { id: 1, username: 'ignacio' } })

    expect(wrapper.text()).toContain('ignacio')
    expect(wrapper.findComponent(LoginForm).exists()).toBe(false)
  })
})
