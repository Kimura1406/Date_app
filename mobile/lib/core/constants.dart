const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

const authStorageKey = 'kimura_mobile_auth';
const rememberedLoginStorageKey = 'kimura_mobile_login_form';
