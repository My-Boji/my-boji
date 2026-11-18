import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.myboji.store',
  appName: 'My Boji',
  webDir: 'dist',
  plugins: {
    SplashScreen: {
      launchShowDuration: 1800,
      launchAutoHide: true,
      backgroundColor: '#101010',
      androidScaleType: 'CENTER_INSIDE',
      showSpinner: false,
    },
  },
}

export default config
