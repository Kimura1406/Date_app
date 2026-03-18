import 'app_language.dart';
import 'app_localizations.dart';

extension DiscoveryStrings on AppStrings {
  String get filterTitle {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Tìm kiếm theo điều kiện';
      case AppLanguage.japanese:
        return '条件で検索';
      case AppLanguage.korean:
        return '조건으로 검색';
      case AppLanguage.russian:
        return 'Поиск по условиям';
      case AppLanguage.chinese:
        return '按条件搜索';
      case AppLanguage.english:
        return 'Search by conditions';
      case AppLanguage.thai:
        return 'ค้นหาตามเงื่อนไข';
    }
  }

  String get showFilters {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Mở bộ lọc';
      case AppLanguage.japanese:
        return '絞り込みを開く';
      case AppLanguage.korean:
        return '필터 열기';
      case AppLanguage.russian:
        return 'Открыть фильтр';
      case AppLanguage.chinese:
        return '打开筛选';
      case AppLanguage.english:
        return 'Show filters';
      case AppLanguage.thai:
        return 'เปิดตัวกรอง';
    }
  }

  String get hideFilters {
    switch (language) {
      case AppLanguage.vietnamese:
        return 'Đóng bộ lọc';
      case AppLanguage.japanese:
        return '絞り込みを閉じる';
      case AppLanguage.korean:
        return '필터 닫기';
      case AppLanguage.russian:
        return 'Скрыть фильтр';
      case AppLanguage.chinese:
        return '关闭筛选';
      case AppLanguage.english:
        return 'Hide filters';
      case AppLanguage.thai:
        return 'ปิดตัวกรอง';
    }
  }

  String get countryFilter => language == AppLanguage.japanese ? '国' : _common(
        vi: 'Quốc gia',
        ko: '국가',
        ru: 'Страна',
        zh: '国家',
        en: 'Country',
        th: 'ประเทศ',
      );

  String get jobFilter => _common(
        vi: 'Nghề nghiệp',
        ja: '職業',
        ko: '직업',
        ru: 'Профессия',
        zh: '职业',
        en: 'Job',
        th: 'อาชีพ',
      );

  String get ageRangeFilter => _common(
        vi: 'Độ tuổi',
        ja: '年齢',
        ko: '연령',
        ru: 'Возраст',
        zh: '年龄',
        en: 'Age range',
        th: 'ช่วงอายุ',
      );

  String get ageFrom => _common(
        vi: 'Từ',
        ja: 'から',
        ko: '부터',
        ru: 'От',
        zh: '从',
        en: 'From',
        th: 'จาก',
      );

  String get ageTo => _common(
        vi: 'Đến',
        ja: 'まで',
        ko: '까지',
        ru: 'До',
        zh: '到',
        en: 'To',
        th: 'ถึง',
      );

  String get genderFilter => _common(
        vi: 'Giới tính',
        ja: '性別',
        ko: '성별',
        ru: 'Пол',
        zh: '性别',
        en: 'Gender',
        th: 'เพศ',
      );

  String get locationFilter => _common(
        vi: 'Địa điểm',
        ja: '場所',
        ko: '위치',
        ru: 'Местоположение',
        zh: '地点',
        en: 'Location',
        th: 'สถานที่',
      );

  String get locationPlaceholder => _common(
        vi: 'Nhập khu vực hoặc địa chỉ',
        ja: 'エリアまたは住所を入力',
        ko: '지역 또는 주소를 입력',
        ru: 'Введите район или адрес',
        zh: '输入地区或地址',
        en: 'Enter area or address',
        th: 'กรอกพื้นที่หรือที่อยู่',
      );

  String get resetFilters => _common(
        vi: 'Xóa lọc',
        ja: 'リセット',
        ko: '초기화',
        ru: 'Сбросить',
        zh: '重置',
        en: 'Reset',
        th: 'รีเซ็ต',
      );

  String get applyFilters => _common(
        vi: 'Tìm kiếm',
        ja: '検索',
        ko: '검색',
        ru: 'Искать',
        zh: '搜索',
        en: 'Search',
        th: 'ค้นหา',
      );

  String get anyOption => _common(
        vi: 'Tất cả',
        ja: 'すべて',
        ko: '전체',
        ru: 'Все',
        zh: '全部',
        en: 'All',
        th: 'ทั้งหมด',
      );

  String get feedSectionTitle => _common(
        vi: 'Gợi ý cho bạn',
        ja: 'おすすめ',
        ko: '추천',
        ru: 'Рекомендации',
        zh: '为你推荐',
        en: 'Recommended for you',
        th: 'แนะนำสำหรับคุณ',
      );

  String get newBadge => _common(
        vi: 'Mới',
        ja: 'New',
        ko: 'New',
        ru: 'New',
        zh: 'New',
        en: 'New',
        th: 'New',
      );

  String countryName(String code) {
    switch (code) {
      case 'Vietnam':
        return _common(vi: 'Việt Nam', ja: 'ベトナム', ko: '베트남', ru: 'Вьетнам', zh: '越南', en: 'Vietnam', th: 'เวียดนาม');
      case 'Japan':
        return _common(vi: 'Nhật Bản', ja: '日本', ko: '일본', ru: 'Япония', zh: '日本', en: 'Japan', th: 'ญี่ปุ่น');
      case 'Korea':
        return _common(vi: 'Hàn Quốc', ja: '韓国', ko: '한국', ru: 'Корея', zh: '韩国', en: 'Korea', th: 'เกาหลี');
      case 'Russia':
        return _common(vi: 'Nga', ja: 'ロシア', ko: '러시아', ru: 'Россия', zh: '俄罗斯', en: 'Russia', th: 'รัสเซีย');
      case 'China':
        return _common(vi: 'Trung Quốc', ja: '中国', ko: '중국', ru: 'Китай', zh: '中国', en: 'China', th: 'จีน');
      case 'England':
        return _common(vi: 'Anh', ja: 'イギリス', ko: '영국', ru: 'Англия', zh: '英国', en: 'England', th: 'อังกฤษ');
      case 'Thailand':
        return _common(vi: 'Thái Lan', ja: 'タイ', ko: '태국', ru: 'Таиланд', zh: '泰国', en: 'Thailand', th: 'ไทย');
      default:
        return code;
    }
  }

  String genderName(String code) {
    switch (code) {
      case 'female':
        return _common(vi: 'Nữ', ja: '女性', ko: '여성', ru: 'Женщина', zh: '女性', en: 'Female', th: 'ผู้หญิง');
      case 'male':
        return _common(vi: 'Nam', ja: '男性', ko: '남성', ru: 'Мужчина', zh: '男性', en: 'Male', th: 'ผู้ชาย');
      case 'other':
        return _common(vi: 'Khác', ja: 'その他', ko: '기타', ru: 'Другое', zh: '其他', en: 'Other', th: 'อื่นๆ');
      default:
        return code;
    }
  }

  String jobName(String code) {
    switch (code) {
      case 'Photographer':
        return _common(vi: 'Nhiếp ảnh gia', ja: 'フォトグラファー', ko: '사진작가', ru: 'Фотограф', zh: '摄影师', en: 'Photographer', th: 'ช่างภาพ');
      case 'Designer':
        return _common(vi: 'Nhà thiết kế', ja: 'デザイナー', ko: '디자이너', ru: 'Дизайнер', zh: '设计师', en: 'Designer', th: 'นักออกแบบ');
      case 'Software Engineer':
        return _common(vi: 'Kỹ sư phần mềm', ja: 'ソフトウェアエンジニア', ko: '소프트웨어 엔지니어', ru: 'Инженер-программист', zh: '软件工程师', en: 'Software Engineer', th: 'วิศวกรซอฟต์แวร์');
      case 'Teacher':
        return _common(vi: 'Giáo viên', ja: '教師', ko: '교사', ru: 'Учитель', zh: '老师', en: 'Teacher', th: 'ครู');
      case 'Doctor':
        return _common(vi: 'Bác sĩ', ja: '医師', ko: '의사', ru: 'Врач', zh: '医生', en: 'Doctor', th: 'แพทย์');
      case 'Nurse':
        return _common(vi: 'Y tá', ja: '看護師', ko: '간호사', ru: 'Медсестра', zh: '护士', en: 'Nurse', th: 'พยาบาล');
      case 'Marketing Specialist':
        return _common(vi: 'Chuyên viên marketing', ja: 'マーケティング担当', ko: '마케팅 전문가', ru: 'Маркетолог', zh: '市场专员', en: 'Marketing Specialist', th: 'นักการตลาด');
      case 'Product Manager':
        return _common(vi: 'Quản lý sản phẩm', ja: 'プロダクトマネージャー', ko: '프로덕트 매니저', ru: 'Продакт-менеджер', zh: '产品经理', en: 'Product Manager', th: 'ผู้จัดการผลิตภัณฑ์');
      case 'Fitness Coach':
        return _common(vi: 'Huấn luyện viên thể hình', ja: 'フィットネスコーチ', ko: '피트니스 코치', ru: 'Фитнес-тренер', zh: '健身教练', en: 'Fitness Coach', th: 'โค้ชฟิตเนส');
      case 'Chef':
        return _common(vi: 'Đầu bếp', ja: 'シェフ', ko: '셰프', ru: 'Шеф-повар', zh: '厨师', en: 'Chef', th: 'เชฟ');
      case 'Sales Manager':
        return _common(vi: 'Quản lý bán hàng', ja: '営業マネージャー', ko: '영업 관리자', ru: 'Менеджер по продажам', zh: '销售经理', en: 'Sales Manager', th: 'ผู้จัดการฝ่ายขาย');
      case 'Writer':
        return _common(vi: 'Nhà văn', ja: 'ライター', ko: '작가', ru: 'Писатель', zh: '作家', en: 'Writer', th: 'นักเขียน');
      case 'Lawyer':
        return _common(vi: 'Luật sư', ja: '弁護士', ko: '변호사', ru: 'Юрист', zh: '律师', en: 'Lawyer', th: 'ทนายความ');
      case 'Artist':
        return _common(vi: 'Nghệ sĩ', ja: 'アーティスト', ko: '아티스트', ru: 'Художник', zh: '艺术家', en: 'Artist', th: 'ศิลปิน');
      case 'Entrepreneur':
        return _common(vi: 'Doanh nhân', ja: '起業家', ko: '사업가', ru: 'Предприниматель', zh: '企业家', en: 'Entrepreneur', th: 'ผู้ประกอบการ');
      default:
        return code;
    }
  }

  String _common({
    required String vi,
    String? ja,
    required String ko,
    required String ru,
    required String zh,
    required String en,
    required String th,
  }) {
    switch (language) {
      case AppLanguage.vietnamese:
        return vi;
      case AppLanguage.japanese:
        return ja ?? en;
      case AppLanguage.korean:
        return ko;
      case AppLanguage.russian:
        return ru;
      case AppLanguage.chinese:
        return zh;
      case AppLanguage.english:
        return en;
      case AppLanguage.thai:
        return th;
    }
  }
}
