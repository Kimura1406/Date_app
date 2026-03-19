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
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
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
      AppLanguage.vietnamese: 'Vui lòng đăng nhập bằng email và mật khẩu.',
      AppLanguage.japanese: 'メールアドレスとパスワードでログインしてください',
      AppLanguage.korean: '이메일 주소와 비밀번호로 로그인해 주세요',
      AppLanguage.russian:
          'Войдите, используя адрес электронной почты и пароль',
      AppLanguage.chinese: '请使用邮箱地址和密码登录',
      AppLanguage.english:
          'Please log in with your email address and password.',
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
      AppLanguage.russian:
          'Найдите людей, с которыми вам действительно хочется говорить.',
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
      AppLanguage.russian:
          'Отсутствует refresh token. Пожалуйста, войдите снова.',
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
  String get commentsLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Bình luận';
      case AppLanguage.japanese:
        return 'コメント';
      case AppLanguage.korean:
        return '댓글';
      case AppLanguage.russian:
        return 'Комментарии';
      case AppLanguage.chinese:
        return '评论';
      case AppLanguage.english:
        return 'Comments';
      case AppLanguage.thai:
        return 'ความคิดเห็น';
    }
  }

  String get giftsLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Quà tặng';
      case AppLanguage.japanese:
        return 'ギフト';
      case AppLanguage.korean:
        return '선물';
      case AppLanguage.russian:
        return 'Подарки';
      case AppLanguage.chinese:
        return '礼物';
      case AppLanguage.english:
        return 'Gifts';
      case AppLanguage.thai:
        return 'ของขวัญ';
    }
  }

  String get postsSectionTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Bài đăng';
      case AppLanguage.japanese:
        return '投稿';
      case AppLanguage.korean:
        return '게시물';
      case AppLanguage.russian:
        return 'Публикации';
      case AppLanguage.chinese:
        return '帖子';
      case AppLanguage.english:
        return 'Posts';
      case AppLanguage.thai:
        return 'โพสต์';
    }
  }

  String get birthYearLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Năm sinh';
      case AppLanguage.japanese:
        return '生年';
      case AppLanguage.korean:
        return '출생 연도';
      case AppLanguage.russian:
        return 'Год рождения';
      case AppLanguage.chinese:
        return '出生年份';
      case AppLanguage.english:
        return 'Birth year';
      case AppLanguage.thai:
        return 'ปีเกิด';
    }
  }

  String get genderProfileLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Giới tính';
      case AppLanguage.japanese:
        return '性別';
      case AppLanguage.korean:
        return '성별';
      case AppLanguage.russian:
        return 'Пол';
      case AppLanguage.chinese:
        return '性别';
      case AppLanguage.english:
        return 'Gender';
      case AppLanguage.thai:
        return 'เพศ';
    }
  }

  String get likesCountLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Lượt thích';
      case AppLanguage.japanese:
        return 'いいね数';
      case AppLanguage.korean:
        return '좋아요 수';
      case AppLanguage.russian:
        return 'Лайки';
      case AppLanguage.chinese:
        return '点赞数';
      case AppLanguage.english:
        return 'Likes';
      case AppLanguage.thai:
        return 'จำนวนไลก์';
    }
  }

  String get chatButtonLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chat';
      case AppLanguage.japanese:
        return 'チャット';
      case AppLanguage.korean:
        return '채팅';
      case AppLanguage.russian:
        return 'Чат';
      case AppLanguage.chinese:
        return '聊天';
      case AppLanguage.english:
        return 'Chat';
      case AppLanguage.thai:
        return 'แชต';
    }
  }

  String get chatOnlineStatus {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Đang hoạt động';
      case AppLanguage.japanese:
        return 'オンライン';
      case AppLanguage.korean:
        return '온라인';
      case AppLanguage.russian:
        return 'В сети';
      case AppLanguage.chinese:
        return '在线';
      case AppLanguage.english:
        return 'Online';
      case AppLanguage.thai:
        return 'ออนไลน์';
    }
  }

  String get chatInputPlaceholder {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Nhập tin nhắn';
      case AppLanguage.japanese:
        return 'メッセージを入力';
      case AppLanguage.korean:
        return '메시지를 입력하세요';
      case AppLanguage.russian:
        return 'Введите сообщение';
      case AppLanguage.chinese:
        return '输入消息';
      case AppLanguage.english:
        return 'Type a message';
      case AppLanguage.thai:
        return 'พิมพ์ข้อความ';
    }
  }

  String chatGreeting(String name) {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chào bạn, mình là $name. Rất vui được nói chuyện với bạn ở đây.';
      case AppLanguage.japanese:
        return 'こんにちは、$nameです。ここでお話しできてうれしいです。';
      case AppLanguage.korean:
        return '안녕하세요, 저는 $name예요. 여기서 이야기하게 되어 반가워요.';
      case AppLanguage.russian:
        return 'Привет, я $name. Рада познакомиться и пообщаться здесь.';
      case AppLanguage.chinese:
        return '你好，我是$name。很高兴能在这里和你聊天。';
      case AppLanguage.english:
        return 'Hi, I am $name. Happy to chat with you here.';
      case AppLanguage.thai:
        return 'สวัสดี เราชื่อ $name ดีใจที่ได้คุยกันที่นี่';
    }
  }

  String chatReply(String name) {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chào $name, profile của bạn rất thú vị. Hôm nay bạn thế nào?';
      case AppLanguage.japanese:
        return '$nameさん、こんにちは。プロフィールがとても素敵ですね。今日はどうですか？';
      case AppLanguage.korean:
        return '$name님 안녕하세요. 프로필이 정말 멋져요. 오늘 하루는 어땠어요?';
      case AppLanguage.russian:
        return 'Привет, $name. У тебя очень интересный профиль. Как проходит твой день?';
      case AppLanguage.chinese:
        return '$name，你好。你的个人资料很有意思，今天过得怎么样？';
      case AppLanguage.english:
        return 'Hi $name, your profile looks great. How is your day going?';
      case AppLanguage.thai:
        return 'สวัสดี $name โปรไฟล์ของคุณน่าสนใจมาก วันนี้เป็นอย่างไรบ้าง';
    }
  }

  String get chatInviteMessage {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Nếu hợp thì cuối tuần mình có thể đi cà phê hoặc dạo phố cùng nhau.';
      case AppLanguage.japanese:
        return '気が合えば、週末にカフェやお散歩でもどうですか。';
      case AppLanguage.korean:
        return '잘 맞는다면 주말에 커피나 산책 같이 해도 좋을 것 같아요.';
      case AppLanguage.russian:
        return 'Если нам будет комфортно, на выходных можно сходить на кофе или прогуляться.';
      case AppLanguage.chinese:
        return '如果聊得合适，周末我们可以一起喝咖啡或者散步。';
      case AppLanguage.english:
        return 'If we click, maybe we can grab coffee or take a walk this weekend.';
      case AppLanguage.thai:
        return 'ถ้าเราคุยกันเข้ากันได้ สุดสัปดาห์นี้อาจไปกาแฟหรือเดินเล่นด้วยกันก็ได้';
    }
  }

  String get chatRoomsTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Phòng chat';
      case AppLanguage.japanese:
        return 'チャットルーム';
      case AppLanguage.korean:
        return '채팅방';
      case AppLanguage.russian:
        return 'Чаты';
      case AppLanguage.chinese:
        return '聊天室';
      case AppLanguage.english:
        return 'Chat rooms';
      case AppLanguage.thai:
        return 'ห้องแชต';
    }
  }

  String get chatRoomsSubtitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Theo dõi phòng hỗ trợ và các cuộc trò chuyện khác của bạn.';
      case AppLanguage.japanese:
        return '運営業者ルームと他のチャットルームをここで確認できます。';
      case AppLanguage.korean:
        return '운영자 방과 다른 대화를 여기에서 확인할 수 있습니다.';
      case AppLanguage.russian:
        return 'Здесь можно открыть комнату с оператором и другие чаты.';
      case AppLanguage.chinese:
        return '你可以在这里查看运营方聊天室和其他聊天。';
      case AppLanguage.english:
        return 'Open your operator room and other conversations here.';
      case AppLanguage.thai:
        return 'ดูห้องแชตกับทีมงานและห้องสนทนาอื่นได้ที่นี่';
    }
  }

  String get operatorRoomName {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Vận hành';
      case AppLanguage.japanese:
        return '運営業者';
      case AppLanguage.korean:
        return '운영자';
      case AppLanguage.russian:
        return 'Оператор';
      case AppLanguage.chinese:
        return '运营方';
      case AppLanguage.english:
        return 'Operator';
      case AppLanguage.thai:
        return 'ทีมงาน';
    }
  }

  String get operatorRoomSubtitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Hỗ trợ tài khoản và phản hồi nhanh từ admin.';
      case AppLanguage.japanese:
        return 'アカウントサポートと運営からのお知らせを確認できます。';
      case AppLanguage.korean:
        return '계정 지원과 운영진 안내를 여기서 확인할 수 있습니다.';
      case AppLanguage.russian:
        return 'Поддержка аккаунта и сообщения от оператора.';
      case AppLanguage.chinese:
        return '在这里查看账号支持和运营消息。';
      case AppLanguage.english:
        return 'Account support and direct replies from the admin team.';
      case AppLanguage.thai:
        return 'ติดต่อทีมงานเพื่อรับการช่วยเหลือเกี่ยวกับบัญชีได้ที่นี่';
    }
  }

  String get operatorRoomDescription {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Nhấn để mở phòng chat cố định với admin.';
      case AppLanguage.japanese:
        return 'タップすると運営業者との固定チャットを開きます。';
      case AppLanguage.korean:
        return '탭하면 운영자와의 고정 채팅방이 열립니다.';
      case AppLanguage.russian:
        return 'Нажмите, чтобы открыть закреплённый чат с оператором.';
      case AppLanguage.chinese:
        return '点击即可打开与运营方的固定聊天室。';
      case AppLanguage.english:
        return 'Tap to open your pinned chat room with the operator.';
      case AppLanguage.thai:
        return 'แตะเพื่อเปิดห้องแชตที่ปักหมุดไว้กับทีมงาน';
    }
  }

  String get myPageProfileEdit {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chỉnh sửa hồ sơ';
      case AppLanguage.japanese:
        return 'プロフィール変更';
      case AppLanguage.korean:
        return '프로필 변경';
      case AppLanguage.russian:
        return 'Изменить профиль';
      case AppLanguage.chinese:
        return '修改资料';
      case AppLanguage.english:
        return 'Edit profile';
      case AppLanguage.thai:
        return 'แก้ไขโปรไฟล์';
    }
  }

  String get myPageMyHome {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'My Home';
      case AppLanguage.japanese:
        return 'マイホーム';
      case AppLanguage.korean:
        return '마이홈';
      case AppLanguage.russian:
        return 'Мой дом';
      case AppLanguage.chinese:
        return '我的主页';
      case AppLanguage.english:
        return 'My Home';
      case AppLanguage.thai:
        return 'มายโฮม';
    }
  }

  String get myPageBlockList {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Danh sách chặn';
      case AppLanguage.japanese:
        return 'ブロックリスト';
      case AppLanguage.korean:
        return '차단 목록';
      case AppLanguage.russian:
        return 'Черный список';
      case AppLanguage.chinese:
        return '屏蔽列表';
      case AppLanguage.english:
        return 'Block list';
      case AppLanguage.thai:
        return 'รายการบล็อก';
    }
  }

  String get myPageTerms {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Điều khoản sử dụng';
      case AppLanguage.japanese:
        return '利用規約';
      case AppLanguage.korean:
        return '이용약관';
      case AppLanguage.russian:
        return 'Условия использования';
      case AppLanguage.chinese:
        return '使用条款';
      case AppLanguage.english:
        return 'Terms of Service';
      case AppLanguage.thai:
        return 'ข้อกำหนดการใช้งาน';
    }
  }

  String get myPagePrivacy {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chính sách bảo mật';
      case AppLanguage.japanese:
        return 'プライバシーポリシー';
      case AppLanguage.korean:
        return '개인정보 처리방침';
      case AppLanguage.russian:
        return 'Политика конфиденциальности';
      case AppLanguage.chinese:
        return '隐私政策';
      case AppLanguage.english:
        return 'Privacy Policy';
      case AppLanguage.thai:
        return 'นโยบายความเป็นส่วนตัว';
    }
  }

  String get myPageSettings {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Cài đặt';
      case AppLanguage.japanese:
        return '設定';
      case AppLanguage.korean:
        return '설정';
      case AppLanguage.russian:
        return 'Настройки';
      case AppLanguage.chinese:
        return '设置';
      case AppLanguage.english:
        return 'Settings';
      case AppLanguage.thai:
        return 'ตั้งค่า';
    }
  }

  String get flowerShopTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Cửa hàng hoa';
      case AppLanguage.japanese:
        return 'フラワーショップ';
      case AppLanguage.korean:
        return '플라워 샵';
      case AppLanguage.russian:
        return 'Магазин цветов';
      case AppLanguage.chinese:
        return '鲜花商店';
      case AppLanguage.english:
        return 'Flower Shop';
      case AppLanguage.thai:
        return 'ร้านดอกไม้';
    }
  }

  String get flowerShopSubtitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chọn hoa để tặng bằng point của bạn.';
      case AppLanguage.japanese:
        return 'ポイントで贈れるお花をここから選べます。';
      case AppLanguage.korean:
        return '포인트로 선물할 꽃을 여기에서 고를 수 있습니다.';
      case AppLanguage.russian:
        return 'Выберите цветы, которые можно подарить за поинты.';
      case AppLanguage.chinese:
        return '在这里选择可用点数赠送的鲜花。';
      case AppLanguage.english:
        return 'Choose flowers you can send with your points.';
      case AppLanguage.thai:
        return 'เลือกดอกไม้ที่คุณสามารถส่งเป็นของขวัญด้วยพอยต์ได้ที่นี่';
    }
  }

  String get flowerShopTab {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Hoa';
      case AppLanguage.japanese:
        return '花';
      case AppLanguage.korean:
        return '꽃';
      case AppLanguage.russian:
        return 'Цветы';
      case AppLanguage.chinese:
        return '鲜花';
      case AppLanguage.english:
        return 'Flowers';
      case AppLanguage.thai:
        return 'ดอกไม้';
    }
  }

  String get flowerShopLoadError {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Không thể tải danh sách hoa';
      case AppLanguage.japanese:
        return 'お花一覧を読み込めません';
      case AppLanguage.korean:
        return '꽃 목록을 불러올 수 없습니다';
      case AppLanguage.russian:
        return 'Не удалось загрузить список цветов';
      case AppLanguage.chinese:
        return '无法加载鲜花列表';
      case AppLanguage.english:
        return 'Cannot load flowers';
      case AppLanguage.thai:
        return 'ไม่สามารถโหลดรายการดอกไม้ได้';
    }
  }

  String get flowerShopEmpty {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chưa có hoa nào được đăng.';
      case AppLanguage.japanese:
        return '公開中のお花はまだありません。';
      case AppLanguage.korean:
        return '공개된 꽃이 아직 없습니다.';
      case AppLanguage.russian:
        return 'Пока нет опубликованных цветов.';
      case AppLanguage.chinese:
        return '暂时还没有已发布的鲜花。';
      case AppLanguage.english:
        return 'No flowers published yet.';
      case AppLanguage.thai:
        return 'ยังไม่มีดอกไม้ที่เผยแพร่อยู่';
    }
  }

  String get timelineTab {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Timeline';
      case AppLanguage.japanese:
        return 'タイムライン';
      case AppLanguage.korean:
        return '타임라인';
      case AppLanguage.russian:
        return 'Лента';
      case AppLanguage.chinese:
        return '动态';
      case AppLanguage.english:
        return 'Timeline';
      case AppLanguage.thai:
        return 'ไทม์ไลน์';
    }
  }

  String get timelineTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Timeline';
      case AppLanguage.japanese:
        return 'タイムライン';
      case AppLanguage.korean:
        return '타임라인';
      case AppLanguage.russian:
        return 'Лента';
      case AppLanguage.chinese:
        return '动态';
      case AppLanguage.english:
        return 'Timeline';
      case AppLanguage.thai:
        return 'ไทม์ไลน์';
    }
  }

  String get timelineSubtitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Đăng nhanh cảm xúc của bạn và xem các bài nổi bật.';
      case AppLanguage.japanese:
        return '気軽に投稿して、注目の投稿をチェックできます。';
      case AppLanguage.korean:
        return '가볍게 글을 올리고 인기 게시물을 확인해 보세요.';
      case AppLanguage.russian:
        return 'Публикуйте мысли и смотрите популярные посты.';
      case AppLanguage.chinese:
        return '随手发帖，并查看热门内容。';
      case AppLanguage.english:
        return 'Post quickly and browse featured updates.';
      case AppLanguage.thai:
        return 'โพสต์ได้อย่างรวดเร็วและดูโพสต์เด่นได้ที่นี่';
    }
  }

  String get timelineComposerTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Tạo bài đăng';
      case AppLanguage.japanese:
        return '投稿を作成';
      case AppLanguage.korean:
        return '게시물 작성';
      case AppLanguage.russian:
        return 'Создать пост';
      case AppLanguage.chinese:
        return '创建动态';
      case AppLanguage.english:
        return 'Create post';
      case AppLanguage.thai:
        return 'สร้างโพสต์';
    }
  }

  String get timelineComposerPlaceholder {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Bạn đang nghĩ gì hôm nay?';
      case AppLanguage.japanese:
        return '今どんな気分ですか？';
      case AppLanguage.korean:
        return '오늘은 어떤 기분인가요?';
      case AppLanguage.russian:
        return 'О чём вы думаете сегодня?';
      case AppLanguage.chinese:
        return '今天想分享点什么？';
      case AppLanguage.english:
        return 'What do you want to share today?';
      case AppLanguage.thai:
        return 'วันนี้คุณอยากแชร์อะไรบ้าง';
    }
  }

  String get timelineImagePlaceholder {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Dán link ảnh vào đây';
      case AppLanguage.japanese:
        return '画像URLを入力';
      case AppLanguage.korean:
        return '이미지 URL 입력';
      case AppLanguage.russian:
        return 'Вставьте ссылку на изображение';
      case AppLanguage.chinese:
        return '输入图片链接';
      case AppLanguage.english:
        return 'Paste image URL here';
      case AppLanguage.thai:
        return 'วางลิงก์รูปภาพที่นี่';
    }
  }

  String get timelinePublishButton {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Đăng bài';
      case AppLanguage.japanese:
        return '投稿する';
      case AppLanguage.korean:
        return '게시하기';
      case AppLanguage.russian:
        return 'Опубликовать';
      case AppLanguage.chinese:
        return '发布';
      case AppLanguage.english:
        return 'Publish';
      case AppLanguage.thai:
        return 'โพสต์';
    }
  }

  String get timelineFeaturedTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Bài đăng của tôi';
      case AppLanguage.japanese:
        return '自分の投稿';
      case AppLanguage.korean:
        return '내 게시물';
      case AppLanguage.russian:
        return 'Мои посты';
      case AppLanguage.chinese:
        return '我的动态';
      case AppLanguage.english:
        return 'My posts';
      case AppLanguage.thai:
        return 'โพสต์ของฉัน';
    }
  }

  String get timelineJustNow {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Vừa xong';
      case AppLanguage.japanese:
        return 'たった今';
      case AppLanguage.korean:
        return '방금 전';
      case AppLanguage.russian:
        return 'Только что';
      case AppLanguage.chinese:
        return '刚刚';
      case AppLanguage.english:
        return 'Just now';
      case AppLanguage.thai:
        return 'เมื่อสักครู่';
    }
  }

  String get missionTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Nhiệm vụ';
      case AppLanguage.japanese:
        return 'MISSION';
      case AppLanguage.korean:
        return '미션';
      case AppLanguage.russian:
        return 'Миссия';
      case AppLanguage.chinese:
        return '任务';
      case AppLanguage.english:
        return 'Mission';
      case AppLanguage.thai:
        return 'ภารกิจ';
    }
  }

  String get notificationsTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Thông báo';
      case AppLanguage.japanese:
        return 'お知らせ';
      case AppLanguage.korean:
        return '알림';
      case AppLanguage.russian:
        return 'Уведомления';
      case AppLanguage.chinese:
        return '通知';
      case AppLanguage.english:
        return 'Notifications';
      case AppLanguage.thai:
        return 'การแจ้งเตือน';
    }
  }

  String discoverBannerTitle(int index) {
    switch (index) {
      case 0:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Kết nối mới hôm nay';
          case AppLanguage.japanese:
            return '今日の新しい出会い';
          case AppLanguage.korean:
            return '오늘의 새로운 만남';
          case AppLanguage.russian:
            return 'Новые знакомства сегодня';
          case AppLanguage.chinese:
            return '今日新的相遇';
          case AppLanguage.english:
            return 'New connections today';
          case AppLanguage.thai:
            return 'การพบเจอใหม่วันนี้';
        }
      case 1:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Những người phù hợp với bạn';
          case AppLanguage.japanese:
            return 'あなたに合うおすすめ';
          case AppLanguage.korean:
            return '당신에게 맞는 추천';
          case AppLanguage.russian:
            return 'Подходящие вам люди';
          case AppLanguage.chinese:
            return '为你推荐的人';
          case AppLanguage.english:
            return 'People who match you';
          case AppLanguage.thai:
            return 'คนที่เหมาะกับคุณ';
        }
      case 2:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Trò chuyện nhẹ nhàng hơn';
          case AppLanguage.japanese:
            return 'もっと気軽に話そう';
          case AppLanguage.korean:
            return '더 가볍게 대화해 보세요';
          case AppLanguage.russian:
            return 'Начните общаться легче';
          case AppLanguage.chinese:
            return '更轻松地开始聊天';
          case AppLanguage.english:
            return 'Start chatting more easily';
          case AppLanguage.thai:
            return 'เริ่มคุยกันได้ง่ายขึ้น';
        }
      case 3:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Khám phá gần bạn';
          case AppLanguage.japanese:
            return '近くの相手をチェック';
          case AppLanguage.korean:
            return '가까운 사람을 찾아보세요';
          case AppLanguage.russian:
            return 'Люди рядом с вами';
          case AppLanguage.chinese:
            return '发现你附近的人';
          case AppLanguage.english:
            return 'Discover people nearby';
          case AppLanguage.thai:
            return 'ค้นหาคนใกล้ตัวคุณ';
        }
      default:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Tặng hoa để bắt đầu';
          case AppLanguage.japanese:
            return 'お花で会話を始めよう';
          case AppLanguage.korean:
            return '꽃 선물로 대화를 시작해요';
          case AppLanguage.russian:
            return 'Начните разговор с цветка';
          case AppLanguage.chinese:
            return '用鲜花开启聊天';
          case AppLanguage.english:
            return 'Start with a flower gift';
          case AppLanguage.thai:
            return 'เริ่มต้นด้วยการส่งดอกไม้';
        }
    }
  }

  String discoverBannerSubtitle(int index) {
    switch (index) {
      case 0:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Mở rộng vòng tròn của bạn bằng những profile mới nhất.';
          case AppLanguage.japanese:
            return '新しく登録したプロフィールをチェックしましょう。';
          case AppLanguage.korean:
            return '새로 가입한 프로필을 먼저 확인해 보세요.';
          case AppLanguage.russian:
            return 'Сначала посмотрите новые профили в системе.';
          case AppLanguage.chinese:
            return '先看看最新加入的用户资料。';
          case AppLanguage.english:
            return 'See the latest profiles who just joined.';
          case AppLanguage.thai:
            return 'ดูโปรไฟล์ใหม่ล่าสุดที่เพิ่งเข้ามาได้เลย';
        }
      case 1:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Dùng bộ lọc để tìm đúng người bạn đang muốn gặp.';
          case AppLanguage.japanese:
            return 'フィルターを使って会いたい相手を探せます。';
          case AppLanguage.korean:
            return '필터를 사용해 원하는 상대를 더 정확히 찾으세요.';
          case AppLanguage.russian:
            return 'Используйте фильтры, чтобы найти нужного человека.';
          case AppLanguage.chinese:
            return '使用筛选更精准地找到想认识的人。';
          case AppLanguage.english:
            return 'Use filters to find the right person faster.';
          case AppLanguage.thai:
            return 'ใช้ตัวกรองเพื่อหาคนที่ตรงใจได้เร็วขึ้น';
        }
      case 2:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Một lời nhắn ngắn có thể bắt đầu một cuộc gặp dài lâu.';
          case AppLanguage.japanese:
            return '短い一言から素敵な会話が始まるかもしれません。';
          case AppLanguage.korean:
            return '짧은 한마디가 좋은 대화의 시작이 될 수 있어요.';
          case AppLanguage.russian:
            return 'Короткое сообщение может стать началом хорошего разговора.';
          case AppLanguage.chinese:
            return '一句简单问候，也许就是一段对话的开始。';
          case AppLanguage.english:
            return 'A short hello can start a great conversation.';
          case AppLanguage.thai:
            return 'ข้อความสั้น ๆ อาจเป็นจุดเริ่มต้นของบทสนทนาที่ดี';
        }
      case 3:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Kiểm tra những người đang ở gần khu vực bạn chọn.';
          case AppLanguage.japanese:
            return '選択したエリアの近くにいる相手を見つけましょう。';
          case AppLanguage.korean:
            return '선택한 지역 근처에 있는 사람들을 확인해 보세요.';
          case AppLanguage.russian:
            return 'Смотрите людей рядом с выбранным вами районом.';
          case AppLanguage.chinese:
            return '查看你所选区域附近的用户。';
          case AppLanguage.english:
            return 'Browse people near the area you choose.';
          case AppLanguage.thai:
            return 'ดูคนที่อยู่ใกล้กับพื้นที่ที่คุณเลือก';
        }
      default:
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Một món quà nhỏ giúp cuộc trò chuyện dễ bắt đầu hơn.';
          case AppLanguage.japanese:
            return '小さなお花のギフトで会話を始めやすくなります。';
          case AppLanguage.korean:
            return '작은 꽃 선물로 대화를 더 부드럽게 시작해 보세요.';
          case AppLanguage.russian:
            return 'Небольшой подарок поможет начать разговор мягче.';
          case AppLanguage.chinese:
            return '一份小小花礼，会让对话更容易开始。';
          case AppLanguage.english:
            return 'A small flower gift can break the ice nicely.';
          case AppLanguage.thai:
            return 'ของขวัญดอกไม้เล็ก ๆ ช่วยให้เริ่มคุยกันง่ายขึ้น';
        }
    }
  }

  String flowerGiftName(Object type) {
    final normalized = type.toString().split('.').last;
    switch (normalized) {
      case 'rose':
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Hoa hồng';
          case AppLanguage.japanese:
            return 'ローズ';
          case AppLanguage.korean:
            return '장미';
          case AppLanguage.russian:
            return 'Роза';
          case AppLanguage.chinese:
            return '玫瑰';
          case AppLanguage.english:
            return 'Rose';
          case AppLanguage.thai:
            return 'กุหลาบ';
        }
      case 'tulip':
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Tulip';
          case AppLanguage.japanese:
            return 'チューリップ';
          case AppLanguage.korean:
            return '튤립';
          case AppLanguage.russian:
            return 'Тюльпан';
          case AppLanguage.chinese:
            return '郁金香';
          case AppLanguage.english:
            return 'Tulip';
          case AppLanguage.thai:
            return 'ทิวลิป';
        }
      case 'lily':
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Hoa ly';
          case AppLanguage.japanese:
            return 'リリー';
          case AppLanguage.korean:
            return '백합';
          case AppLanguage.russian:
            return 'Лилия';
          case AppLanguage.chinese:
            return '百合';
          case AppLanguage.english:
            return 'Lily';
          case AppLanguage.thai:
            return 'ลิลลี่';
        }
      case 'sunflower':
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Hoa hướng dương';
          case AppLanguage.japanese:
            return 'ひまわり';
          case AppLanguage.korean:
            return '해바라기';
          case AppLanguage.russian:
            return 'Подсолнух';
          case AppLanguage.chinese:
            return '向日葵';
          case AppLanguage.english:
            return 'Sunflower';
          case AppLanguage.thai:
            return 'ทานตะวัน';
        }
      case 'lavender':
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Lavender';
          case AppLanguage.japanese:
            return 'ラベンダー';
          case AppLanguage.korean:
            return '라벤더';
          case AppLanguage.russian:
            return 'Лаванда';
          case AppLanguage.chinese:
            return '薰衣草';
          case AppLanguage.english:
            return 'Lavender';
          case AppLanguage.thai:
            return 'ลาเวนเดอร์';
        }
      case 'camellia':
        switch (language) {
          case AppLanguage.vietnamese:
            return 'Hoa trà';
          case AppLanguage.japanese:
            return 'カメリア';
          case AppLanguage.korean:
            return '동백꽃';
          case AppLanguage.russian:
            return 'Камелия';
          case AppLanguage.chinese:
            return '山茶花';
          case AppLanguage.english:
            return 'Camellia';
          case AppLanguage.thai:
            return 'คามิเลีย';
        }
      default:
        return normalized;
    }
  }

  String get myPageBirthDateLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Ngày sinh';
      case AppLanguage.japanese:
        return '生年月日';
      case AppLanguage.korean:
        return '생년월일';
      case AppLanguage.russian:
        return 'Дата рождения';
      case AppLanguage.chinese:
        return '出生日期';
      case AppLanguage.english:
        return 'Birth date';
      case AppLanguage.thai:
        return 'วันเกิด';
    }
  }

  String get myPageGenderLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Giới tính';
      case AppLanguage.japanese:
        return '性別';
      case AppLanguage.korean:
        return '성별';
      case AppLanguage.russian:
        return 'Пол';
      case AppLanguage.chinese:
        return '性别';
      case AppLanguage.english:
        return 'Gender';
      case AppLanguage.thai:
        return 'เพศ';
    }
  }

  String get myPageEmptyPlaceholder {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Màn hình này đang được chuẩn bị.';
      case AppLanguage.japanese:
        return 'この画面は準備中です。';
      case AppLanguage.korean:
        return '이 화면은 준비 중입니다.';
      case AppLanguage.russian:
        return 'Этот экран пока готовится.';
      case AppLanguage.chinese:
        return '该页面正在准备中。';
      case AppLanguage.english:
        return 'This screen is being prepared.';
      case AppLanguage.thai:
        return 'หน้าจอนี้กำลังอยู่ระหว่างเตรียมการ';
    }
  }

  String get myPageLogoutConfirmTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Xác nhận đăng xuất';
      case AppLanguage.japanese:
        return 'ログアウト確認';
      case AppLanguage.korean:
        return '로그아웃 확인';
      case AppLanguage.russian:
        return 'Подтвердите выход';
      case AppLanguage.chinese:
        return '确认登出';
      case AppLanguage.english:
        return 'Confirm logout';
      case AppLanguage.thai:
        return 'ยืนยันการออกจากระบบ';
    }
  }

  String get myPageLogoutConfirmMessage {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Bạn có chắc muốn đăng xuất không?';
      case AppLanguage.japanese:
        return 'ログアウトしてもよろしいですか？';
      case AppLanguage.korean:
        return '로그아웃하시겠습니까?';
      case AppLanguage.russian:
        return 'Вы уверены, что хотите выйти?';
      case AppLanguage.chinese:
        return '确定要登出吗？';
      case AppLanguage.english:
        return 'Are you sure you want to log out?';
      case AppLanguage.thai:
        return 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ';
    }
  }

  String get cancelLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Hủy';
      case AppLanguage.japanese:
        return 'キャンセル';
      case AppLanguage.korean:
        return '취소';
      case AppLanguage.russian:
        return 'Отмена';
      case AppLanguage.chinese:
        return '取消';
      case AppLanguage.english:
        return 'Cancel';
      case AppLanguage.thai:
        return 'ยกเลิก';
    }
  }

  String get notSetLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chưa thiết lập';
      case AppLanguage.japanese:
        return '未設定';
      case AppLanguage.korean:
        return '미설정';
      case AppLanguage.russian:
        return 'Не задано';
      case AppLanguage.chinese:
        return '未设置';
      case AppLanguage.english:
        return 'Not set';
      case AppLanguage.thai:
        return 'ยังไม่ได้ตั้งค่า';
    }
  }

  String get noUserChatRooms {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chưa có phòng chat nào khác.';
      case AppLanguage.japanese:
        return '他のチャットルームはまだありません。';
      case AppLanguage.korean:
        return '다른 채팅방이 아직 없습니다.';
      case AppLanguage.russian:
        return 'Других чатов пока нет.';
      case AppLanguage.chinese:
        return '暂无其他聊天室。';
      case AppLanguage.english:
        return 'No other chat rooms yet.';
      case AppLanguage.thai:
        return 'ยังไม่มีห้องแชตอื่น';
    }
  }

  String get noMessagesYet {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chưa có tin nhắn nào.';
      case AppLanguage.japanese:
        return 'まだメッセージはありません。';
      case AppLanguage.korean:
        return '아직 메시지가 없습니다.';
      case AppLanguage.russian:
        return 'Сообщений пока нет.';
      case AppLanguage.chinese:
        return '还没有消息。';
      case AppLanguage.english:
        return 'No messages yet.';
      case AppLanguage.thai:
        return 'ยังไม่มีข้อความ';
    }
  }

  String get unknownUserLabel {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Người dùng';
      case AppLanguage.japanese:
        return 'ユーザー';
      case AppLanguage.korean:
        return '사용자';
      case AppLanguage.russian:
        return 'Пользователь';
      case AppLanguage.chinese:
        return '用户';
      case AppLanguage.english:
        return 'User';
      case AppLanguage.thai:
        return 'ผู้ใช้';
    }
  }

  String chatRoomDetailTitle(String name) {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Chat với $name';
      case AppLanguage.japanese:
        return '$nameとのチャット';
      case AppLanguage.korean:
        return '$name 채팅';
      case AppLanguage.russian:
        return 'Чат с $name';
      case AppLanguage.chinese:
        return '与$name聊天';
      case AppLanguage.english:
        return 'Chat with $name';
      case AppLanguage.thai:
        return 'แชตกับ $name';
    }
  }

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
