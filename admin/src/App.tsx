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
  birthDate: string;
  country: string;
  prefecture: string;
  datingReason: string;
  createdAt: string;
  lastLoginAt: string;
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
  birthDate: string;
  country: string;
  prefecture: string;
  datingReason: string;
};

type ChatMessage = {
  id: string;
  senderId: string;
  senderName: string;
  body: string;
  sentAt: string;
};

type ChatRoom = {
  roomId: string;
  roomType: 'user' | 'admin';
  participants: Array<{
    userId: string;
    name: string;
    role: string;
  }>;
  lastMessage: string;
  lastMessageAt: string;
  messages: ChatMessage[];
};

type MenuKey = 'user-list' | 'chat' | 'gift' | 'sales' | 'revenue';

const menuSections: Array<{
  label: string;
  children?: Array<{ key: MenuKey; label: string }>;
  key?: MenuKey;
}> = [
  {
    label: '\u30e6\u30fc\u30b6\u30fc\u7ba1\u7406',
    children: [{ key: 'user-list', label: '\u30e6\u30fc\u30b6\u30fc\u4e00\u89a7' }],
  },
  { key: 'chat', label: '\u30c1\u30e3\u30c3\u30c8\u7ba1\u7406' },
  { key: 'gift', label: '\u30ae\u30d5\u30c8\u7ba1\u7406' },
  { key: 'sales', label: '\u8ca9\u58f2\u7ba1\u7406' },
  { key: 'revenue', label: '\u58f2\u4e0a\u7ba1\u7406' },
];

const viewMeta: Record<MenuKey, { title: string; description: string }> = {
  'user-list': {
    title: '\u30e6\u30fc\u30b6\u30fc\u4e00\u89a7',
    description:
      '\u7ba1\u7406\u8005\u306e\u307f\u30e6\u30fc\u30b6\u30fc\u306e\u4f5c\u6210\u3001\u7de8\u96c6\u3001\u524a\u9664\u3001\u78ba\u8a8d\u304c\u3067\u304d\u307e\u3059\u3002',
  },
  chat: {
    title: '\u30c1\u30e3\u30c3\u30c8\u7ba1\u7406',
    description:
      '\u30e6\u30fc\u30b6\u30fc\u30c1\u30e3\u30c3\u30c8\u3068\u904b\u55b6\u696d\u8005\u30c1\u30e3\u30c3\u30c8\u3092\u5207\u308a\u66ff\u3048\u3066\u78ba\u8a8d\u3067\u304d\u307e\u3059\u3002',
  },
  gift: {
    title: '\u30ae\u30d5\u30c8\u7ba1\u7406',
    description:
      '\u3053\u306e\u753b\u9762\u306f\u307e\u3060\u6e96\u5099\u4e2d\u3067\u3059\u3002\u30ae\u30d5\u30c8\u30de\u30b9\u30bf\u306e\u7ba1\u7406\u3092\u5f8c\u304b\u3089\u8ffd\u52a0\u3067\u304d\u307e\u3059\u3002',
  },
  sales: {
    title: '\u8ca9\u58f2\u7ba1\u7406',
    description:
      '\u3053\u306e\u753b\u9762\u306f\u307e\u3060\u6e96\u5099\u4e2d\u3067\u3059\u3002\u8ca9\u58f2\u30d7\u30e9\u30f3\u3084\u5546\u54c1\u7ba1\u7406\u3092\u3053\u3053\u306b\u8ffd\u52a0\u3067\u304d\u307e\u3059\u3002',
  },
  revenue: {
    title: '\u58f2\u4e0a\u7ba1\u7406',
    description:
      '\u3053\u306e\u753b\u9762\u306f\u307e\u3060\u6e96\u5099\u4e2d\u3067\u3059\u3002\u58f2\u4e0a\u30ec\u30dd\u30fc\u30c8\u3068\u96c6\u8a08\u30c0\u30c3\u30b7\u30e5\u30dc\u30fc\u30c9\u3092\u5f8c\u304b\u3089\u8ffd\u52a0\u3067\u304d\u307e\u3059\u3002',
  },
};

