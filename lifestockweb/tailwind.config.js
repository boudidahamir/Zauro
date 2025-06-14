module.exports = {
    theme: {
      extend: {
        animation: {
          'slide-in': 'slideIn 0.5s ease-out',
        },
        keyframes: {
          slideIn: {
            '0%': { transform: 'translateY(-20px)', opacity: '0' },
            '100%': { transform: 'translateY(0)', opacity: '1' },
          },
        },
      },
    },
  };