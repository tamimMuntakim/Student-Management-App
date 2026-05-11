module.exports = {
  content: ["./index.html", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        teal: {
          600: '#0f766e',
          700: '#0f766e'
        },
        brand: {
          primary: '#007bff',
          bg: '#f4f7f6'
        }
      }
    }
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: [
      {
        studentapp: {
          primary: '#0f766e',
          secondary: '#007bff',
          accent: '#28a745',
          neutral: '#f4f7f6',
          'base-100': '#ffffff'
        }
      }
    ]
  }
}
