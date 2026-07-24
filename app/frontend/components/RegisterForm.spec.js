import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import RegisterForm from './RegisterForm.vue'

function mockFetch(response, ok = true) {
  vi.stubGlobal(
    'fetch',
    vi.fn().mockResolvedValue({
      ok,
      status: ok ? 201 : 422,
      json: () => Promise.resolve(response),
    })
  )
}

async function fillAndSubmit(wrapper, username, password) {
  await wrapper.find('input[placeholder="Username"]').setValue(username)
  await wrapper.find('input[type="password"]').setValue(password)
  await wrapper.find('button').trigger('click')
  await flushPromises()
}

describe('RegisterForm', () => {
  beforeEach(() => {
    vi.unstubAllGlobals()
  })

  it('renders username and password inputs', () => {
    const wrapper = mount(RegisterForm)

    expect(wrapper.find('input[placeholder="Username"]').exists()).toBe(true)
    expect(wrapper.find('input[type="password"]').exists()).toBe(true)
  })

  it('shows a success message after registering', async () => {
    mockFetch({ id: 1, username: 'ignacio' })
    const wrapper = mount(RegisterForm)

    await fillAndSubmit(wrapper, 'ignacio', '12345678')

    expect(wrapper.text()).toContain('Cuenta creada')
  })

  it('sends the form data to the api', async () => {
    mockFetch({ id: 1, username: 'ignacio' })
    const wrapper = mount(RegisterForm)

    await fillAndSubmit(wrapper, 'ignacio', '12345678')

    expect(fetch).toHaveBeenCalledWith(
      '/api/v1/users',
      expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({
          user: { username: 'ignacio', password: '12345678' },
        }),
      })
    )
  })

  it('shows validation errors from the api', async () => {
    mockFetch(
      { errors: ['Password is too short (minimum is 8 characters)'] },
      false
    )
    const wrapper = mount(RegisterForm)

    await fillAndSubmit(wrapper, 'ignacio', 'short')

    expect(wrapper.text()).toContain('Password is too short')
    expect(wrapper.find('input[placeholder="Username"]').exists()).toBe(true) // el form sigue visible
  })
})