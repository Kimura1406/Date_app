import { ChangeEvent, FormEvent, useEffect, useRef, useState } from 'react';

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
  pointBalance: number;
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

type Flower = {
  id: string;
  name: string;
  imageUrl: string;
  description: string;
  pricePoints: number;
  purchaserCount: number;
  purchaseCount: number;
  published: boolean;
  createdAt: string;
  updatedAt: string;
};

type FlowerFormState = {
  imageUrl: string;
  name: string;
  description: string;
  pricePoints: number;
  published: boolean;
};

type Banner = {
  id: string;
  imageUrl: string;
  eventName: string;
  displayOrder: number;
  redirectLink: string;
  published: boolean;
  createdAt: string;
  updatedAt: string;
};

type BannerFormState = {
  imageUrl: string;
  eventName: string;
  displayOrder: number;
  redirectLink: string;
  published: boolean;
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

type ReportEntry = {
  id: string;
  reporterUserId: string;
  reporterUserName: string;
  reason: string;
  createdAt: string;
};

type ReportSummary = {
  id: string;
  reportedUserId: string;
  reportedUserName: string;
  latestReporterUserId: string;
  latestReporterName: string;
  latestReason: string;
  latestReportedAt: string;
  reports: ReportEntry[];
};

type MenuKey = 'user-list' | 'chat' | 'gift' | 'sales' | 'report' | 'revenue';
type AdminPath =
  | 'user-list'
  | 'user-list/new'
  | 'chat'
  | 'gift'
  | 'gift/new'
  | 'sales'
  | 'sales/new'
  | 'report'
  | 'revenue';

const menuSections: Array<{
  label: string;
  children?: Array<{ key: MenuKey; label: string }>;
  key?: MenuKey;
}> = [
  { key: 'user-list', label: '\u30e6\u30fc\u30b6\u30fc\u7ba1\u7406' },
  { key: 'chat', label: '\u30c1\u30e3\u30c3\u30c8\u7ba1\u7406' },
  { key: 'gift', label: '\u304a\u82b1\u7ba1\u7406' },
  { key: 'sales', label: '\u30d0\u30ca\u30fc\u7ba1\u7406' },
  { key: 'report', label: '\u901a\u5831\u7ba1\u7406' },
  { key: 'revenue', label: '\u58f2\u4e0a\u7ba1\u7406' },
];

const viewMeta: Record<MenuKey, { title: string; description: string }> = {
  'user-list': {
    title: '\u30e6\u30fc\u30b6\u30fc\u7ba1\u7406',
    description:
      '\u7ba1\u7406\u8005\u306e\u307f\u30e6\u30fc\u30b6\u30fc\u306e\u4f5c\u6210\u3001\u7de8\u96c6\u3001\u524a\u9664\u3001\u78ba\u8a8d\u304c\u3067\u304d\u307e\u3059\u3002',
  },
  chat: {
    title: '\u30c1\u30e3\u30c3\u30c8\u7ba1\u7406',
    description:
      '\u30e6\u30fc\u30b6\u30fc\u30c1\u30e3\u30c3\u30c8\u3068\u904b\u55b6\u696d\u8005\u30c1\u30e3\u30c3\u30c8\u3092\u5207\u308a\u66ff\u3048\u3066\u78ba\u8a8d\u3067\u304d\u307e\u3059\u3002',
  },
  gift: {
    title: '\u304a\u82b1\u7ba1\u7406',
    description:
      '\u3053\u306e\u753b\u9762\u306f\u307e\u3060\u6e96\u5099\u4e2d\u3067\u3059\u3002\u304a\u82b1\u30de\u30b9\u30bf\u306e\u7ba1\u7406\u3092\u5f8c\u304b\u3089\u8ffd\u52a0\u3067\u304d\u307e\u3059\u3002',
  },
  sales: {
    title: '\u30d0\u30ca\u30fc\u7ba1\u7406',
    description:
      '\u30a4\u30d9\u30f3\u30c8\u30d0\u30ca\u30fc\u306e\u516c\u958b\u72b6\u614b\u3084\u8868\u793a\u9806\u3001\u518d\u7528\u30ea\u30f3\u30af\u3092\u7ba1\u7406\u3067\u304d\u307e\u3059\u3002',
  },
  report: {
    title: '\u901a\u5831\u7ba1\u7406',
    description:
      '\u901a\u5831\u3055\u308c\u305f\u30e6\u30fc\u30b6\u30fc\u3068\u76f4\u8fd1\u306e\u901a\u5831\u5185\u5bb9\u3092\u78ba\u8a8d\u3067\u304d\u307e\u3059\u3002',
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

const emptyFlowerForm: FlowerFormState = {
  imageUrl: '',
  name: '',
  description: '',
  pricePoints: 1,
  published: true,
};

const emptyBannerForm: BannerFormState = {
  imageUrl: '',
  eventName: '',
  displayOrder: 0,
  redirectLink: '',
  published: true,
};

const defaultPath: AdminPath = 'user-list';

function parseAdminPath(hash: string): AdminPath {
  const raw = hash.replace(/^#/, '');
  switch (raw) {
    case '/users':
      return 'user-list';
    case '/users/new':
      return 'user-list/new';
    case '/chat':
      return 'chat';
    case '/flowers':
      return 'gift';
    case '/flowers/new':
      return 'gift/new';
    case '/banners':
      return 'sales';
    case '/banners/new':
      return 'sales/new';
    case '/reports':
      return 'report';
    case '/revenue':
      return 'revenue';
    default:
      return defaultPath;
  }
}

function pathToHash(path: AdminPath) {
  switch (path) {
    case 'user-list':
      return '#/users';
    case 'user-list/new':
      return '#/users/new';
    case 'chat':
      return '#/chat';
    case 'gift':
      return '#/flowers';
    case 'gift/new':
      return '#/flowers/new';
    case 'sales':
      return '#/banners';
    case 'sales/new':
      return '#/banners/new';
    case 'report':
      return '#/reports';
    case 'revenue':
      return '#/revenue';
  }
}

function menuKeyFromPath(path: AdminPath): MenuKey {
  switch (path) {
    case 'user-list':
    case 'user-list/new':
      return 'user-list';
    case 'gift':
    case 'gift/new':
      return 'gift';
    case 'sales':
    case 'sales/new':
      return 'sales';
    case 'report':
      return 'report';
    default:
      return path;
  }
}

function menuKeyToPath(menuKey: MenuKey): AdminPath {
  switch (menuKey) {
    case 'user-list':
      return 'user-list';
    case 'chat':
      return 'chat';
    case 'gift':
      return 'gift';
    case 'sales':
      return 'sales';
    case 'report':
      return 'report';
    case 'revenue':
      return 'revenue';
  }
}

function App() {
  const pageSizeOptions = [10, 20, 50, 100];
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(false);
  const [flowers, setFlowers] = useState<Flower[]>([]);
  const [loadingFlowers, setLoadingFlowers] = useState(false);
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loadingBanners, setLoadingBanners] = useState(false);
  const [reports, setReports] = useState<ReportSummary[]>([]);
  const [loadingReports, setLoadingReports] = useState(false);
  const [saving, setSaving] = useState(false);
  const [grantingPoints, setGrantingPoints] = useState(false);
  const [savingFlower, setSavingFlower] = useState(false);
  const [savingBanner, setSavingBanner] = useState(false);
  const [message, setMessage] = useState<string>('');
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [selectedFlowerId, setSelectedFlowerId] = useState<string | null>(null);
  const [selectedBannerId, setSelectedBannerId] = useState<string | null>(null);
  const [form, setForm] = useState<UserFormState>(emptyForm);
  const [flowerForm, setFlowerForm] = useState<FlowerFormState>(emptyFlowerForm);
  const [bannerForm, setBannerForm] = useState<BannerFormState>(emptyBannerForm);
  const [adminEmail, setAdminEmail] = useState('admin@kimura.local');
  const [adminPassword, setAdminPassword] = useState('admin12345');
  const [authToken, setAuthToken] = useState('');
  const [refreshToken, setRefreshToken] = useState('');
  const [adminUser, setAdminUser] = useState<User | null>(null);
  const [loginLoading, setLoginLoading] = useState(false);
  const [logoutLoading, setLogoutLoading] = useState(false);
  const [activePath, setActivePath] = useState<AdminPath>(() => parseAdminPath(window.location.hash));
  const [activeMenu, setActiveMenu] = useState<MenuKey>(() => menuKeyFromPath(parseAdminPath(window.location.hash)));
  const [isUserModalOpen, setIsUserModalOpen] = useState(false);
  const [isFlowerModalOpen, setIsFlowerModalOpen] = useState(false);
  const [isBannerModalOpen, setIsBannerModalOpen] = useState(false);
  const [userCurrentPage, setUserCurrentPage] = useState(1);
  const [userPageSize, setUserPageSize] = useState(10);
  const [chatCurrentPage, setChatCurrentPage] = useState(1);
  const [chatPageSize, setChatPageSize] = useState(10);
  const [flowerCurrentPage, setFlowerCurrentPage] = useState(1);
  const [flowerPageSize, setFlowerPageSize] = useState(10);
  const [bannerCurrentPage, setBannerCurrentPage] = useState(1);
  const [bannerPageSize, setBannerPageSize] = useState(10);
  const [bannerSearch, setBannerSearch] = useState('');
  const [reportCurrentPage, setReportCurrentPage] = useState(1);
  const [reportPageSize, setReportPageSize] = useState(10);
  const [reportSearch, setReportSearch] = useState('');
  const [selectedReportSummary, setSelectedReportSummary] = useState<ReportSummary | null>(null);
  const [selectedChatRoom, setSelectedChatRoom] = useState<ChatRoom | null>(null);
  const [chatTab, setChatTab] = useState<'user' | 'admin'>('user');
  const [chatRooms, setChatRooms] = useState<ChatRoom[]>([]);
  const [loadingChatRooms, setLoadingChatRooms] = useState(false);
  const [chatDetailLoading, setChatDetailLoading] = useState(false);
  const [sendingChatMessage, setSendingChatMessage] = useState(false);
  const [chatMessageDraft, setChatMessageDraft] = useState('');
  const [pointGrantValue, setPointGrantValue] = useState('0');
  const chatThreadRef = useRef<HTMLDivElement | null>(null);

  function clearAdminSession(sessionMessage: string) {
    window.localStorage.removeItem(adminAuthStorageKey);
    setAuthToken('');
    setRefreshToken('');
    setAdminUser(null);
    setUsers([]);
    setFlowers([]);
    setBanners([]);
    setReports([]);
    setChatRooms([]);
    setSelectedChatRoom(null);
    navigateToPath('user-list');
    setMessage(sessionMessage);
  }

  function navigateToPath(path: AdminPath) {
    const nextHash = pathToHash(path);
    if (window.location.hash !== nextHash) {
      window.location.hash = nextHash;
    } else {
      setActivePath(path);
      setActiveMenu(menuKeyFromPath(path));
    }
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
    const handleHashChange = () => {
      const nextPath = parseAdminPath(window.location.hash);
      setActivePath(nextPath);
      setActiveMenu(menuKeyFromPath(nextPath));
    };

    handleHashChange();
    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
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

  useEffect(() => {
    if (authToken && activeMenu === 'gift') {
      void loadFlowers(authToken);
    }
  }, [activeMenu, authToken]);

  useEffect(() => {
    if (authToken && activeMenu === 'sales') {
      void loadBanners(authToken);
    }
  }, [activeMenu, authToken]);

  useEffect(() => {
    if (authToken && activeMenu === 'report') {
      void loadReports(authToken);
    }
  }, [activeMenu, authToken]);

  useEffect(() => {
    if (!selectedChatRoom) {
      return;
    }

    const frame = window.requestAnimationFrame(() => {
      const thread = chatThreadRef.current;
      if (!thread) {
        return;
      }
      thread.scrollTop = thread.scrollHeight;
    });

    return () => window.cancelAnimationFrame(frame);
  }, [selectedChatRoom?.roomId, selectedChatRoom?.messages.length, chatDetailLoading]);

  useEffect(() => {
    if (!selectedChatRoom || !authToken) {
      return;
    }

    const interval = window.setInterval(() => {
      void openChatRoomDetail(selectedChatRoom.roomId, {
        silent: true,
        preserveDraft: true,
      });
    }, 3000);

    return () => window.clearInterval(interval);
  }, [authToken, selectedChatRoom?.roomId]);

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
      setUserCurrentPage(1);
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
      setChatCurrentPage(1);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load chat rooms');
    } finally {
      setLoadingChatRooms(false);
    }
  }

  async function loadFlowers(token: string = authToken) {
    if (!token) return;

    setLoadingFlowers(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/flowers`, {
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
        throw new Error(data.error ?? 'Failed to load flowers');
      }

      setFlowers(data.items ?? []);
      setFlowerCurrentPage(1);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load flowers');
    } finally {
      setLoadingFlowers(false);
    }
  }

  async function loadBanners(token: string = authToken) {
    if (!token) return;

    setLoadingBanners(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/banners`, {
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
        throw new Error(data.error ?? 'Failed to load banners');
      }

      setBanners(data.items ?? []);
      setBannerCurrentPage(1);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load banners');
    } finally {
      setLoadingBanners(false);
    }
  }

  async function loadReports(token: string = authToken) {
    if (!token) return;

    setLoadingReports(true);
    setMessage('');

    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/reports`, {
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
        throw new Error(data.error ?? 'Failed to load reports');
      }

      setReports(data.items ?? []);
      setReportCurrentPage(1);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to load reports');
    } finally {
      setLoadingReports(false);
    }
  }

  async function openChatRoomDetail(
    roomId: string,
    options?: { silent?: boolean; preserveDraft?: boolean },
  ) {
    if (!authToken) return;

    const silent = options?.silent ?? false;
    const preserveDraft = options?.preserveDraft ?? false;

    if (!silent) {
      setChatDetailLoading(true);
      setMessage('');
    }

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
      if (!preserveDraft) {
        setChatMessageDraft('');
      }
    } catch (error) {
      if (!silent) {
        setMessage(error instanceof Error ? error.message : 'Failed to load chat detail');
      }
    } finally {
      if (!silent) {
        setChatDetailLoading(false);
      }
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
      navigateToPath('user-list');
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
    setFlowers([]);
    setBanners([]);
    resetForm();
    resetFlowerForm();
    resetBannerForm();
    navigateToPath('user-list');
    setMessage('Logged out.');
    setLogoutLoading(false);
  }

  function openEditUserModal(user: User) {
    navigateToPath('user-list');
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
    setPointGrantValue('0');
    setMessage('');
    setIsUserModalOpen(true);
  }

  function openCreateUserModal() {
    resetForm();
    setMessage('');
    navigateToPath('user-list/new');
  }

  function openCreateFlowerModal() {
    resetFlowerForm();
    setMessage('');
    navigateToPath('gift/new');
  }

  function closeUserModal() {
    setIsUserModalOpen(false);
    resetForm();
  }

  function closeFlowerModal() {
    setIsFlowerModalOpen(false);
    resetFlowerForm();
  }

  function closeBannerModal() {
    setIsBannerModalOpen(false);
    resetBannerForm();
  }

  function resetForm() {
    setSelectedUserId(null);
    setForm(emptyForm);
    setPointGrantValue('0');
  }

  function resetFlowerForm() {
    setSelectedFlowerId(null);
    setFlowerForm(emptyFlowerForm);
  }

  function resetBannerForm() {
    setSelectedBannerId(null);
    setBannerForm(emptyBannerForm);
  }

  function updateField<K extends keyof UserFormState>(key: K, value: UserFormState[K]) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function updateFlowerField<K extends keyof FlowerFormState>(key: K, value: FlowerFormState[K]) {
    setFlowerForm((current) => ({ ...current, [key]: value }));
  }

  function updateBannerField<K extends keyof BannerFormState>(key: K, value: BannerFormState[K]) {
    setBannerForm((current) => ({ ...current, [key]: value }));
  }

  function openEditFlowerModal(flower: Flower) {
    navigateToPath('gift');
    setSelectedFlowerId(flower.id);
    setFlowerForm({
      imageUrl: flower.imageUrl,
      name: flower.name,
      description: flower.description,
      pricePoints: flower.pricePoints,
      published: flower.published,
    });
    setMessage('');
    setIsFlowerModalOpen(true);
  }

  function openCreateBannerModal() {
    resetBannerForm();
    setMessage('');
    navigateToPath('sales/new');
  }

  function openEditBannerModal(banner: Banner) {
    navigateToPath('sales');
    setSelectedBannerId(banner.id);
    setBannerForm({
      imageUrl: banner.imageUrl,
      eventName: banner.eventName,
      displayOrder: banner.displayOrder,
      redirectLink: banner.redirectLink,
      published: banner.published,
    });
    setMessage('');
    setIsBannerModalOpen(true);
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
      if (selectedUserId) {
        closeUserModal();
      } else {
        resetForm();
        navigateToPath('user-list');
      }
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

  async function handleGrantPoints() {
    if (!authToken || !selectedUserId) return;

    const amount = Number(pointGrantValue);
    if (!Number.isFinite(amount) || amount <= 0) {
      setMessage('Points must be greater than 0.');
      return;
    }

    setGrantingPoints(true);
    setMessage('');
    try {
      const response = await fetch(`${apiBaseUrl}/api/v1/admin/users/${selectedUserId}/points`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authToken}`,
        },
        body: JSON.stringify({ points: amount }),
      });
      const data = await response.json();
      if (isInvalidTokenResponse(response, data)) {
        clearAdminSession('Session expired. Please login again.');
        return;
      }
      if (!response.ok) {
        throw new Error(data.error ?? 'Failed to grant points');
      }

      setUsers((current) => current.map((user) => (user.id === data.id ? (data as User) : user)));
      setPointGrantValue('0');
      setMessage('Points granted successfully.');
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to grant points');
    } finally {
      setGrantingPoints(false);
    }
  }

  async function handleFlowerImageChange(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        updateFlowerField('imageUrl', reader.result);
      }
    };
    reader.readAsDataURL(file);
    event.target.value = '';
  }

  async function handleFlowerSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!authToken) return;

    setSavingFlower(true);
    setMessage('');

    const payload = {
      imageUrl: flowerForm.imageUrl,
      name: flowerForm.name,
      description: flowerForm.description,
      pricePoints: flowerForm.pricePoints,
      published: flowerForm.published,
    };

    const endpoint = selectedFlowerId
      ? `${apiBaseUrl}/api/v1/admin/flowers/${selectedFlowerId}`
      : `${apiBaseUrl}/api/v1/admin/flowers`;
    const method = selectedFlowerId ? 'PUT' : 'POST';

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
        throw new Error(data.error ?? 'Failed to save flower');
      }

      setMessage(selectedFlowerId ? 'Flower updated successfully.' : 'Flower created successfully.');
      if (selectedFlowerId) {
        closeFlowerModal();
      } else {
        resetFlowerForm();
        navigateToPath('gift');
      }
      await loadFlowers();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to save flower');
    } finally {
      setSavingFlower(false);
    }
  }

  async function handleBannerImageChange(event: ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      if (typeof reader.result === 'string') {
        updateBannerField('imageUrl', reader.result);
      }
    };
    reader.readAsDataURL(file);
    event.target.value = '';
  }

  async function handleBannerSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!authToken) return;

    setSavingBanner(true);
    setMessage('');

    const payload = {
      imageUrl: bannerForm.imageUrl,
      eventName: bannerForm.eventName,
      displayOrder: bannerForm.displayOrder,
      redirectLink: bannerForm.redirectLink,
      published: bannerForm.published,
    };

    const endpoint = selectedBannerId
      ? `${apiBaseUrl}/api/v1/admin/banners/${selectedBannerId}`
      : `${apiBaseUrl}/api/v1/admin/banners`;
    const method = selectedBannerId ? 'PUT' : 'POST';

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
        throw new Error(data.error ?? 'Failed to save banner');
      }

      setMessage(selectedBannerId ? 'Banner updated successfully.' : 'Banner created successfully.');
      if (selectedBannerId) {
        closeBannerModal();
      } else {
        resetBannerForm();
        navigateToPath('sales');
      }
      await loadBanners();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Failed to save banner');
    } finally {
      setSavingBanner(false);
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
                      onClick={() => navigateToPath(menuKeyToPath(child.key))}
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
              onClick={() => navigateToPath(menuKeyToPath(section.key!))}
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

  const filteredBanners = banners.filter((banner) => {
    const query = bannerSearch.trim().toLowerCase();
    if (!query) {
      return true;
    }
    return (
      banner.id.toLowerCase().includes(query) ||
      banner.eventName.toLowerCase().includes(query) ||
      banner.redirectLink.toLowerCase().includes(query)
    );
  });
  const filteredReports = reports.filter((report) => {
    const query = reportSearch.trim().toLowerCase();
    if (!query) {
      return true;
    }
    return (
      report.id.toLowerCase().includes(query) ||
      report.reportedUserName.toLowerCase().includes(query) ||
      report.latestReporterName.toLowerCase().includes(query) ||
      report.latestReason.toLowerCase().includes(query)
    );
  });
  const userPagination = paginateItems(users, userCurrentPage, userPageSize);
  const chatPagination = paginateItems(chatRooms, chatCurrentPage, chatPageSize);
  const flowerPagination = paginateItems(flowers, flowerCurrentPage, flowerPageSize);
  const bannerPagination = paginateItems(filteredBanners, bannerCurrentPage, bannerPageSize);
  const reportPagination = paginateItems(filteredReports, reportCurrentPage, reportPageSize);

  function renderCreateUserPanel() {
    return (
      <div className="panel subscreen-panel">
        <div className="panel-header">
          <div>
            <h2>Create new user</h2>
          </div>
        </div>
        {message ? <div className="notice">{message}</div> : null}
        <form className="user-form" onSubmit={(event) => void handleSubmit(event)}>
          <label>
            Email
            <input onChange={(event) => updateField('email', event.target.value)} type="email" value={form.email} />
          </label>
          <label>
            Password
            <input onChange={(event) => updateField('password', event.target.value)} type="password" value={form.password} />
          </label>
          <label>
            {'\u30e6\u30fc\u30b6\u30fc\u30cd\u30fc\u30e0'}
            <input onChange={(event) => updateField('name', event.target.value)} type="text" value={form.name} />
          </label>
          <label>
            {'\u751f\u5e74\u6708\u65e5'}
            <input onChange={(event) => updateField('birthDate', event.target.value)} type="date" value={form.birthDate} />
          </label>
          <label>
            {'\u56fd'}
            <input onChange={(event) => updateField('country', event.target.value)} type="text" value={form.country} />
          </label>
          <label>
            {'\u90fd\u9053\u5e9c\u770c'}
            <input onChange={(event) => updateField('prefecture', event.target.value)} type="text" value={form.prefecture} />
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
            <button className="ghost" onClick={() => navigateToPath('user-list')} type="button">
              Cancel
            </button>
            <button disabled={saving} type="submit">
              {saving ? 'Saving...' : 'Create user'}
            </button>
          </div>
        </form>
      </div>
    );
  }

  function renderCreateFlowerPanel() {
    return (
      <div className="panel subscreen-panel">
        <div className="panel-header">
          <div>
            <h2>{'\u304a\u82b1\u6295\u7a3f'}</h2>
          </div>
        </div>
        {message ? <div className="notice">{message}</div> : null}
        <form className="user-form" onSubmit={(event) => void handleFlowerSubmit(event)}>
          <label className="full-span">
            {'\u753b\u50cf\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9'}
            <input accept="image/*" onChange={(event) => void handleFlowerImageChange(event)} type="file" />
            {flowerForm.imageUrl ? <img alt="Flower preview" className="flower-preview" src={flowerForm.imageUrl} /> : null}
          </label>
          <label className="full-span">
            {'\u82b1\u306e\u540d\u524d'}
            <input
              maxLength={50}
              onChange={(event) => updateFlowerField('name', event.target.value)}
              type="text"
              value={flowerForm.name}
            />
            <small className="field-note">{flowerForm.name.length}/50</small>
          </label>
          <label className="full-span">
            {'\u82b1\u306b\u3064\u3044\u3066'}
            <textarea
              maxLength={100}
              onChange={(event) => updateFlowerField('description', event.target.value)}
              rows={4}
              value={flowerForm.description}
            />
            <small className="field-note">{flowerForm.description.length}/100</small>
          </label>
          <label className="full-span">
            {'\u4fa1\u683c'}
            <div className="price-stepper">
              <button className="ghost" onClick={() => updateFlowerField('pricePoints', Math.max(1, flowerForm.pricePoints - 1))} type="button">
                -
              </button>
              <input
                min={1}
                onChange={(event) => updateFlowerField('pricePoints', Math.max(1, Number(event.target.value) || 1))}
                type="number"
                value={flowerForm.pricePoints}
              />
              <span>P</span>
              <button className="ghost" onClick={() => updateFlowerField('pricePoints', flowerForm.pricePoints + 1)} type="button">
                +
              </button>
            </div>
          </label>
          <fieldset className="full-span publish-fieldset">
            <legend>{'\u516c\u958b\u72b6\u614b'}</legend>
            <label className="radio-option">
              <input checked={flowerForm.published} name="flower-publish" onChange={() => updateFlowerField('published', true)} type="radio" />
              {'\u516c\u958b'}
            </label>
            <label className="radio-option">
              <input checked={!flowerForm.published} name="flower-publish" onChange={() => updateFlowerField('published', false)} type="radio" />
              {'\u975e\u516c\u958b'}
            </label>
          </fieldset>
          <div className="form-actions full-span">
            <button className="ghost" onClick={() => navigateToPath('gift')} type="button">
              Cancel
            </button>
            <button disabled={savingFlower} type="submit">
              {savingFlower ? 'Saving...' : '\u6295\u7a3f'}
            </button>
          </div>
        </form>
      </div>
    );
  }

  function renderCreateBannerPanel() {
    return (
      <div className="panel subscreen-panel">
        <div className="panel-header">
          <div>
            <h2>{'\u65b0\u898f\u4f5c\u6210'}</h2>
          </div>
        </div>
        {message ? <div className="notice">{message}</div> : null}
        <form className="user-form" onSubmit={(event) => void handleBannerSubmit(event)}>
          <label className="full-span">
            {'\u753b\u50cf\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9'}
            <input accept="image/*" onChange={(event) => void handleBannerImageChange(event)} type="file" />
            {bannerForm.imageUrl ? <img alt="Banner preview" className="banner-preview" src={bannerForm.imageUrl} /> : null}
          </label>
          <label>
            {'\u30a4\u30d9\u30f3\u30c8\u540d'}
            <input
              maxLength={100}
              onChange={(event) => updateBannerField('eventName', event.target.value)}
              type="text"
              value={bannerForm.eventName}
            />
          </label>
          <label>
            {'\u8868\u793a\u9806'}
            <input
              min={0}
              onChange={(event) => updateBannerField('displayOrder', Math.max(0, Number(event.target.value) || 0))}
              type="number"
              value={bannerForm.displayOrder}
            />
          </label>
          <label className="full-span">
            {'\u518d\u7528\u30ea\u30f3\u30af'}
            <input
              onChange={(event) => updateBannerField('redirectLink', event.target.value)}
              placeholder="https://example.com"
              type="url"
              value={bannerForm.redirectLink}
            />
          </label>
          <fieldset className="full-span publish-fieldset">
            <legend>{'\u72b6\u614b'}</legend>
            <label className="radio-option">
              <input checked={bannerForm.published} name="banner-publish" onChange={() => updateBannerField('published', true)} type="radio" />
              {'\u516c\u958b'}
            </label>
            <label className="radio-option">
              <input checked={!bannerForm.published} name="banner-publish" onChange={() => updateBannerField('published', false)} type="radio" />
              {'\u672a\u516c\u958b'}
            </label>
          </fieldset>
          <div className="form-actions full-span">
            <button className="ghost" onClick={() => navigateToPath('sales')} type="button">
              Cancel
            </button>
            <button disabled={savingBanner} type="submit">
              {savingBanner ? 'Saving...' : '\u6295\u7a3f'}
            </button>
          </div>
        </form>
      </div>
    );
  }

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
        <section className="hero compact-hero admin-page-hero">
          <div>
            <h1>{viewMeta[activeMenu].title}</h1>
          </div>
        </section>

        {activeMenu === 'user-list' ? (
          <>
            <section className="content-grid user-list-layout">
              {activePath === 'user-list/new' ? renderCreateUserPanel() : (
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
                    <div className="table-wrap fixed-list-wrap">
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
                          {userPagination.items.map((user) => (
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
                              setUserPageSize(Number(event.target.value));
                              setUserCurrentPage(1);
                            }}
                            value={userPageSize}
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
                          Page {userPagination.page} / {userPagination.totalPages}
                        </span>
                        <button
                          className="ghost"
                          disabled={userPagination.page <= 1}
                          onClick={() => setUserCurrentPage((page) => Math.max(1, page - 1))}
                          type="button"
                        >
                          Prev
                        </button>
                        <button
                          disabled={userPagination.page >= userPagination.totalPages}
                          onClick={() =>
                            setUserCurrentPage((page) =>
                              Math.min(userPagination.totalPages, page + 1),
                            )
                          }
                          type="button"
                        >
                          Next
                        </button>
                      </div>
                    </div>
                  </>
                )}
                </div>
              )}
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
                    {selectedUserId ? (
                      <div className="full-span point-grant-panel">
                        <div className="point-grant-header">
                          <strong>{'\u30dd\u30a4\u30f3\u30c8\u4ed8\u4e0e'}</strong>
                          <span className="muted">
                            Current: {users.find((user) => user.id === selectedUserId)?.pointBalance ?? 0}P
                          </span>
                        </div>
                        <div className="point-grant-controls">
                          <input
                            min={1}
                            onChange={(event) => setPointGrantValue(event.target.value)}
                            type="number"
                            value={pointGrantValue}
                          />
                          <button disabled={grantingPoints} onClick={() => void handleGrantPoints()} type="button">
                            {grantingPoints ? 'Submitting...' : 'Submit'}
                          </button>
                        </div>
                      </div>
                    ) : null}
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
                <div className="panel-header">
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
                  <div className="table-wrap fixed-list-wrap">
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
                        {chatPagination.items.map((room) => (
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

                {!loadingChatRooms && chatRooms.length > 0 ? (
                  <div className="pagination-bar">
                    <div className="pagination-meta">
                      <span>{chatRooms.length} rooms</span>
                      <label className="page-size-label">
                        <span>Rows per page</span>
                        <select
                          onChange={(event) => {
                            setChatPageSize(Number(event.target.value));
                            setChatCurrentPage(1);
                          }}
                          value={chatPageSize}
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
                        Page {chatPagination.page} / {chatPagination.totalPages}
                      </span>
                      <button
                        className="ghost"
                        disabled={chatPagination.page <= 1}
                        onClick={() => setChatCurrentPage((page) => Math.max(1, page - 1))}
                        type="button"
                      >
                        Prev
                      </button>
                      <button
                        disabled={chatPagination.page >= chatPagination.totalPages}
                        onClick={() =>
                          setChatCurrentPage((page) =>
                            Math.min(chatPagination.totalPages, page + 1),
                          )
                        }
                        type="button"
                      >
                        Next
                      </button>
                    </div>
                  </div>
                ) : null}
              </div>
            </section>

          </>
        ) : activeMenu === 'gift' ? (
          <>
            <section className="content-grid user-list-layout">
              {activePath === 'gift/new' ? renderCreateFlowerPanel() : (
                <div className="panel flower-panel">
                <div className="panel-header flower-panel-header">
                  <div className="flower-record-count">
                    {'件数'}: {flowers.length} {'件'}
                  </div>
                  <div className="inline-actions">
                    <button onClick={openCreateFlowerModal} type="button">
                      {'\u304a\u82b1\u6295\u7a3f'}
                    </button>
                  </div>
                </div>

                {message ? <div className="notice">{message}</div> : null}

                {loadingFlowers ? (
                  <p className="muted">Loading flowers...</p>
                ) : flowers.length === 0 ? (
                  <p className="muted">No flowers found yet.</p>
                ) : (
                  <div className="table-wrap flower-table-wrap fixed-list-wrap">
                    <table className="user-table flower-table">
                      <thead>
                        <tr>
                          <th>ID</th>
                          <th>{'\u82b1\u306e\u540d\u524d'}</th>
                          <th>{'\u753b\u50cf'}</th>
                          <th>{'\u4fa1\u683c'}</th>
                          <th>{'\u8cfc\u5165\u8005\u6570'}</th>
                          <th>{'\u8cfc\u5165\u56de\u6570'}</th>
                          <th>Edit</th>
                        </tr>
                      </thead>
                      <tbody>
                        {flowerPagination.items.map((flower) => (
                          <tr key={flower.id}>
                            <td>
                              <code>{flower.id}</code>
                            </td>
                            <td>
                              <div className="flower-name-cell">
                                <strong>{flower.name}</strong>
                              </div>
                            </td>
                            <td>
                              <img
                                alt={flower.name}
                                className="flower-thumb"
                                src={flower.imageUrl}
                              />
                            </td>
                            <td>{flower.pricePoints}P</td>
                            <td>{flower.purchaserCount}</td>
                            <td>{flower.purchaseCount}</td>
                            <td>
                              <div className="flower-actions">
                                <span className={`status-chip ${flower.published ? 'published' : 'draft'}`}>
                                  {flower.published ? '\u516c\u958b' : '\u975e\u516c\u958b'}
                                </span>
                                <button onClick={() => openEditFlowerModal(flower)} type="button">
                                  Edit
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}

                {!loadingFlowers && flowers.length > 0 ? (
                  <div className="pagination-bar">
                    <div className="pagination-meta">
                      <span>{flowers.length} 件</span>
                      <label className="page-size-label">
                        <span>Rows per page</span>
                        <select
                          onChange={(event) => {
                            setFlowerPageSize(Number(event.target.value));
                            setFlowerCurrentPage(1);
                          }}
                          value={flowerPageSize}
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
                        Page {flowerPagination.page} / {flowerPagination.totalPages}
                      </span>
                      <button
                        className="ghost"
                        disabled={flowerPagination.page <= 1}
                        onClick={() => setFlowerCurrentPage((page) => Math.max(1, page - 1))}
                        type="button"
                      >
                        Prev
                      </button>
                      <button
                        disabled={flowerPagination.page >= flowerPagination.totalPages}
                        onClick={() =>
                          setFlowerCurrentPage((page) =>
                            Math.min(flowerPagination.totalPages, page + 1),
                          )
                        }
                        type="button"
                      >
                        Next
                      </button>
                    </div>
                  </div>
                ) : null}
                </div>
              )}
            </section>
          </>
        ) : activeMenu === 'sales' ? (
          <>
            <section className="content-grid user-list-layout">
              {activePath === 'sales/new' ? renderCreateBannerPanel() : (
                <div className="panel banner-panel">
                <div className="panel-header panel-header-right banner-toolbar">
                  <div className="inline-actions banner-toolbar-actions">
                    <label className="banner-search">
                      <input
                        onChange={(event) => {
                          setBannerSearch(event.target.value);
                          setBannerCurrentPage(1);
                        }}
                        placeholder={'\u691c\u7d22'}
                        type="search"
                        value={bannerSearch}
                      />
                    </label>
                    <button className="banner-create-button" onClick={openCreateBannerModal} type="button">
                      + {'\u65b0\u898f\u4f5c\u6210'}
                    </button>
                  </div>
                </div>

                {message ? <div className="notice">{message}</div> : null}

                {loadingBanners ? (
                  <p className="muted">Loading banners...</p>
                ) : filteredBanners.length === 0 ? (
                  <p className="muted">No banners found yet.</p>
                ) : (
                  <>
                    <div className="table-wrap banner-table-wrap fixed-list-wrap">
                      <table className="user-table banner-table">
                        <thead>
                          <tr>
                            <th className="banner-check-cell">
                              <input type="checkbox" />
                            </th>
                            <th>ID</th>
                            <th>{'\u753b\u50cf'}</th>
                            <th>{'\u30a4\u30d9\u30f3\u30c8\u540d'}</th>
                            <th>{'\u8868\u793a\u9806'}</th>
                            <th>{'\u518d\u7528\u30ea\u30f3\u30af'}</th>
                            <th>{'\u72b6\u614b'}</th>
                            <th />
                          </tr>
                        </thead>
                        <tbody>
                          {bannerPagination.items.map((banner) => (
                            <tr key={banner.id}>
                              <td className="banner-check-cell">
                                <input type="checkbox" />
                              </td>
                              <td>{banner.id}</td>
                              <td>
                                <img alt={banner.eventName} className="banner-thumb" src={banner.imageUrl} />
                              </td>
                              <td>{banner.eventName}</td>
                              <td>{banner.displayOrder}</td>
                              <td className="banner-link-cell">
                                <a href={banner.redirectLink} rel="noreferrer" target="_blank">
                                  {banner.redirectLink}
                                </a>
                              </td>
                              <td>
                                <span className={`status-chip ${banner.published ? 'published' : 'draft'}`}>
                                  {banner.published ? '\u516c\u958b' : '\u672a\u516c\u958b'}
                                </span>
                              </td>
                              <td>
                                <div className="banner-row-actions">
                                  <button className="icon-button" onClick={() => openEditBannerModal(banner)} type="button">
                                    {'\u270e'}
                                  </button>
                                  <button className="icon-button ghost" type="button">
                                    {'\ud83d\uddd1'}
                                  </button>
                                </div>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>

                    <div className="banner-pagination">
                      <span>
                        {filteredBanners.length} {'\u4ef6\u4e2d'}{' '}
                        {bannerPagination.items.length == 0
                          ? 0
                          : (bannerPagination.page - 1) * bannerPageSize + 1}{' '}
                        ~{' '}
                        {Math.min(
                          filteredBanners.length,
                          (bannerPagination.page - 1) * bannerPageSize +
                            bannerPagination.items.length,
                        )}{' '}
                        {'\u4ef6\u3092\u8868\u793a'}
                      </span>
                      <div className="banner-pagination-controls">
                        <button
                          className="ghost banner-page-button"
                          disabled={bannerPagination.page <= 1}
                          onClick={() =>
                            setBannerCurrentPage((page) => Math.max(1, page - 1))
                          }
                          type="button"
                        >
                          {'<'}
                        </button>
                        <span className="banner-page-current">{bannerPagination.page}</span>
                        <button
                          className="ghost banner-page-button"
                          disabled={bannerPagination.page >= bannerPagination.totalPages}
                          onClick={() =>
                            setBannerCurrentPage((page) =>
                              Math.min(bannerPagination.totalPages, page + 1),
                            )
                          }
                          type="button"
                        >
                          {'>'}
                        </button>
                        <label className="banner-page-size">
                          <select
                            onChange={(event) => {
                              setBannerPageSize(Number(event.target.value));
                              setBannerCurrentPage(1);
                            }}
                            value={bannerPageSize}
                          >
                            {pageSizeOptions.map((option) => (
                              <option key={option} value={option}>
                                {option}件 / ページ
                              </option>
                            ))}
                          </select>
                        </label>
                      </div>
                    </div>
                  </>
                )}
                </div>
              )}
            </section>
          </>
        ) : activeMenu === 'report' ? (
          <>
            <section className="content-grid user-list-layout">
              <div className="panel report-panel">
                <div className="panel-header panel-header-right banner-toolbar">
                  <div className="inline-actions banner-toolbar-actions">
                    <label className="banner-search">
                      <input
                        onChange={(event) => {
                          setReportSearch(event.target.value);
                          setReportCurrentPage(1);
                        }}
                        placeholder={'\u691c\u7d22'}
                        type="search"
                        value={reportSearch}
                      />
                    </label>
                  </div>
                </div>

                {message ? <div className="notice">{message}</div> : null}

                {loadingReports ? (
                  <p className="muted">Loading reports...</p>
                ) : filteredReports.length === 0 ? (
                  <p className="muted">No reports found yet.</p>
                ) : (
                  <>
                    <div className="table-wrap fixed-list-wrap report-table-wrap">
                      <table className="user-table report-table">
                        <thead>
                          <tr>
                            <th>ID</th>
                            <th>{'\u901a\u5831\u3055\u308c\u305f\u30e6\u30fc\u30b6\u30fc'}</th>
                            <th>{'\u901a\u5831\u3057\u305f\u30e6\u30fc\u30b6\u30fc'}</th>
                            <th>{'\u65e5\u6642'}</th>
                            <th>{'\u901a\u5831\u5185\u5bb9'}</th>
                            <th>{'BAN\u72b6\u614b'}</th>
                            <th>{'\u78ba\u8a8d\u72b6\u614b'}</th>
                          </tr>
                        </thead>
                        <tbody>
                          {reportPagination.items.map((report) => (
                            <tr key={report.id}>
                              <td>
                                <code>{report.id}</code>
                              </td>
                              <td>{report.reportedUserName}</td>
                              <td>{report.latestReporterName}</td>
                              <td>{formatDateTime(report.latestReportedAt)}</td>
                              <td className="report-reason-cell">
                                <p title={report.latestReason}>{truncateReason(report.latestReason)}</p>
                                <button
                                  className="ghost report-more-button"
                                  onClick={() => setSelectedReportSummary(report)}
                                  type="button"
                                >
                                  {'\u3082\u3063\u3068\u898b\u308b'}
                                </button>
                              </td>
                              <td>
                                <span className="report-switch" aria-hidden="true">
                                  <span />
                                </span>
                              </td>
                              <td>
                                <span className="status-chip draft">{'\u672a\u78ba\u8a8d'}</span>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>

                    <div className="banner-pagination">
                      <span>
                        {filteredReports.length} {'\u4ef6\u4e2d'}{' '}
                        {reportPagination.items.length === 0
                          ? 0
                          : (reportPagination.page - 1) * reportPageSize + 1}{' '}
                        ~{' '}
                        {Math.min(
                          filteredReports.length,
                          (reportPagination.page - 1) * reportPageSize + reportPagination.items.length,
                        )}{' '}
                        {'\u4ef6\u3092\u8868\u793a'}
                      </span>
                      <div className="banner-pagination-controls">
                        <button
                          className="ghost banner-page-button"
                          disabled={reportPagination.page <= 1}
                          onClick={() => setReportCurrentPage((page) => Math.max(1, page - 1))}
                          type="button"
                        >
                          {'<'}
                        </button>
                        <span className="banner-page-current">{reportPagination.page}</span>
                        <button
                          className="ghost banner-page-button"
                          disabled={reportPagination.page >= reportPagination.totalPages}
                          onClick={() =>
                            setReportCurrentPage((page) =>
                              Math.min(reportPagination.totalPages, page + 1),
                            )
                          }
                          type="button"
                        >
                          {'>'}
                        </button>
                        <label className="banner-page-size">
                          <select
                            onChange={(event) => {
                              setReportPageSize(Number(event.target.value));
                              setReportCurrentPage(1);
                            }}
                            value={reportPageSize}
                          >
                            {pageSizeOptions.map((option) => (
                              <option key={option} value={option}>
                                {option}件 / ページ
                              </option>
                            ))}
                          </select>
                        </label>
                      </div>
                    </div>
                  </>
                )}
              </div>
            </section>
          </>
        ) : (
          renderPlaceholderView(activeMenu)
        )}

        {selectedReportSummary ? (
          <div className="modal-backdrop" onClick={() => setSelectedReportSummary(null)} role="presentation">
            <div
              className="modal-panel report-detail-modal"
              onClick={(event) => event.stopPropagation()}
              role="dialog"
              aria-modal="true"
            >
              <div className="panel-header">
                <div>
                  <h2>{selectedReportSummary.reportedUserName}</h2>
                  <p className="muted">
                    {selectedReportSummary.reports.length} {'\u4ef6\u306e\u901a\u5831'}
                  </p>
                </div>
                <button className="ghost" onClick={() => setSelectedReportSummary(null)} type="button">
                  Close
                </button>
              </div>

              <div className="report-detail-list">
                {selectedReportSummary.reports.map((report) => (
                  <article className="report-detail-item" key={report.id}>
                    <div className="report-detail-meta">
                      <strong>{report.reporterUserName}</strong>
                      <span>{formatDateTime(report.createdAt)}</span>
                    </div>
                    <p>{report.reason}</p>
                  </article>
                ))}
              </div>
            </div>
          </div>
        ) : null}

        {selectedChatRoom ? (
          <div className="modal-backdrop" onClick={() => setSelectedChatRoom(null)} role="presentation">
            <div className="modal-panel chat-detail-modal" onClick={(event) => event.stopPropagation()} role="dialog" aria-modal="true">
              <div className="panel-header chat-detail-header">
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

              <div className="chat-detail-thread-wrap">
                <div className="chat-detail-thread" ref={chatThreadRef}>
                  {selectedChatRoom.messages.map((chat) => {
                    const isAdminMessage = chat.senderId === adminUser?.id;
                    return (
                      <article
                        className={`chat-detail-message ${isAdminMessage ? 'admin' : 'user'}`}
                        key={chat.id}
                      >
                        <div className="chat-detail-meta">
                          <strong>{chat.senderName}</strong>
                          <span>{chat.sentAt}</span>
                        </div>
                        <p>{chat.body}</p>
                      </article>
                    );
                  })}
                </div>
              </div>

              <div className="chat-detail-compose">
                <textarea
                  onChange={(event) => setChatMessageDraft(event.target.value)}
                  placeholder="Type a reply..."
                  rows={3}
                  value={chatMessageDraft}
                />
                <div className="chat-detail-compose-actions">
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

        {isFlowerModalOpen ? (
          <div className="modal-backdrop" onClick={closeFlowerModal} role="presentation">
            <div className="modal-panel" onClick={(event) => event.stopPropagation()} role="dialog" aria-modal="true">
              <div className="panel-header">
                <div>
                  <h2>{selectedFlowerId ? 'Edit flower' : '\u304a\u82b1\u6295\u7a3f'}</h2>
                  <p className="muted">Upload one image and register the flower details.</p>
                </div>
                <button className="ghost" onClick={closeFlowerModal} type="button">
                  Close
                </button>
              </div>

              <form className="user-form" onSubmit={(event) => void handleFlowerSubmit(event)}>
                <label className="full-span">
                  {'\u753b\u50cf\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9'}
                  <input accept="image/*" onChange={(event) => void handleFlowerImageChange(event)} type="file" />
                  {flowerForm.imageUrl ? (
                    <img alt="Flower preview" className="flower-preview" src={flowerForm.imageUrl} />
                  ) : null}
                </label>
                <label className="full-span">
                  {'\u82b1\u306e\u540d\u524d'}
                  <input
                    maxLength={50}
                    onChange={(event) => updateFlowerField('name', event.target.value)}
                    type="text"
                    value={flowerForm.name}
                  />
                  <small className="field-note">{flowerForm.name.length}/50</small>
                </label>
                <label className="full-span">
                  {'\u82b1\u306b\u3064\u3044\u3066'}
                  <textarea
                    maxLength={100}
                    onChange={(event) => updateFlowerField('description', event.target.value)}
                    rows={4}
                    value={flowerForm.description}
                  />
                  <small className="field-note">{flowerForm.description.length}/100</small>
                </label>
                <label className="full-span">
                  {'\u4fa1\u683c'}
                  <div className="price-stepper">
                    <button
                      className="ghost"
                      onClick={() => updateFlowerField('pricePoints', Math.max(1, flowerForm.pricePoints - 1))}
                      type="button"
                    >
                      -
                    </button>
                    <input
                      min={1}
                      onChange={(event) =>
                        updateFlowerField('pricePoints', Math.max(1, Number(event.target.value) || 1))
                      }
                      type="number"
                      value={flowerForm.pricePoints}
                    />
                    <span>P</span>
                    <button
                      className="ghost"
                      onClick={() => updateFlowerField('pricePoints', flowerForm.pricePoints + 1)}
                      type="button"
                    >
                      +
                    </button>
                  </div>
                </label>
                <fieldset className="full-span publish-fieldset">
                  <legend>{'\u516c\u958b\u72b6\u614b'}</legend>
                  <label className="radio-option">
                    <input
                      checked={flowerForm.published}
                      name="flower-publish"
                      onChange={() => updateFlowerField('published', true)}
                      type="radio"
                    />
                    {'\u516c\u958b'}
                  </label>
                  <label className="radio-option">
                    <input
                      checked={!flowerForm.published}
                      name="flower-publish"
                      onChange={() => updateFlowerField('published', false)}
                      type="radio"
                    />
                    {'\u975e\u516c\u958b'}
                  </label>
                </fieldset>
                <div className="form-actions full-span">
                  <button className="ghost" onClick={closeFlowerModal} type="button">
                    Cancel
                  </button>
                  <button disabled={savingFlower} type="submit">
                    {savingFlower ? 'Saving...' : '\u6295\u7a3f'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        ) : null}

        {isBannerModalOpen ? (
          <div className="modal-backdrop" onClick={closeBannerModal} role="presentation">
            <div className="modal-panel" onClick={(event) => event.stopPropagation()} role="dialog" aria-modal="true">
              <div className="panel-header">
                <div>
                  <h2>{selectedBannerId ? 'Edit banner' : '\u65b0\u898f\u4f5c\u6210'}</h2>
                  <p className="muted">Create or update a banner item for the home carousel.</p>
                </div>
                <button className="ghost" onClick={closeBannerModal} type="button">
                  Close
                </button>
              </div>

              <form className="user-form" onSubmit={(event) => void handleBannerSubmit(event)}>
                <label className="full-span">
                  {'\u753b\u50cf\u30a2\u30c3\u30d7\u30ed\u30fc\u30c9'}
                  <input accept="image/*" onChange={(event) => void handleBannerImageChange(event)} type="file" />
                  {bannerForm.imageUrl ? (
                    <img alt="Banner preview" className="banner-preview" src={bannerForm.imageUrl} />
                  ) : null}
                </label>
                <label>
                  {'\u30a4\u30d9\u30f3\u30c8\u540d'}
                  <input
                    maxLength={100}
                    onChange={(event) => updateBannerField('eventName', event.target.value)}
                    type="text"
                    value={bannerForm.eventName}
                  />
                </label>
                <label>
                  {'\u8868\u793a\u9806'}
                  <input
                    min={0}
                    onChange={(event) =>
                      updateBannerField('displayOrder', Math.max(0, Number(event.target.value) || 0))
                    }
                    type="number"
                    value={bannerForm.displayOrder}
                  />
                </label>
                <label className="full-span">
                  {'\u518d\u7528\u30ea\u30f3\u30af'}
                  <input
                    onChange={(event) => updateBannerField('redirectLink', event.target.value)}
                    placeholder="https://example.com"
                    type="url"
                    value={bannerForm.redirectLink}
                  />
                </label>
                <fieldset className="full-span publish-fieldset">
                  <legend>{'\u72b6\u614b'}</legend>
                  <label className="radio-option">
                    <input
                      checked={bannerForm.published}
                      name="banner-publish"
                      onChange={() => updateBannerField('published', true)}
                      type="radio"
                    />
                    {'\u516c\u958b'}
                  </label>
                  <label className="radio-option">
                    <input
                      checked={!bannerForm.published}
                      name="banner-publish"
                      onChange={() => updateBannerField('published', false)}
                      type="radio"
                    />
                    {'\u672a\u516c\u958b'}
                  </label>
                </fieldset>
                <div className="form-actions full-span">
                  <button className="ghost" onClick={closeBannerModal} type="button">
                    Cancel
                  </button>
                  <button disabled={savingBanner} type="submit">
                    {savingBanner ? 'Saving...' : '\u65b0\u898f\u4f5c\u6210'}
                  </button>
                </div>
              </form>
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

function paginateItems<T>(items: T[], currentPage: number, pageSize: number) {
  const totalPages = Math.max(1, Math.ceil(items.length / pageSize));
  const page = Math.min(currentPage, totalPages);
  const start = (page - 1) * pageSize;
  return {
    items: items.slice(start, start + pageSize),
    page,
    totalPages,
  };
}

export default App;
