import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import App from './App.vue'
import RegisterForm from './components/RegisterForm.vue'

describe('App', () => {
  it('renders Register Form', () => {
    const wrapper = mount(App)
    expect(wrapper.findComponent(RegisterForm).exists()).toBe(true)
  })
})
