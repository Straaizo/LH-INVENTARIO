import { createContext, useContext, useEffect, useState } from 'react'

const Ctx = createContext({ dark: false, toggle: () => {} })

export function ThemeProvider({ children }) {
  const [dark, setDark] = useState(() => {
    const saved = localStorage.getItem('theme')
    return saved === 'dark'
  })

  useEffect(() => {
    document.documentElement.classList.toggle('dark', dark)
    localStorage.setItem('theme', dark ? 'dark' : 'light')
    const meta = document.querySelector('meta[name="theme-color"]')
    if (meta) meta.setAttribute('content', dark ? '#1A2332' : '#ffffff')
  }, [dark])

  function toggle() {
    const html = document.documentElement
    html.classList.add('theme-transitioning')
    setDark(d => !d)
    setTimeout(() => html.classList.remove('theme-transitioning'), 350)
  }

  return (
    <Ctx.Provider value={{ dark, toggle }}>
      {children}
    </Ctx.Provider>
  )
}

export function useTheme() { return useContext(Ctx) }
