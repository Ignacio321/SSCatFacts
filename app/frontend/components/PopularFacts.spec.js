import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import PopularFacts from './PopularFacts.vue'

function mockFetch(response, ok = true) {
  vi.stubGlobal(
    'fetch',
    vi.fn().mockResolvedValue({
      ok,
      status: ok ? 200 : 500,
      json: () => Promise.resolve(response),
    })
  )
}

describe('PopularFacts', () => {
  beforeEach(() => vi.unstubAllGlobals())

  it('renders the popular facts with their likes count', async () => {
    mockFetch({
      facts: [{ text: 'Cats purr at 26 hertz.', length: 22, likes_count: 5 }],
    })
    const wrapper = mount(PopularFacts)
    await flushPromises()

    const items = wrapper.findAll('[data-testid="popular-item"]')
    expect(items).toHaveLength(1)
    expect(items[0].text()).toContain('Cats purr')
    expect(items[0].text()).toContain('5')
  })

  it('shows a message when there are no popular facts yet', async () => {
    mockFetch({ facts: [] })
    const wrapper = mount(PopularFacts)
    await flushPromises()

    expect(wrapper.text()).toContain('Todavía no hay facts populares')
  })

  it('shows an error message when the api fails', async () => {
    mockFetch({ error: 'boom' }, false)
    const wrapper = mount(PopularFacts)
    await flushPromises()

    expect(wrapper.text()).toContain('No pudimos cargar los más populares')
  })
})
