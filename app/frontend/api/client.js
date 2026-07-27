function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content
}

export async function apiPost(path, body) {
  const response = await fetch(path, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken(),
    },
    credentials: 'same-origin',
    body: JSON.stringify(body),
  })
  const data = await response.json().catch(() => ({}))
  if (!response.ok) throw { status: response.status, ...data }
  return data
}

export async function apiGet(path) {
  const response = await fetch(path, { credentials: 'same-origin' })
  const data = await response.json().catch(() => ({}))
  if (!response.ok) throw { status: response.status, ...data }
  return data
}

export async function apiDelete(path) {
  const response = await fetch(path, {
    method: 'DELETE',
    headers: { 'X-CSRF-Token': csrfToken() },
    credentials: 'same-origin',
  })
  if (!response.ok) throw { status: response.status }
}
