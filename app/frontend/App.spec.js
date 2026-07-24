import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import App from './App.vue'

describe('App', () => {
  it('renders the heading', () => {
    const wrapper = mount(App)
    expect(wrapper.find('h1').exists()).toBe(true)
  })

  it('increments the counter on click', async () => {
    const wrapper = mount(App)
    await wrapper.find('button').trigger('click')
    expect(wrapper.text()).toContain('1')
  })
})
