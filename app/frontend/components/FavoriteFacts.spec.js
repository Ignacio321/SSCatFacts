import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import FavoriteFacts from './FavoriteFacts.vue'

function favorite(id) {
  return { like_id: id, text: `Fact ${id}`, length: 10 }
}

function favorites(...ids) {
  return ids.map(favorite)
}

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

function mockFetchSequence(responses) {
  const fn = vi.fn()
  responses.forEach((response) => {
    fn.mockImplementationOnce(() =>
      Promise.resolve({
        ok: response.ok ?? true,
        status: response.status ?? 200,
        json: () => Promise.resolve(response.body ?? {}),
      })
    )
  })
  vi.stubGlobal('fetch', fn)
  return fn
}

describe('FavoriteFacts', () => {
  beforeEach(() => vi.unstubAllGlobals())

  it('renders the liked facts from the api', async () => {
    mockFetch({ facts: favorites(1), current_page: 1, last_page: 1 })
    const wrapper = mount(FavoriteFacts)
    await flushPromises()

    const items = wrapper.findAll('[data-testid="favorite-item"]')
    expect(items).toHaveLength(1)
    expect(items[0].text()).toContain('Fact 1')
  })

  it('shows a message when there are no favorites', async () => {
    mockFetch({ facts: [], current_page: 1, last_page: 1 })
    const wrapper = mount(FavoriteFacts)
    await flushPromises()

    expect(wrapper.text()).toContain('Todavía no tienes favoritos')
    expect(
      wrapper.find('[data-testid="prev-page"]').attributes('disabled')
    ).toBeDefined()
    expect(
      wrapper.find('[data-testid="next-page"]').attributes('disabled')
    ).toBeDefined()
  })

  it('shows an error message when the api fails', async () => {
    mockFetch({ error: 'boom' }, false)
    const wrapper = mount(FavoriteFacts)
    await flushPromises()

    expect(wrapper.text()).toContain('No pudimos cargar tus favoritos')
  })

  it('removes a favorite when clicking unlike and reloads the same page', async () => {
    mockFetchSequence([
      { body: { facts: favorites(1, 2), current_page: 1, last_page: 1 } },
      {},
      { body: { facts: favorites(2), current_page: 1, last_page: 1 } },
    ])
    const wrapper = mount(FavoriteFacts)
    await flushPromises()

    await wrapper.find('[data-testid="unlike-button"]').trigger('click')
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(3)
    const items = wrapper.findAll('[data-testid="favorite-item"]')
    expect(items).toHaveLength(1)
    expect(items[0].text()).toContain('Fact 2')
  })

  it('goes to the next page and steps back automatically when its last item is unliked', async () => {
    mockFetchSequence([
      { body: { facts: favorites(1, 2, 3), current_page: 1, last_page: 2 } },
      { body: { facts: favorites(4), current_page: 2, last_page: 2 } },
      {},
      { body: { facts: favorites(1, 2, 3), current_page: 1, last_page: 1 } },
    ])
    const wrapper = mount(FavoriteFacts)
    await flushPromises()

    await wrapper.find('[data-testid="next-page"]').trigger('click')
    await flushPromises()
    expect(wrapper.text()).toContain('Fact 4')

    await wrapper.find('[data-testid="unlike-button"]').trigger('click')
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(4)
    expect(wrapper.findAll('[data-testid="favorite-item"]')).toHaveLength(3)
    expect(
      wrapper.find('[data-testid="prev-page"]').attributes('disabled')
    ).toBeDefined()
  })
})
