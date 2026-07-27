import { describe, it, expect, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import LoginForm from './LoginForm.vue'
import { useAuthStore } from '../stores/auth'

function mountForm() {
  const wrapper = mount(LoginForm, {
    global: {
      plugins: [createTestingPinia({ createSpy: vi.fn })],
    },
  })
  return { wrapper, auth: useAuthStore() }
}

describe('LoginForm', () => {
  it('calls the login action with the credentials', async () => {
    const { wrapper, auth } = mountForm()

    await wrapper.find('input[placeholder="Username"]').setValue('ignacio')
    await wrapper.find('input[type="password"]').setValue('12345678')
    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(auth.login).toHaveBeenCalledWith('ignacio', '12345678')
  })

  it('shows an error when the credentials are wrong', async () => {
    const { wrapper, auth } = mountForm()
    auth.login.mockRejectedValueOnce({ status: 401 })

    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('incorrectos')
  })

  it('shows a rate limit message when throttled', async () => {
    const { wrapper, auth } = mountForm()
    auth.login.mockRejectedValueOnce({
      status: 429,
      error: 'Too many login attempts. Please try again later.',
    })

    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('Too many login attempts')
  })

  it('shows a connection error when the request fails outright', async () => {
    const { wrapper, auth } = mountForm()
    auth.login.mockRejectedValueOnce(new TypeError('Failed to fetch'))

    await wrapper.find('button').trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('No pudimos conectar')
  })
})
