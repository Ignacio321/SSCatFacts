import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import FactsList from './FactsList.vue'

function fact(n) {
  return { text: `Fact ${n}`, length: 10 }
}

function facts(...ns) {
  return ns.map(fact)
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

describe('FactsList', () => {
  beforeEach(() => vi.unstubAllGlobals())

  it('renders up to 10 facts from a single page', async () => {
    mockFetchSequence([
      { body: { facts: [] } },
      {
        body: {
          facts: facts(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
          current_page: 1,
          last_page: 3,
        },
      },
    ])
    const wrapper = mount(FactsList)
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(2)
    expect(wrapper.findAll('[data-testid="fact-item"]')).toHaveLength(10)
  })

  it('pulls from more pages to fill up to 10 when some facts are already liked', async () => {
    mockFetchSequence([
      { body: { facts: [{ text: 'Fact 2' }, { text: 'Fact 4' }] } },
      {
        body: {
          facts: facts(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
          current_page: 1,
          last_page: 3,
        },
      },
      { body: { facts: facts(11, 12, 13), current_page: 2, last_page: 3 } },
    ])
    const wrapper = mount(FactsList)
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(3)
    expect(wrapper.findAll('[data-testid="fact-item"]')).toHaveLength(10)
  })

  it('shows an error message when the api fails', async () => {
    mockFetchSequence([
      { body: { facts: [] } },
      { ok: false, status: 503, body: { error: 'boom' } },
    ])
    const wrapper = mount(FactsList)
    await flushPromises()

    expect(wrapper.text()).toContain('No pudimos cargar')
  })

  it('shows a message when every fact has already been liked', async () => {
    mockFetchSequence([
      { body: { facts: [{ text: 'Fact 1' }] } },
      { body: { facts: facts(1), current_page: 1, last_page: 1 } },
    ])
    const wrapper = mount(FactsList)
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(2)
    expect(wrapper.text()).toContain(
      'Le diste like a todos los cat facts disponibles'
    )
    expect(
      wrapper.find('[data-testid="next-page"]').attributes('disabled')
    ).toBeDefined()
    expect(
      wrapper.find('[data-testid="prev-page"]').attributes('disabled')
    ).toBeDefined()
  })

  it('refills to 10 after liking a fact, pulling from the next page', async () => {
    mockFetchSequence([
      { body: { facts: [] } },
      {
        body: {
          facts: facts(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
          current_page: 1,
          last_page: 3,
        },
      },
      { status: 201, body: { id: 1, fact: fact(1) } },
      { body: { facts: facts(11), current_page: 2, last_page: 3 } },
    ])
    const wrapper = mount(FactsList)
    await flushPromises()

    await wrapper.find('[data-testid="like-button"]').trigger('click')
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(4)
    expect(wrapper.findAll('[data-testid="fact-item"]')).toHaveLength(10)
    expect(wrapper.text()).toContain('Fact 11')
  })

  it('goes to the next screen and back without refetching', async () => {
    mockFetchSequence([
      { body: { facts: [] } },
      {
        body: {
          facts: facts(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
          current_page: 1,
          last_page: 2,
        },
      },
      { body: { facts: facts(11, 12, 13), current_page: 2, last_page: 2 } },
    ])
    const wrapper = mount(FactsList)
    await flushPromises()

    await wrapper.find('[data-testid="next-page"]').trigger('click')
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(3)
    expect(wrapper.findAll('[data-testid="fact-item"]')).toHaveLength(3)
    expect(
      wrapper.find('[data-testid="next-page"]').attributes('disabled')
    ).toBeDefined()

    await wrapper.find('[data-testid="prev-page"]').trigger('click')
    await flushPromises()

    expect(fetch).toHaveBeenCalledTimes(3)
    expect(wrapper.findAll('[data-testid="fact-item"]')).toHaveLength(10)
    expect(
      wrapper.find('[data-testid="next-page"]').attributes('disabled')
    ).toBeUndefined()
    expect(
      wrapper.find('[data-testid="prev-page"]').attributes('disabled')
    ).toBeDefined()
  })
})
