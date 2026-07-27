import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import FactsList from './FactsList.vue'

function mockFetch(response, ok = true) {
  vi.stubGlobal(
    'fetch',
    vi.fn().mockResolvedValue({
      ok,
      status: ok ? 200 : 503,
      json: () => Promise.resolve(response),
    })
  )
}

describe('FactsList', () => {
  beforeEach(() => vi.unstubAllGlobals())

  it('renders the facts from the api', async () => {
    mockFetch({ facts: [{ text: 'Cats purr at 26 hertz.', length: 22 }] })
    const wrapper = mount(FactsList)
    await flushPromises()

    const items = wrapper.findAll('[data-testid="fact-item"]')
    expect(items).toHaveLength(1)
    expect(items[0].text()).toContain('Cats purr')
  })

  it('shows an error message when the api fails', async () => {
    mockFetch({ error: 'Cat facts are unavailable right now' }, false)
    const wrapper = mount(FactsList)
    await flushPromises()

    expect(wrapper.text()).toContain('No pudimos cargar')
  })

  it('reloads facts when clicking reload', async () => {
    mockFetch({ facts: [{ text: 'First fact', length: 10 }] })
    const wrapper = mount(FactsList)
    await flushPromises()

    await wrapper.find('[data-testid="reload-facts"]').trigger('click')
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(2)
  })
})
