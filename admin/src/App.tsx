import { FormEvent, useEffect, useState } from 'react';

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';
const adminAuthStorageKey = 'kimura_admin_auth';

type HealthResponse = {
  status: string;
  env: string;
};

type User = {
  id: string;
  email: string;
  role: string;
  name: string;
  age: number;
  job: string;
  bio: string;
  distance: string;
  interests: string[];
  createdAt: string;
  updatedAt: string;
};

type LoginResult = {
  user: User;
  tokens: {
    accessToken: string;
    refreshToken: string;
    tokenType: string;
    expiresIn: number;
  };
};

type UserFormState = {
  email: string;
  password: string;
  name: string;
  age: string;
  job: string;
  bio: string;
  distance: string;
  interests: string;
};

const emptyForm: UserFormState = {
  email: '',
  password: '',
  name: '',
  age: '18',
  job: '',
  bio: '',
  distance: '',
  interests: '',
};

function App() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(false);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string>('');
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [form, setForm] = useState<UserFormState>(emptyForm);
  const [adminEmail, setAdminEmail] = useState('admin@kimura.local');
  const [adminPassword, setAdminPassword] = useState('admin12345');
  const [authToken, setAuthToken] = useState('');
  const [refreshToken, setRefreshToken] = useState('');
  const [adminUser, setAdminUser] = useState<User | null>(null);
  const [loginLoading, setLoginLoading] = useState(false);

  useEffect(() => {
    fetch(`${apiBaseUrl}/health`)
      .then((response) => response.json())
      .then((data: HealthResponse) => setHealth(data))
      .catch(() => setHealth(null));

    const storedAuth = window.localStorage.getItem(adminAuthStorageKey);
    if (!storedAuth) {
      return;
    }

    try {
      const parsed = JSON.parse(storedAuth) as {
        authToken?: string;
        refreshToken?: string;
        adminUser?: User | null;
      };
      setAuthToken(parsed.authToken ?? '');
      setRefreshToken(parsed.refreshToken ?? '');
      setAdminUser(parsed.adminUser ?? null);
    } catch {
      window.localStorage.removeItem(adminAuthStorageKey);
    }
  }, []);

  useEffect(() => {
    if (!authToken || !refreshToken || !adminUser) {
      window.localStorage.removeItem(adminAuthStorageKey);
      return;
    }

    window.localStorage.setItem(
      adminAuthStorageKey,
      JSON.stringify({
        authToken,
        refreshToken,
        adminUser,
      }),
    );
  }, [authToken, refreshToken, adminUser]);

  useEffect(() => {
    if (authToken) {
      void loadUsers(authToken);
    }
  }, [authToken]);

  async function loadUsers(token: string = authToken) {
    if (!token) return;

    setLoadingUsers(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/users`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const data = await response.json();
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to load users');
      }

      setUsers(data.items ?? []);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load users');
    } finally {
      setLoadingUsers(false);
    }
  }

  async function handleAdminLogin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoginLoading(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: adminEmail,
          password: adminPassword,
        }),
      });
      const data = (await response.json()) as LoginResult & { error?: string };
      if (!response.ok) {
        throw new Error(data.error ?? 'Admin login failed');
      }

      setAuthToken(data.tokens.accessToken);
      setRefreshToken(data.tokens.refreshToken);
      setAdminUser(data.user);
      setMessage('Admin login successful.');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Admin login failed');
    } finally {
      setLoginLoading(false);
    }
  }

  async function handleRefreshSession() {
    if (!refreshToken) return;

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      const data = (await response.json()) as LoginResult & { error?: string };
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to refresh session');
      }

      setAuthToken(data.tokens.accessToken);
      setRefreshToken(data.tokens.refreshToken);
      setAdminUser(data.user);
      setMessage('Session refreshed successfully.');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to refresh session');
    }
  }

  async function handleLogout() {
    if (refreshToken) {
      await fetch(`${apiBaseUrl}/api/v1/auth/logout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      }).catch(() => undefined);
    }

    setAuthToken('');
    setRefreshToken('');
    setAdminUser(null);
    setUsers([]);
    resetForm();
    setMessage('Logged out.');
  }

  function selectUser(user: User) {
    setSelectedUserId(user.id);
    setForm({
      email: user.email,
      password: '',
      name: user.name,
      age: String(user.age),
      job: user.job,
      bio: user.bio,
      distance: user.distance,
      interests: user.interests.join(', '),
    });
    setMessage('');
  }

  function resetForm() {
    setSelectedUserId(null);
    setForm(emptyForm);
  }

  function updateField<K extends keyof UserFormState>(key: K, value: UserFormState[K]) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!authToken) return;

    setSaving(true);
    setMessage('');

    const payload = {
      email: form.email,
      password: form.password,
      name: form.name,
      age: Number(form.age),
      job: form.job,
      bio: form.bio,
      distance: form.distance,
      interests: form.interests
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean),
    };

    const endpoint = selectedUserId
      ? `${apiBaseUrl}/api/v1/admin/users/${selectedUserId}`
      : `${apiBaseUrl}/api/v1/admin/users`;
    const method = selectedUserId ? 'PUT' : 'POST';

    try {
      const response = await fetch(endpoint, {
        method,
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authToken}`,
        },
        body: JSON.stringify(payload),
      });
      const data = await response.json();
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to save user');
      }

      setMessage(selectedUserId ? 'User updated successfully.' : 'User created successfully.');
      resetForm();
      await loadUsers();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to save user');
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(userId: string) {
    if (!authToken) return;

    setMessage('');
    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/users/${userId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${authToken}`,
        },
      });
      const data = await response.json();
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to delete user');
      }

      if (selectedUserId === userId) {
        resetForm();
      }
      setMessage('User deleted successfully.');
      await loadUsers();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to delete user');
    }
  }

  const activeUserCount = users.length;

  if (!authToken) {
    return (
      <main className="dashboard">
        <section className="hero auth-hero">
          <div>
            <p className="eyebrow">Kimura Admin</p>
            <h1>ログイン</h1>
            <p className="subcopy">
              管理者アカウントでログインしてください。
            </p>
          </div>
          <div className="server-card">
            <span>Backend</span>
            <strong>{health?.status ?? 'offline'}</strong>
            <small>{health ? `Environment: ${health.env}` : 'Cannot reach API'}</small>
          </div>
        </section>

        <section className="content-grid single-panel">
          <div className="panel auth-panel">
            <div className="panel-header">
              <div>
                <h2>ログイン</h2>
                <p className="muted">メールアドレスとパスワードを入力してください。</p>
              </div>
            </div>
            {message ? <div className="notice">{message}</div> : null}
            <form className="user-form" onSubmit={(event) => void handleAdminLogin(event)}>
              <label className="full-span">
                メールアドレス
                <input
                  onChange={(event) => setAdminEmail(event.target.value)}
                  type="email"
                  value={adminEmail}
                />
              </label>
              <label className="full-span">
                パスワード
                <input
                  onChange={(event) => setAdminPassword(event.target.value)}
                  type="password"
                  value={adminPassword}
                />
              </label>
              <div className="form-actions full-span">
                <button className="login-submit" disabled={loginLoading} type="submit">
                  {loginLoading ? 'ログイン中...' : 'ログイン'}
                </button>
              </div>
            </form>
          </div>
        </section>
      </main>
    );
  }

  return (
    <main className="dashboard">
      <section className="hero">
        <div>
          <p className="eyebrow">Kimura Admin</p>
          <h1>User management for your dating app.</h1>
          <p className="subcopy">
            Logged in as {adminUser?.name}. JWT-protected admin routes now control account
            creation, editing, deletion, and review.
          </p>
        </div>
        <div className="server-card">
          <span>Backend</span>
          <strong>{health?.status ?? 'offline'}</strong>
          <small>{health ? `Environment: ${health.env}` : 'Cannot reach API'}</small>
        </div>
      </section>

      <section className="stats-grid">
        <StatCard label="Total users" value={String(activeUserCount)} accent="rose" />
        <StatCard
          label="Selected mode"
          value={selectedUserId ? 'Edit' : 'Create'}
          accent="gold"
        />
        <StatCard label="Admin role" value={adminUser?.role ?? 'admin'} accent="ink" />
        <StatCard label="Directory state" value={loadingUsers ? 'Syncing' : 'Ready'} accent="mint" />
      </section>

      <section className="content-grid users-layout">
        <div className="panel">
          <div className="panel-header">
            <div>
              <h2>Users</h2>
              <p className="muted">Only authenticated admins can access this list now.</p>
            </div>
            <div className="inline-actions">
              <button className="ghost" onClick={() => void handleRefreshSession()} type="button">
                Refresh session
              </button>
              <button onClick={() => void loadUsers()} type="button">
                Refresh users
              </button>
              <button className="ghost" onClick={() => void handleLogout()} type="button">
                Logout
              </button>
            </div>
          </div>

          {message ? <div className="notice">{message}</div> : null}

          {loadingUsers ? (
            <p className="muted">Loading users...</p>
          ) : users.length === 0 ? (
            <p className="muted">No users found yet.</p>
          ) : (
            <div className="user-list">
              {users.map((user) => (
                <article className="user-item" key={user.id}>
                  <div className="user-item-main">
                    <div>
                      <strong>{user.name}</strong>
                      <p>{user.email}</p>
                    </div>
                    <span className="pill">{user.role}</span>
                  </div>
                  <p className="user-meta">
                    {user.job || 'No job'} | {user.distance || 'No distance'} |{' '}
                    {user.interests.join(', ') || 'No interests'}
                  </p>
                  <div className="user-actions">
                    <button onClick={() => selectUser(user)} type="button">
                      Edit
                    </button>
                    <button className="ghost" onClick={() => void handleDelete(user.id)} type="button">
                      Delete
                    </button>
                  </div>
                </article>
              ))}
            </div>
          )}
        </div>

        <div className="panel">
          <div className="panel-header">
            <div>
              <h2>{selectedUserId ? 'Edit user' : 'Create user'}</h2>
              <p className="muted">Admin actions here are authenticated with Bearer JWT.</p>
            </div>
            {selectedUserId ? (
              <button className="ghost" onClick={resetForm} type="button">
                New user
              </button>
            ) : null}
          </div>

          <form className="user-form" onSubmit={(event) => void handleSubmit(event)}>
            <label>
              Email
              <input
                onChange={(event) => updateField('email', event.target.value)}
                type="email"
                value={form.email}
              />
            </label>
            <label>
              Password {selectedUserId ? '(leave blank to keep current password)' : ''}
              <input
                onChange={(event) => updateField('password', event.target.value)}
                type="password"
                value={form.password}
              />
            </label>
            <label>
              Name
              <input
                onChange={(event) => updateField('name', event.target.value)}
                type="text"
                value={form.name}
              />
            </label>
            <label>
              Age
              <input
                min="18"
                onChange={(event) => updateField('age', event.target.value)}
                type="number"
                value={form.age}
              />
            </label>
            <label>
              Job
              <input
                onChange={(event) => updateField('job', event.target.value)}
                type="text"
                value={form.job}
              />
            </label>
            <label>
              Distance
              <input
                onChange={(event) => updateField('distance', event.target.value)}
                type="text"
                value={form.distance}
              />
            </label>
            <label className="full-span">
              Bio
              <textarea
                onChange={(event) => updateField('bio', event.target.value)}
                rows={4}
                value={form.bio}
              />
            </label>
            <label className="full-span">
              Interests
              <input
                onChange={(event) => updateField('interests', event.target.value)}
                placeholder="Travel, Music, Coffee"
                type="text"
                value={form.interests}
              />
            </label>
            <div className="form-actions full-span">
              <button disabled={saving} type="submit">
                {saving ? 'Saving...' : selectedUserId ? 'Update user' : 'Create user'}
              </button>
            </div>
          </form>
        </div>
      </section>
    </main>
  );
}

function StatCard({
  label,
  value,
  accent,
}: {
  label: string;
  value: string;
  accent: string;
}) {
  return (
    <article className={`stat-card ${accent}`}>
      <span>{label}</span>
      <strong>{value}</strong>
    </article>
  );
}

export default App;
