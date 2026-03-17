import 'package:flutter/material.dart';

import 'app_language.dart';
import 'app_language_controller.dart';

class AppLocalizationScope extends InheritedNotifier<AppLanguageController> {
  const AppLocalizationScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLanguageController controllerOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    assert(scope != null, 'AppLocalizationScope not found in context.');
    return scope!.notifier!;
  }

  static AppStrings stringsOf(BuildContext context) {
    final controller = controllerOf(context);
    return AppStrings(controller.language);
  }
}

extension AppStringsBuildContext on BuildContext {
  AppStrings get strings => AppLocalizationScope.stringsOf(this);
  AppLanguageController get languageController =>
      AppLocalizationScope.controllerOf(this);
}

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  static const Map<String, Map<AppLanguage, String>> _values = {
    'appTitle': {
      AppLanguage.vietnamese: 'Kimura Dating',
      AppLanguage.japanese: 'Kimura Dating',
      AppLanguage.korean: 'Kimura Dating',
      AppLanguage.russian: 'Kimura Dating',
      AppLanguage.chinese: 'Kimura Dating',
      AppLanguage.english: 'Kimura Dating',
      AppLanguage.thai: 'Kimura Dating',
    },
    'changeLanguage': {
      AppLanguage.vietnamese: 'Đổi ngôn ngữ',
      AppLanguage.japanese: 'Change language',
      AppLanguage.korean: 'Change language',
      AppLanguage.russian: 'Change language',
      AppLanguage.chinese: 'Change language',
      AppLanguage.english: 'Change language',
      AppLanguage.thai: 'Change language',
    },
    'loginTitle': {
      AppLanguage.vietnamese: 'Đăng nhập',
      AppLanguage.japanese: 'ログイン',
      AppLanguage.korean: '로그인',
      AppLanguage.russian: 'Вход',
      AppLanguage.chinese: '登录',
      AppLanguage.english: 'Login',
      AppLanguage.thai: 'เข้าสู่ระบบ',
    },
    'loginSubtitle': {
      AppLanguage.vietnamese:
          'Vui lòng đăng nhập bằng email và mật khẩu.',
      AppLanguage.japanese: 'メールアドレスとパスワードでログインしてください',
      AppLanguage.korean: '이메일 주소와 비밀번호로 로그인해 주세요',
      AppLanguage.russian: 'Войдите, используя адрес электронной почты и пароль',
      AppLanguage.chinese: '请使用邮箱地址和密码登录',
      AppLanguage.english: 'Please log in with your email address and password.',
      AppLanguage.thai: 'กรุณาเข้าสู่ระบบด้วยอีเมลและรหัสผ่าน',
    },
    'emailLabel': {
      AppLanguage.vietnamese: 'Email',
      AppLanguage.japanese: 'メールアドレス',
      AppLanguage.korean: '이메일 주소',
      AppLanguage.russian: 'Электронная почта',
      AppLanguage.chinese: '邮箱地址',
      AppLanguage.english: 'Email address',
      AppLanguage.thai: 'อีเมล',
    },
    'emailPlaceholder': {
      AppLanguage.vietnamese: 'Nhập email',
      AppLanguage.japanese: 'メールアドレスを入力',
      AppLanguage.korean: '이메일 주소를 입력',
      AppLanguage.russian: 'Введите адрес электронной почты',
      AppLanguage.chinese: '请输入邮箱地址',
      AppLanguage.english: 'Enter your email address',
      AppLanguage.thai: 'กรอกอีเมล',
    },
    'emailRequired': {
      AppLanguage.vietnamese: 'Vui lòng nhập email',
      AppLanguage.japanese: 'メールアドレスを入力してください',
      AppLanguage.korean: '이메일 주소를 입력해 주세요',
      AppLanguage.russian: 'Введите адрес электронной почты',
      AppLanguage.chinese: '请输入邮箱地址',
      AppLanguage.english: 'Please enter your email address',
      AppLanguage.thai: 'กรุณากรอกอีเมล',
    },
    'emailInvalid': {
      AppLanguage.vietnamese: 'Vui lòng nhập email hợp lệ',
      AppLanguage.japanese: '有効なメールアドレスを入力してください',
      AppLanguage.korean: '유효한 이메일 주소를 입력해 주세요',
      AppLanguage.russian: 'Введите корректный адрес электронной почты',
      AppLanguage.chinese: '请输入有效的邮箱地址',
      AppLanguage.english: 'Please enter a valid email address',
      AppLanguage.thai: 'กรุณากรอกอีเมลที่ถูกต้อง',
    },
    'passwordLabel': {
      AppLanguage.vietnamese: 'Mật khẩu',
      AppLanguage.japanese: 'パスワード',
      AppLanguage.korean: '비밀번호',
      AppLanguage.russian: 'Пароль',
      AppLanguage.chinese: '密码',
      AppLanguage.english: 'Password',
      AppLanguage.thai: 'รหัสผ่าน',
    },
    'passwordPlaceholder': {
      AppLanguage.vietnamese: 'Nhập mật khẩu',
      AppLanguage.japanese: 'パスワードを入力',
      AppLanguage.korean: '비밀번호를 입력',
      AppLanguage.russian: 'Введите пароль',
      AppLanguage.chinese: '请输入密码',
      AppLanguage.english: 'Enter your password',
      AppLanguage.thai: 'กรอกรหัสผ่าน',
    },
    'passwordRequired': {
      AppLanguage.vietnamese: 'Vui lòng nhập mật khẩu',
      AppLanguage.japanese: 'パスワードを入力してください',
      AppLanguage.korean: '비밀번호를 입력해 주세요',
      AppLanguage.russian: 'Введите пароль',
      AppLanguage.chinese: '请输入密码',
      AppLanguage.english: 'Please enter your password',
      AppLanguage.thai: 'กรุณากรอกรหัสผ่าน',
    },
    'rememberLogin': {
      AppLanguage.vietnamese: 'Ghi nhớ thông tin đăng nhập',
      AppLanguage.japanese: 'ログイン情報を記憶する',
      AppLanguage.korean: '로그인 정보를 기억하기',
      AppLanguage.russian: 'Запомнить данные входа',
      AppLanguage.chinese: '记住登录信息',
      AppLanguage.english: 'Remember login info',
      AppLanguage.thai: 'จดจำข้อมูลการเข้าสู่ระบบ',
    },
    'loginButton': {
      AppLanguage.vietnamese: 'Đăng nhập',
      AppLanguage.japanese: 'ログイン',
      AppLanguage.korean: '로그인',
      AppLanguage.russian: 'Войти',
      AppLanguage.chinese: '登录',
      AppLanguage.english: 'Login',
      AppLanguage.thai: 'เข้าสู่ระบบ',
    },
    'signingIn': {
      AppLanguage.vietnamese: 'Đang đăng nhập...',
      AppLanguage.japanese: 'ログイン中...',
      AppLanguage.korean: '로그인 중...',
      AppLanguage.russian: 'Выполняется вход...',
      AppLanguage.chinese: '登录中...',
      AppLanguage.english: 'Signing in...',
      AppLanguage.thai: 'กำลังเข้าสู่ระบบ...',
    },
    'discoverTitle': {
      AppLanguage.vietnamese: 'Kimura',
      AppLanguage.japanese: 'Kimura',
      AppLanguage.korean: 'Kimura',
      AppLanguage.russian: 'Kimura',
      AppLanguage.chinese: 'Kimura',
      AppLanguage.english: 'Kimura',
      AppLanguage.thai: 'Kimura',
    },
    'discoverSubtitle': {
      AppLanguage.vietnamese: 'Tìm những người bạn thực sự muốn trò chuyện.',
      AppLanguage.japanese: '本当に話したい相手を見つけましょう。',
      AppLanguage.korean: '정말 대화하고 싶은 사람을 찾아보세요.',
      AppLanguage.russian: 'Найдите людей, с которыми вам действительно хочется говорить.',
      AppLanguage.chinese: '找到你真正想聊天的人。',
      AppLanguage.english: 'Find people you actually want to talk to.',
      AppLanguage.thai: 'พบคนที่คุณอยากคุยด้วยจริงๆ',
    },
    'cannotLoadProfiles': {
      AppLanguage.vietnamese: 'Không thể tải hồ sơ',
      AppLanguage.japanese: 'プロフィールを読み込めません',
      AppLanguage.korean: '프로필을 불러올 수 없습니다',
      AppLanguage.russian: 'Не удалось загрузить профили',
      AppLanguage.chinese: '无法加载资料',
      AppLanguage.english: 'Cannot load profiles',
      AppLanguage.thai: 'ไม่สามารถโหลดโปรไฟล์ได้',
    },
    'noProfilesYet': {
      AppLanguage.vietnamese: 'Chưa có hồ sơ nào',
      AppLanguage.japanese: 'まだプロフィールがありません',
      AppLanguage.korean: '아직 프로필이 없습니다',
      AppLanguage.russian: 'Профилей пока нет',
      AppLanguage.chinese: '暂无资料',
      AppLanguage.english: 'No profiles yet',
      AppLanguage.thai: 'ยังไม่มีโปรไฟล์',
    },
    'matchesTitle': {
      AppLanguage.vietnamese: 'Ghép đôi',
      AppLanguage.japanese: 'マッチ一覧',
      AppLanguage.korean: '매칭 목록',
      AppLanguage.russian: 'Совпадения',
      AppLanguage.chinese: '配对列表',
      AppLanguage.english: 'Matches',
      AppLanguage.thai: 'แมตช์',
    },
    'cannotLoadMatches': {
      AppLanguage.vietnamese: 'Không thể tải danh sách ghép đôi',
      AppLanguage.japanese: 'マッチ一覧を読み込めません',
      AppLanguage.korean: '매칭 목록을 불러올 수 없습니다',
      AppLanguage.russian: 'Не удалось загрузить список совпадений',
      AppLanguage.chinese: '无法加载配对列表',
      AppLanguage.english: 'Cannot load matches',
      AppLanguage.thai: 'ไม่สามารถโหลดรายการแมตช์ได้',
    },
    'myPageTitle': {
      AppLanguage.vietnamese: 'Trang cá nhân',
      AppLanguage.japanese: 'マイページ',
      AppLanguage.korean: '마이페이지',
      AppLanguage.russian: 'Моя страница',
      AppLanguage.chinese: '我的页面',
      AppLanguage.english: 'My page',
      AppLanguage.thai: 'หน้าของฉัน',
    },
    'myPageSubtitle': {
      AppLanguage.vietnamese: 'Bạn đang đăng nhập với',
      AppLanguage.japanese: '現在ログインしているアカウント',
      AppLanguage.korean: '현재 로그인한 계정',
      AppLanguage.russian: 'Текущая учетная запись',
      AppLanguage.chinese: '当前登录账号',
      AppLanguage.english: 'Currently signed in account',
      AppLanguage.thai: 'บัญชีที่เข้าสู่ระบบอยู่',
    },
    'displayName': {
      AppLanguage.vietnamese: 'Tên hiển thị',
      AppLanguage.japanese: '表示名',
      AppLanguage.korean: '표시 이름',
      AppLanguage.russian: 'Отображаемое имя',
      AppLanguage.chinese: '显示名称',
      AppLanguage.english: 'Display name',
      AppLanguage.thai: 'ชื่อที่แสดง',
    },
    'age': {
      AppLanguage.vietnamese: 'Tuổi',
      AppLanguage.japanese: '年齢',
      AppLanguage.korean: '나이',
      AppLanguage.russian: 'Возраст',
      AppLanguage.chinese: '年龄',
      AppLanguage.english: 'Age',
      AppLanguage.thai: 'อายุ',
    },
    'job': {
      AppLanguage.vietnamese: 'Nghề nghiệp',
      AppLanguage.japanese: '職業',
      AppLanguage.korean: '직업',
      AppLanguage.russian: 'Профессия',
      AppLanguage.chinese: '职业',
      AppLanguage.english: 'Job',
      AppLanguage.thai: 'อาชีพ',
    },
    'distance': {
      AppLanguage.vietnamese: 'Khoảng cách',
      AppLanguage.japanese: '距離',
      AppLanguage.korean: '거리',
      AppLanguage.russian: 'Расстояние',
      AppLanguage.chinese: '距离',
      AppLanguage.english: 'Distance',
      AppLanguage.thai: 'ระยะทาง',
    },
    'bio': {
      AppLanguage.vietnamese: 'Giới thiệu',
      AppLanguage.japanese: '自己紹介',
      AppLanguage.korean: '자기소개',
      AppLanguage.russian: 'О себе',
      AppLanguage.chinese: '自我介绍',
      AppLanguage.english: 'Bio',
      AppLanguage.thai: 'แนะนำตัว',
    },
    'interests': {
      AppLanguage.vietnamese: 'Sở thích',
      AppLanguage.japanese: '興味・関心',
      AppLanguage.korean: '관심사',
      AppLanguage.russian: 'Интересы',
      AppLanguage.chinese: '兴趣爱好',
      AppLanguage.english: 'Interests',
      AppLanguage.thai: 'ความสนใจ',
    },
    'interestsHint': {
      AppLanguage.vietnamese: 'Du lịch, Âm nhạc, Cà phê',
      AppLanguage.japanese: '旅行, 音楽, コーヒー',
      AppLanguage.korean: '여행, 음악, 커피',
      AppLanguage.russian: 'Путешествия, Музыка, Кофе',
      AppLanguage.chinese: '旅行, 音乐, 咖啡',
      AppLanguage.english: 'Travel, Music, Coffee',
      AppLanguage.thai: 'ท่องเที่ยว, ดนตรี, กาแฟ',
    },
    'passwordKeepCurrent': {
      AppLanguage.vietnamese: 'Mật khẩu (để trống nếu giữ nguyên)',
      AppLanguage.japanese: 'パスワード（変更しない場合は空欄）',
      AppLanguage.korean: '비밀번호(변경하지 않으려면 비워두세요)',
      AppLanguage.russian: 'Пароль (оставьте пустым, чтобы не менять)',
      AppLanguage.chinese: '密码（如不修改请留空）',
      AppLanguage.english: 'Password (leave blank to keep current password)',
      AppLanguage.thai: 'รหัสผ่าน (เว้นว่างไว้หากไม่เปลี่ยน)',
    },
    'refreshToken': {
      AppLanguage.vietnamese: 'Làm mới token',
      AppLanguage.japanese: 'トークン更新',
      AppLanguage.korean: '토큰 새로고침',
      AppLanguage.russian: 'Обновить токен',
      AppLanguage.chinese: '刷新令牌',
      AppLanguage.english: 'Refresh token',
      AppLanguage.thai: 'รีเฟรชโทเค็น',
    },
    'editUser': {
      AppLanguage.vietnamese: 'Cập nhật hồ sơ',
      AppLanguage.japanese: 'ユーザー更新',
      AppLanguage.korean: '사용자 수정',
      AppLanguage.russian: 'Обновить профиль',
      AppLanguage.chinese: '更新资料',
      AppLanguage.english: 'Edit user',
      AppLanguage.thai: 'แก้ไขผู้ใช้',
    },
    'deleteUser': {
      AppLanguage.vietnamese: 'Xóa tài khoản',
      AppLanguage.japanese: 'ユーザー削除',
      AppLanguage.korean: '사용자 삭제',
      AppLanguage.russian: 'Удалить аккаунт',
      AppLanguage.chinese: '删除账号',
      AppLanguage.english: 'Delete user',
      AppLanguage.thai: 'ลบผู้ใช้',
    },
    'logout': {
      AppLanguage.vietnamese: 'Đăng xuất',
      AppLanguage.japanese: 'ログアウト',
      AppLanguage.korean: '로그아웃',
      AppLanguage.russian: 'Выйти',
      AppLanguage.chinese: '退出登录',
      AppLanguage.english: 'Logout',
      AppLanguage.thai: 'ออกจากระบบ',
    },
    'discoverTab': {
      AppLanguage.vietnamese: 'Khám phá',
      AppLanguage.japanese: '探す',
      AppLanguage.korean: '둘러보기',
      AppLanguage.russian: 'Поиск',
      AppLanguage.chinese: '发现',
      AppLanguage.english: 'Discover',
      AppLanguage.thai: 'ค้นหา',
    },
    'matchesTab': {
      AppLanguage.vietnamese: 'Ghép đôi',
      AppLanguage.japanese: 'マッチ',
      AppLanguage.korean: '매칭',
      AppLanguage.russian: 'Совпадения',
      AppLanguage.chinese: '配对',
      AppLanguage.english: 'Matches',
      AppLanguage.thai: 'แมตช์',
    },
    'myPageTab': {
      AppLanguage.vietnamese: 'Trang tôi',
      AppLanguage.japanese: 'マイページ',
      AppLanguage.korean: '마이페이지',
      AppLanguage.russian: 'Моя страница',
      AppLanguage.chinese: '我的页面',
      AppLanguage.english: 'My page',
      AppLanguage.thai: 'หน้าของฉัน',
    },
    'retry': {
      AppLanguage.vietnamese: 'Thử lại',
      AppLanguage.japanese: '再試行',
      AppLanguage.korean: '다시 시도',
      AppLanguage.russian: 'Повторить',
      AppLanguage.chinese: '重试',
      AppLanguage.english: 'Retry',
      AppLanguage.thai: 'ลองอีกครั้ง',
    },
    'skip': {
      AppLanguage.vietnamese: 'Bỏ qua',
      AppLanguage.japanese: 'スキップ',
      AppLanguage.korean: '건너뛰기',
      AppLanguage.russian: 'Пропустить',
      AppLanguage.chinese: '跳过',
      AppLanguage.english: 'Skip',
      AppLanguage.thai: 'ข้าม',
    },
    'like': {
      AppLanguage.vietnamese: 'Thích',
      AppLanguage.japanese: 'いいね',
      AppLanguage.korean: '좋아요',
      AppLanguage.russian: 'Нравится',
      AppLanguage.chinese: '喜欢',
      AppLanguage.english: 'Like',
      AppLanguage.thai: 'ถูกใจ',
    },
    'loginSuccessful': {
      AppLanguage.vietnamese: 'Đăng nhập thành công.',
      AppLanguage.japanese: 'ログインしました。',
      AppLanguage.korean: '로그인되었습니다.',
      AppLanguage.russian: 'Вход выполнен успешно.',
      AppLanguage.chinese: '登录成功。',
      AppLanguage.english: 'Login successful.',
      AppLanguage.thai: 'เข้าสู่ระบบสำเร็จ',
    },
    'noRefreshToken': {
      AppLanguage.vietnamese: 'Không có refresh token. Vui lòng đăng nhập lại.',
      AppLanguage.japanese: 'リフレッシュトークンがありません。再度ログインしてください。',
      AppLanguage.korean: '리프레시 토큰이 없습니다. 다시 로그인해 주세요.',
      AppLanguage.russian: 'Отсутствует refresh token. Пожалуйста, войдите снова.',
      AppLanguage.chinese: '没有刷新令牌。请重新登录。',
      AppLanguage.english: 'No refresh token available. Please login again.',
      AppLanguage.thai: 'ไม่มีรีเฟรชโทเค็น กรุณาเข้าสู่ระบบอีกครั้ง',
    },
    'sessionRefreshed': {
      AppLanguage.vietnamese: 'Làm mới phiên thành công.',
      AppLanguage.japanese: 'セッションを更新しました。',
      AppLanguage.korean: '세션이 새로고침되었습니다.',
      AppLanguage.russian: 'Сессия успешно обновлена.',
      AppLanguage.chinese: '会话刷新成功。',
      AppLanguage.english: 'Session refreshed successfully.',
      AppLanguage.thai: 'รีเฟรชเซสชันสำเร็จ',
    },
    'loginBeforeUpdate': {
      AppLanguage.vietnamese: 'Vui lòng đăng nhập trước khi cập nhật.',
      AppLanguage.japanese: '更新する前にログインしてください。',
      AppLanguage.korean: '수정하기 전에 먼저 로그인해 주세요.',
      AppLanguage.russian: 'Пожалуйста, войдите перед обновлением.',
      AppLanguage.chinese: '更新前请先登录。',
      AppLanguage.english: 'Please login first before updating.',
      AppLanguage.thai: 'กรุณาเข้าสู่ระบบก่อนอัปเดต',
    },
    'profileUpdated': {
      AppLanguage.vietnamese: 'Cập nhật hồ sơ thành công.',
      AppLanguage.japanese: 'プロフィールを更新しました。',
      AppLanguage.korean: '프로필이 업데이트되었습니다.',
      AppLanguage.russian: 'Профиль успешно обновлен.',
      AppLanguage.chinese: '资料更新成功。',
      AppLanguage.english: 'Profile updated successfully.',
      AppLanguage.thai: 'อัปเดตโปรไฟล์สำเร็จ',
    },
    'loginBeforeDelete': {
      AppLanguage.vietnamese: 'Vui lòng đăng nhập trước khi xóa.',
      AppLanguage.japanese: '削除する前にログインしてください。',
      AppLanguage.korean: '삭제하기 전에 먼저 로그인해 주세요.',
      AppLanguage.russian: 'Пожалуйста, войдите перед удалением.',
      AppLanguage.chinese: '删除前请先登录。',
      AppLanguage.english: 'Please login first before deleting.',
      AppLanguage.thai: 'กรุณาเข้าสู่ระบบก่อนลบ',
    },
    'accountDeleted': {
      AppLanguage.vietnamese: 'Xóa tài khoản thành công.',
      AppLanguage.japanese: 'アカウントを削除しました。',
      AppLanguage.korean: '계정이 삭제되었습니다.',
      AppLanguage.russian: 'Аккаунт успешно удален.',
      AppLanguage.chinese: '账号删除成功。',
      AppLanguage.english: 'Account deleted successfully.',
      AppLanguage.thai: 'ลบบัญชีสำเร็จ',
    },
    'loggedOutSuccessfully': {
      AppLanguage.vietnamese: 'Đăng xuất thành công.',
      AppLanguage.japanese: 'ログアウトしました。',
      AppLanguage.korean: '로그아웃되었습니다.',
      AppLanguage.russian: 'Выход выполнен успешно.',
      AppLanguage.chinese: '退出登录成功。',
      AppLanguage.english: 'Logged out successfully.',
      AppLanguage.thai: 'ออกจากระบบสำเร็จ',
    },
    'loggedOut': {
      AppLanguage.vietnamese: 'Đã đăng xuất.',
      AppLanguage.japanese: 'ログアウトしました。',
      AppLanguage.korean: '로그아웃되었습니다.',
      AppLanguage.russian: 'Вы вышли из системы.',
      AppLanguage.chinese: '已退出登录。',
      AppLanguage.english: 'Logged out.',
      AppLanguage.thai: 'ออกจากระบบแล้ว',
    },
    'sessionRestored': {
      AppLanguage.vietnamese: 'Khôi phục phiên thành công.',
      AppLanguage.japanese: 'セッションを復元しました。',
      AppLanguage.korean: '세션이 복원되었습니다.',
      AppLanguage.russian: 'Сессия восстановлена.',
      AppLanguage.chinese: '会话已恢复。',
      AppLanguage.english: 'Session restored successfully.',
      AppLanguage.thai: 'กู้คืนเซสชันสำเร็จ',
    },
    'matchStatusNew': {
      AppLanguage.vietnamese: 'Mới',
      AppLanguage.japanese: '新着',
      AppLanguage.korean: '신규',
      AppLanguage.russian: 'Новое',
      AppLanguage.chinese: '新消息',
      AppLanguage.english: 'New',
      AppLanguage.thai: 'ใหม่',
    },
  };

  String _text(String key) => _values[key]![language]!;

  String get appTitle => _text('appTitle');
  String get changeLanguage => _text('changeLanguage');
  String get loginTitle => _text('loginTitle');
  String get loginSubtitle => _text('loginSubtitle');
  String get emailLabel => _text('emailLabel');
  String get emailPlaceholder => _text('emailPlaceholder');
  String get emailRequired => _text('emailRequired');
  String get emailInvalid => _text('emailInvalid');
  String get passwordLabel => _text('passwordLabel');
  String get passwordPlaceholder => _text('passwordPlaceholder');
  String get passwordRequired => _text('passwordRequired');
  String get rememberLogin => _text('rememberLogin');
  String get loginButton => _text('loginButton');
  String get signingIn => _text('signingIn');
  String get discoverTitle => _text('discoverTitle');
  String get discoverSubtitle => _text('discoverSubtitle');
  String get cannotLoadProfiles => _text('cannotLoadProfiles');
  String get noProfilesYet => _text('noProfilesYet');
  String get matchesTitle => _text('matchesTitle');
  String get cannotLoadMatches => _text('cannotLoadMatches');
  String get myPageTitle => _text('myPageTitle');
  String get myPageSubtitle => _text('myPageSubtitle');
  String get displayName => _text('displayName');
  String get age => _text('age');
  String get job => _text('job');
  String get distance => _text('distance');
  String get bio => _text('bio');
  String get interests => _text('interests');
  String get interestsHint => _text('interestsHint');
  String get passwordKeepCurrent => _text('passwordKeepCurrent');
  String get refreshToken => _text('refreshToken');
  String get editUser => _text('editUser');
  String get deleteUser => _text('deleteUser');
  String get logout => _text('logout');
  String get discoverTab => _text('discoverTab');
  String get matchesTab => _text('matchesTab');
  String get myPageTab => _text('myPageTab');
  String get retry => _text('retry');
  String get skip => _text('skip');
  String get like => _text('like');
  String get loginSuccessful => _text('loginSuccessful');
  String get noRefreshToken => _text('noRefreshToken');
  String get sessionRefreshed => _text('sessionRefreshed');
  String get loginBeforeUpdate => _text('loginBeforeUpdate');
  String get profileUpdated => _text('profileUpdated');
  String get loginBeforeDelete => _text('loginBeforeDelete');
  String get accountDeleted => _text('accountDeleted');
  String get loggedOutSuccessfully => _text('loggedOutSuccessfully');
  String get loggedOut => _text('loggedOut');
  String get sessionRestored => _text('sessionRestored');

  String matchStatus(String status) {
    if (status.toLowerCase() == 'new') {
      return _text('matchStatusNew');
    }
    return status;
  }
}