const emptyForm: UserFormState = {
  email: '',
  password: '',
  name: '',
  birthDate: '',
  country: '',
  prefecture: '',
  datingReason: '',
};

function App() {
  const pageSizeOptions = [10, 20, 50, 100];
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
  const [logoutLoading, setLogoutLoading] = useState(false);
  const [activeMenu, setActiveMenu] = useState<MenuKey>('user-list');
  const [isUserModalOpen, setIsUserModalOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [selectedChatRoom, setSelectedChatRoom] = useState<ChatRoom | null>(null);
  const [chatTab, setChatTab] = useState<'user' | 'admin'>('user');
  const [chatRooms, setChatRooms] = useState<ChatRoom[]>([]);
  const [loadingChatRooms, setLoadingChatRooms] = useState(false);
  const [chatDetailLoading, setChatDetailLoading] = useState(false);
  const [sendingChatMessage, setSendingChatMessage] = useState(false);
  const [chatMessageDraft, setChatMessageDraft] = useState('');

  function clearAdminSession(sessionMessage: string) {
    window.localStorage.removeItem(adminAuthStorageKey);
    setAuthToken('');
    setRefreshToken('');
    setAdminUser(null);
    setUsers([]);
    setChatRooms([]);
    setSelectedChatRoom(null);
    setActiveMenu('user-list');
    setMessage(sessionMessage);
  }

  function isInvalidTokenResponse(response: Response, data: { error?: string }) {
    return response.status === 401 && data.error === 'invalid token';
  }

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

  useEffect(() => {
    if (authToken && activeMenu === 'chat') {
      void loadChatRooms(chatTab, authToken);
    }
  }, [activeMenu, authToken, chatTab]);

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
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to load users');
      }

      setUsers(data.items ?? []);
      setCurrentPage(1);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load users');
    } finally {
      setLoadingUsers(false);
    }
  }

  async function loadChatRooms(type: 'user' | 'admin', token: string = authToken) {
    if (!token) return;

    setLoadingChatRooms(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/chat-rooms?type=${type}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const data = await response.json();
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to load chat rooms');
      }

      setChatRooms(data.items ?? []);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load chat rooms');
    } finally {
      setLoadingChatRooms(false);
    }
  }

  async function openChatRoomDetail(roomId: string) {
    if (!authToken) return;

    setChatDetailLoading(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/chat-rooms/${roomId}`, {
        headers: {
          Authorization: `Bearer ${authToken}`,
        },
      });
      const data = (await response.json()) as ChatRoom & { error?: string };
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to load chat detail');
      }

      setSelectedChatRoom(data);
      setChatMessageDraft('');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load chat detail');
    } finally {
      setChatDetailLoading(false);
    }
  }

  async function openAdminChatForUser(user: User) {
    if (!authToken || !adminUser) return;
    if (user.id === adminUser.id || user.role === 'admin') {
      setMessage('Admin account chat is not available here.');
      return;
    }

    setChatDetailLoading(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/users/${user.id}/operator-chat`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${authToken}`,
        },
      });
      const data = (await response.json()) as ChatRoom & { error?: string };
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to open operator chat room');
      }

      setSelectedChatRoom(data);
      setChatMessageDraft('');
    } catch (error) {
      setMessage(
        error instanceof Error ? error.message : 'Failed to open operator chat room',
      );
    } finally {
      setChatDetailLoading(false);
    }
  }

  async function handleSendChatMessage() {
    if (!authToken || !selectedChatRoom || !chatMessageDraft.trim()) return;

    setSendingChatMessage(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/chat-rooms/${selectedChatRoom.roomId}/messages`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authToken}`,
        },
        body: JSON.stringify({ body: chatMessageDraft.trim() }),
      });
      const data = await response.json();
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to send message');
      }

      setChatMessageDraft('');
      await Promise.all([openChatRoomDetail(selectedChatRoom.roomId), loadChatRooms(chatTab)]);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to send message');
    } finally {
      setSendingChatMessage(false);
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
      setActiveMenu('user-list');
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
    setLogoutLoading(true);
    setMessage('');

    if (refreshToken) {
      try {
        const response = await fetch(`${apiBaseUrl}/api/v1/admin/auth/logout`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refreshToken }),
        });
        const data = (await response.json()) as { error?: string };
        if (!response.ok) {
          throw new Error(data.error ?? 'Failed to logout');
        }
      } catch (error) {
        setMessage(error instanceof Error ? error.message : 'Failed to logout');
        setLogoutLoading(false);
        return;
      }
    }

    setAuthToken('');
    setRefreshToken('');
    setAdminUser(null);
    setUsers([]);
    resetForm();
    setActiveMenu('user-list');
    setMessage('Logged out.');
    setLogoutLoading(false);
  }

  function openEditUserModal(user: User) {
    setActiveMenu('user-list');
    setSelectedUserId(user.id);
    setForm({
      email: user.email,
      password: '',
      name: user.name,
      birthDate: user.birthDate,
      country: user.country,
      prefecture: user.prefecture,
      datingReason: user.datingReason,
    });
    setMessage('');
    setIsUserModalOpen(true);
  }

  function openCreateUserModal() {
    resetForm();
    setMessage('');
    setIsUserModalOpen(true);
  }

  function closeUserModal() {
    setIsUserModalOpen(false);
    resetForm();
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
      birthDate: form.birthDate,
      country: form.country,
      prefecture: form.prefecture,
      datingReason: form.datingReason,
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
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to save user');
      }

      setMessage(selectedUserId ? 'User updated successfully.' : 'User created successfully.');
      closeUserModal();
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
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
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

  function renderMenu() {
    return (
      <nav className="sidebar-nav">
        {menuSections.map((section) => {
          if (section.children) {
            return (
              <div className="nav-group" key={section.label}>
                <button className="nav-group-label" type="button">
                  {section.label}
                </button>
                <div className="nav-submenu">
                  {section.children.map((child) => (
                    <button
                      className={`nav-item nav-subitem ${activeMenu === child.key ? 'active' : ''}`}
                      key={child.key}
                      onClick={() => setActiveMenu(child.key)}
                      type="button"
                    >
                      {child.label}
                    </button>
                  ))}
                </div>
              </div>
            );
          }

          return (
            <button
              className={`nav-item ${activeMenu === section.key ? 'active' : ''}`}
              key={section.label}
              onClick={() => setActiveMenu(section.key!)}
              type="button"
            >
              {section.label}
            </button>
          );
        })}

        <button className="nav-item logout-nav" disabled={logoutLoading} onClick={() => void handleLogout()} type="button">
          {logoutLoading ? 'Logging out...' : '\u30ed\u30b0\u30a2\u30a6\u30c8'}
        </button>
      </nav>
    );
  }

  function renderPlaceholderView(view: MenuKey) {
    return (
      <section className="panel placeholder-panel">
        <div className="panel-header">
          <div>
            <h2>{viewMeta[view].title}</h2>
            <p className="muted">{viewMeta[view].description}</p>
          </div>
        </div>
        <div className="coming-soon">
          <strong>Coming soon</strong>
          <p>{viewMeta[view].description}</p>
        </div>
      </section>
    );
  }

  const activeUserCount = users.length;
  const totalPages = Math.max(1, Math.ceil(users.length / pageSize));
  const normalizedPage = Math.min(currentPage, totalPages);
  const pagedUsers = users.slice((normalizedPage - 1) * pageSize, normalizedPage * pageSize);

  if (!authToken) {
    return (
      <main className="dashboard">
        <section className="hero auth-hero">
          <div>
            <p className="eyebrow">Kimura Admin</p>
            <h1>{'\u30ed\u30b0\u30a4\u30f3'}</h1>
            <p className="subcopy">
              {
                '\u7ba1\u7406\u8005\u30a2\u30ab\u30a6\u30f3\u30c8\u3067\u30ed\u30b0\u30a4\u30f3\u3057\u3066\u304f\u3060\u3055\u3044\u3002'
              }
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
                <h2>{'\u30ed\u30b0\u30a4\u30f3'}</h2>
                <p className="muted">
                  {
                    '\u30e1\u30fc\u30eb\u30a2\u30c9\u30ec\u30b9\u3068\u30d1\u30b9\u30ef\u30fc\u30c9\u3092\u5165\u529b\u3057\u3066\u304f\u3060\u3055\u3044\u3002'
                  }
                </p>
              </div>
            </div>
            {message ? <div className="notice">{message}</div> : null}
            <form className="user-form" onSubmit={(event) => void handleAdminLogin(event)}>
              <label className="full-span">
                {'\u30e1\u30fc\u30eb\u30a2\u30c9\u30ec\u30b9'}
                <input
                  onChange={(event) => setAdminEmail(event.target.value)}
                  type="email"
                  value={adminEmail}
                />
              </label>
              <label className="full-span">
                {'\u30d1\u30b9\u30ef\u30fc\u30c9'}
                <input
                  onChange={(event) => setAdminPassword(event.target.value)}
                  type="password"
                  value={adminPassword}
                />
              </label>
              <div className="form-actions full-span">
                <button className="login-submit" disabled={loginLoading} type="submit">
                  {loginLoading ? '\u30ed\u30b0\u30a4\u30f3\u4e2d...' : '\u30ed\u30b0\u30a4\u30f3'}
                </button>
              </div>
            </form>
          </div>
        </section>
      </main>
    );
  }

  return (
    <main className="admin-shell">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <p className="eyebrow">Kimura Admin</p>
          <h1>{'\u7ba1\u7406\u753b\u9762'}</h1>
          <p className="muted">{adminUser?.name}</p>
        </div>
        {renderMenu()}
      </aside>

      <section className="admin-main">
        <section className="hero compact-hero">
          <div>
            <p className="eyebrow">{viewMeta[activeMenu].title}</p>
            <h1>{viewMeta[activeMenu].title}</h1>
            <p className="subcopy">{viewMeta[activeMenu].description}</p>
          </div>
        </section>

        {activeMenu === 'user-list' ? (
          <>
            <section className="content-grid user-list-layout">
              <div className="panel">
                <div className="panel-header panel-header-right">
                  <div className="inline-actions">
                    <button onClick={openCreateUserModal} type="button">
                      {'\u65b0\u898f\u767b\u9332'}
                    </button>
                  </div>
                </div>

                {message ? <div className="notice">{message}</div> : null}

                {loadingUsers ? (
                  <p className="muted">Loading users...</p>
                ) : users.length === 0 ? (
                  <p className="muted">No users found yet.</p>
                ) : (
                  <>
                    <div className="table-wrap">
                      <table className="user-table">
                        <thead>
                          <tr>
                            <th>ID</th>
                            <th>{'\u30e6\u30fc\u30b6\u30fc\u30cd\u30fc\u30e0'}</th>
                            <th>{'\u751f\u5e74\u6708\u65e5'}</th>
                            <th>{'\u56fd'}</th>
                            <th>{'\u90fd\u9053\u5e9c\u770c'}</th>
                            <th>{'\u4ed8\u304d\u5408\u3046\u7406\u7531'}</th>
                            <th>{'\u65b0\u898f\u767b\u9332\u65e5'}</th>
                            <th>{'\u6700\u7d42\u30ed\u30b0\u30a4\u30f3\u65e5\u6642'}</th>
                            <th>Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                          {pagedUsers.map((user) => (
                            <tr key={user.id}>
                              <td>
                                <div className="table-id-cell">
                                  <code>{user.id}</code>
                                  <span className="pill">{user.role}</span>
                                </div>
                              </td>
                              <td>{user.name}</td>
                              <td>{formatDate(user.birthDate)}</td>
                              <td>{user.country || '-'}</td>
                              <td>{user.prefecture || '-'}</td>
                              <td className="reason-cell" title={user.datingReason}>
                                {truncateReason(user.datingReason)}
                              </td>
                              <td>{formatDateTime(user.createdAt)}</td>
                              <td>{formatDateTime(user.lastLoginAt)}</td>
                              <td>
                                <div className="user-actions">
                                  <button onClick={() => openEditUserModal(user)} type="button">
                                    Edit
                                  </button>
                                  <button
                                    className="ghost"
                                    onClick={() => void openAdminChatForUser(user)}
                                    type="button"
                                  >
                                    Chat
                                  </button>
                                  <button className="ghost" onClick={() => void handleDelete(user.id)} type="button">
                                    Delete
                                  </button>
                                </div>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>

                    <div className="pagination-bar">
                      <div className="pagination-meta">
                        <span>{users.length} users</span>
                        <label className="page-size-label">
                          <span>Rows per page</span>
                          <select
                            onChange={(event) => {
                              setPageSize(Number(event.target.value));
                              setCurrentPage(1);
                            }}
                            value={pageSize}
                          >
                            {pageSizeOptions.map((option) => (
                              <option key={option} value={option}>
                                {option}
                              </option>
                            ))}
                          </select>
                        </label>
                      </div>

                      <div className="pagination-actions">
                        <span>
                          Page {normalizedPage} / {totalPages}
                        </span>
                        <button
                          className="ghost"
                          disabled={normalizedPage <= 1}
                          onClick={() => setCurrentPage((page) => Math.max(1, page - 1))}
                          type="button"
                        >
                          Prev
                        </button>
                        <button
                          disabled={normalizedPage >= totalPages}
                          onClick={() => setCurrentPage((page) => Math.min(totalPages, page + 1))}
                          type="button"
                        >
                          Next
                        </button>
                      </div>
                    </div>
                  </>
                )}
              </div>
            </section>

            {isUserModalOpen ? (
              <div className="modal-backdrop" onClick={closeUserModal} role="presentation">
                <div className="modal-panel" onClick={(event) => event.stopPropagation()} role="dialog" aria-modal="true">
                  <div className="panel-header">
                    <div>
                      <h2>{selectedUserId ? 'Edit user' : 'Create new user'}</h2>
                      <p className="muted">Admin actions here are authenticated with Bearer JWT.</p>
                    </div>
                    <button className="ghost" onClick={closeUserModal} type="button">
                      Close
                    </button>
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
                      {'\u30e6\u30fc\u30b6\u30fc\u30cd\u30fc\u30e0'}
                      <input
                        onChange={(event) => updateField('name', event.target.value)}
                        type="text"
                        value={form.name}
                      />
                    </label>
                    <label>
                      {'\u751f\u5e74\u6708\u65e5'}
                      <input
                        onChange={(event) => updateField('birthDate', event.target.value)}
                        type="date"
                        value={form.birthDate}
                      />
                    </label>
                    <label>
                      {'\u56fd'}
                      <input
                        onChange={(event) => updateField('country', event.target.value)}
                        type="text"
                        value={form.country}
                      />
                    </label>
                    <label>
                      {'\u90fd\u9053\u5e9c\u770c'}
                      <input
                        onChange={(event) => updateField('prefecture', event.target.value)}
                        type="text"
                        value={form.prefecture}
                      />
                    </label>
                    <label className="full-span">
                      {'\u4ed8\u304d\u5408\u3046\u7406\u7531'}
                      <textarea
                        maxLength={100}
                        onChange={(event) => updateField('datingReason', event.target.value)}
                        rows={4}
                        value={form.datingReason}
                      />
                      <small className="field-note">{form.datingReason.length}/100</small>
                    </label>
                    <div className="form-actions full-span">
                      <button className="ghost" onClick={closeUserModal} type="button">
                        Cancel
                      </button>
                      <button disabled={saving} type="submit">
                        {saving ? 'Saving...' : selectedUserId ? 'Update user' : 'Create user'}
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            ) : null}
          </>
        ) : activeMenu === 'chat' ? (
          <>
            <section className="content-grid user-list-layout">
              <div className="panel">
                <div className="panel-header panel-header-right">
                  <div className="inline-actions">
                    <div className="chat-segmented">
                      <button
                        className={chatTab === 'user' ? 'active' : 'ghost'}
                        onClick={() => setChatTab('user')}
                        type="button"
                      >
                        {'\u30e6\u30fc\u30b6\u30fc\u30c1\u30e3\u30c3\u30c8'}
                      </button>
                      <button
                        className={chatTab === 'admin' ? 'active' : 'ghost'}
                        onClick={() => setChatTab('admin')}
                        type="button"
                      >
                        {'\u904b\u55b6\u696d\u8005'}
                      </button>
                    </div>
                  </div>
                </div>

                {message ? <div className="notice">{message}</div> : null}

                {loadingChatRooms ? (
                  <p className="muted">Loading chat rooms...</p>
                ) : chatRooms.length === 0 ? (
                  <p className="muted">No chat rooms found yet.</p>
                ) : (
                  <div className="table-wrap">
                    <table className="user-table chat-table">
                      <thead>
                        <tr>
                          <th>{'\u30eb\u30fc\u30e0ID'}</th>
                          <th>{'\u53c2\u52a0\u8005'}</th>
                          <th>{'\u6700\u7d42\u30e1\u30c3\u30bb\u30fc\u30b8'}</th>
                          <th>Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {chatRooms.map((room) => (
                          <tr key={room.roomId}>
                            <td>
                              <code>{room.roomId}</code>
                            </td>
                            <td>
                              <div className="chat-participants">
                                <span>{room.participants[0]?.name ?? '-'}</span>
                                <span className="chat-participant-sep">/</span>
                                <span>{room.participants[1]?.name ?? '-'}</span>
                              </div>
                            </td>
                            <td className="chat-last-message">{room.lastMessage}</td>
                            <td>
                              <button onClick={() => void openChatRoomDetail(room.roomId)} type="button">
                                {'\u8a73\u7d30\u3078'}
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </section>

          </>
        ) : (
          renderPlaceholderView(activeMenu)
        )}

        {selectedChatRoom ? (
          <div className="modal-backdrop" onClick={() => setSelectedChatRoom(null)} role="presentation">
            <div className="modal-panel chat-detail-modal" onClick={(event) => event.stopPropagation()} role="dialog" aria-modal="true">
              <div className="panel-header">
                <div>
                  <h2>{selectedChatRoom.roomId}</h2>
                  <p className="muted">
                    {selectedChatRoom.participants[0]?.name ?? '-'} / {selectedChatRoom.participants[1]?.name ?? '-'}
                  </p>
                </div>
                <button className="ghost" onClick={() => setSelectedChatRoom(null)} type="button">
                  Close
                </button>
              </div>

              {chatDetailLoading ? <p className="muted">Loading chat detail...</p> : null}

              <div className="chat-detail-thread">
                {selectedChatRoom.messages.map((chat) => (
                  <article className="chat-detail-message" key={chat.id}>
                    <div className="chat-detail-meta">
                      <strong>{chat.senderName}</strong>
                      <span>{chat.sentAt}</span>
                    </div>
                    <p>{chat.body}</p>
                  </article>
                ))}
              </div>

              <div className="chat-detail-compose">
                <textarea
                  onChange={(event) => setChatMessageDraft(event.target.value)}
                  placeholder="Type a reply..."
                  rows={3}
                  value={chatMessageDraft}
                />
                <div className="form-actions">
                  <button
                    disabled={sendingChatMessage || !chatMessageDraft.trim()}
                    onClick={() => void handleSendChatMessage()}
                    type="button"
                  >
                    {sendingChatMessage ? 'Sending...' : 'Send message'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        ) : null}
      </section>
    </main>
  );
}

function truncateReason(value: string) {
  if (value.length <= 100) {
    return value;
  }
  return `${value.slice(0, 100)}...`;
}

function formatDate(value: string) {
  if (!value) {
    return '-';
  }
  return value;
}

function formatDateTime(value: string) {
  if (!value) {
    return '-';
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return value;
  }

  return parsed.toLocaleString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  });
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
