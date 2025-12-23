/// App localization strings for multiple languages.
class AppStrings {
  final String code;

  AppStrings(this.code);

  // App Title
  String get appTitle => _t({
    'en': 'Subscriptions',
    'ar': 'الاشتراكات',
    'fr': 'Abonnements',
    'es': 'Suscripciones',
    'de': 'Abonnements',
    'pt': 'Assinaturas',
    'ja': 'サブスクリプション',
    'tr': 'Abonelikler',
    'zh': '订阅',
    'ko': '구독',
  });

  // Navigation & Actions
  String get settings => _t({
    'en': 'Settings',
    'ar': 'الإعدادات',
    'fr': 'Paramètres',
    'es': 'Configuración',
    'de': 'Einstellungen',
    'pt': 'Configurações',
    'ja': '設定',
    'tr': 'Ayarlar',
    'zh': '设置',
    'ko': '설정',
  });

  String get history => _t({
    'en': 'Payment History',
    'ar': 'سجل الدفع',
    'fr': 'Historique des paiements',
    'es': 'Historial de pagos',
    'de': 'Zahlungsverlauf',
    'pt': 'Histórico de pagamentos',
    'ja': '支払い履歴',
    'tr': 'Ödeme geçmişi',
    'zh': '付款记录',
    'ko': '결제 내역',
  });

  String get whereToWatch => _t({
    'en': 'Where to Watch',
    'ar': 'أين تشاهد',
    'fr': 'Où regarder',
    'es': 'Dónde ver',
    'de': 'Wo ansehen',
    'pt': 'Onde assistir',
    'ja': '視聴先',
    'tr': 'Nerede izlenir',
    'zh': '在哪里观看',
    'ko': '어디서 볼까',
  });

  String get signOut => _t({
    'en': 'Sign Out',
    'ar': 'تسجيل الخروج',
    'fr': 'Déconnexion',
    'es': 'Cerrar sesión',
    'de': 'Abmelden',
    'pt': 'Sair',
    'ja': 'ログアウト',
    'tr': 'Çıkış yap',
    'zh': '退出登录',
    'ko': '로그아웃',
  });

  String get cancel => _t({
    'en': 'Cancel',
    'ar': 'إلغاء',
    'fr': 'Annuler',
    'es': 'Cancelar',
    'de': 'Abbrechen',
    'pt': 'Cancelar',
    'ja': 'キャンセル',
    'tr': 'İptal',
    'zh': '取消',
    'ko': '취소',
  });

  String get delete => _t({
    'en': 'Delete',
    'ar': 'حذف',
    'fr': 'Supprimer',
    'es': 'Eliminar',
    'de': 'Löschen',
    'pt': 'Excluir',
    'ja': '削除',
    'tr': 'Sil',
    'zh': '删除',
    'ko': '삭제',
  });

  String get edit => _t({
    'en': 'Edit',
    'ar': 'تعديل',
    'fr': 'Modifier',
    'es': 'Editar',
    'de': 'Bearbeiten',
    'pt': 'Editar',
    'ja': '編集',
    'tr': 'Düzenle',
    'zh': '编辑',
    'ko': '수정',
  });

  String get save => _t({
    'en': 'Save',
    'ar': 'حفظ',
    'fr': 'Enregistrer',
    'es': 'Guardar',
    'de': 'Speichern',
    'pt': 'Salvar',
    'ja': '保存',
    'tr': 'Kaydet',
    'zh': '保存',
    'ko': '저장',
  });

  String get add => _t({
    'en': 'Add',
    'ar': 'إضافة',
    'fr': 'Ajouter',
    'es': 'Añadir',
    'de': 'Hinzufügen',
    'pt': 'Adicionar',
    'ja': '追加',
    'tr': 'Ekle',
    'zh': '添加',
    'ko': '추가',
  });

  String get search => _t({
    'en': 'Search',
    'ar': 'بحث',
    'fr': 'Rechercher',
    'es': 'Buscar',
    'de': 'Suchen',
    'pt': 'Pesquisar',
    'ja': '検索',
    'tr': 'Ara',
    'zh': '搜索',
    'ko': '검색',
  });

  String get favorites => _t({
    'en': 'Favorites',
    'ar': 'المفضلة',
    'fr': 'Favoris',
    'es': 'Favoritos',
    'de': 'Favoriten',
    'pt': 'Favoritos',
    'ja': 'お気に入り',
    'tr': 'Favoriler',
    'zh': '收藏',
    'ko': '즐겨찾기',
  });

  String get noFavoritesYet => _t({
    'en': 'No favorites yet',
    'ar': 'لا توجد مفضلات بعد',
    'fr': 'Pas encore de favoris',
    'es': 'Aún no hay favoritos',
    'de': 'Noch keine Favoriten',
    'pt': 'Ainda não há favoritos',
    'ja': 'お気に入りはまだありません',
    'tr': 'Henüz favori yok',
    'zh': '暂无收藏',
    'ko': '아직 즐겨찾기가 없습니다',
  });

  String get tapHeartToAdd => _t({
    'en': 'Tap the heart icon on any item to add it to your favorites',
    'ar': 'اضغط على أيقونة القلب في أي عنصر لإضافته إلى المفضلة',
    'fr': 'Appuyez sur l\'icône du cœur pour ajouter aux favoris',
    'es': 'Toca el ícono del corazón para añadir a favoritos',
    'ko': '하트 아이콘을 탭하여 즐겨찾기에 추가하세요',
  });

  String get addedToFavorites => _t({
    'en': 'Added to favorites',
    'ar': 'تمت الإضافة إلى المفضلة',
    'fr': 'Ajouté aux favoris',
    'es': 'Añadido a favoritos',
    'de': 'Zu Favoriten hinzugefügt',
    'pt': 'Adicionado aos favoritos',
    'ja': 'お気に入りに追加しました',
    'tr': 'Favorilere eklendi',
    'zh': '已添加到收藏',
    'ko': '즐겨찾기에 추가됨',
  });

  String get removedFromFavorites => _t({
    'en': 'Removed from favorites',
    'ar': 'تمت الإزالة من المفضلة',
    'fr': 'Retiré des favoris',
    'es': 'Eliminado de favoritos',
    'de': 'Aus Favoriten entfernt',
    'pt': 'Removido dos favoritos',
    'ja': 'お気に入りから削除しました',
    'tr': 'Favorilerden kaldırıldı',
    'zh': '已从收藏移除',
    'ko': '즐겨찾기에서 제거됨',
  });

  // Home Screen
  String get totalMonthlyCost => _t({
    'en': 'Total Cost',
    'ar': 'التكلفة الإجمالية',
    'fr': 'Coût total',
    'es': 'Costo total',
    'de': 'Gesamtkosten',
    'pt': 'Custo total',
    'ja': '合計費用',
    'tr': 'Toplam maliyet',
    'zh': '总费用',
    'ko': '총 비용',
  });

  String activeSubscriptions(int count) => _t({
    'en': '$count active subscription${count == 1 ? '' : 's'}',
    'ar': '$count اشتراك${count == 1 ? '' : 'ات'} نشط',
    'fr': '$count abonnement${count == 1 ? '' : 's'} actif${count == 1 ? '' : 's'}',
    'es': '$count suscripción${count == 1 ? '' : 'es'} activa${count == 1 ? '' : 's'}',
    'ko': '활성 구독 $count개',
  });

  String get noSubscriptionsYet => _t({
    'en': 'No subscriptions yet',
    'ar': 'لا توجد اشتراكات بعد',
    'fr': 'Pas encore d\'abonnements',
    'es': 'Sin suscripciones aún',
    'de': 'Noch keine Abonnements',
    'pt': 'Ainda não há assinaturas',
    'ja': 'まだサブスクリプションがありません',
    'tr': 'Henüz abonelik yok',
    'zh': '暂无订阅',
    'ko': '아직 구독이 없습니다',
  });

  String get tapToAddFirst => _t({
    'en': 'Tap the + button to add your first subscription',
    'ar': 'اضغط على زر + لإضافة أول اشتراك',
    'fr': 'Appuyez sur + pour ajouter votre premier abonnement',
    'es': 'Toca el botón + para añadir tu primera suscripción',
    'de': 'Tippe auf +, um dein erstes Abo hinzuzufügen',
    'pt': 'Toque no botão + para adicionar sua primeira assinatura',
    'ja': '+ ボタンをタップして最初のサブスクリプションを追加します',
    'tr': 'İlk aboneliğini eklemek için + düğmesine dokun',
    'zh': '点击 + 按钮添加你的第一个订阅',
    'ko': '+ 버튼을 눌러 첫 구독을 추가하세요',
  });

  // Subscription Status
  String get overdue => _t({
    'en': 'Overdue',
    'ar': 'متأخر',
    'fr': 'En retard',
    'es': 'Vencido',
    'ko': '연체',
  });

  String get dueSoon => _t({
    'en': 'Due Soon',
    'ar': 'قريباً',
    'fr': 'Bientôt dû',
    'es': 'Vence pronto',
    'ko': '곧 만료',
  });

  String get active => _t({
    'en': 'Active',
    'ar': 'نشط',
    'fr': 'Actif',
    'es': 'Activo',
    'ko': '활성',
  });

  String get cancelled => _t({
    'en': 'Cancelled',
    'ar': 'ملغى',
    'fr': 'Annulé',
    'es': 'Cancelado',
    'ko': '취소됨',
  });

  // Subscription Details
  String get price => _t({
    'en': 'Price',
    'ar': 'السعر',
    'fr': 'Prix',
    'es': 'Precio',
    'ko': '가격',
  });

  String get billingCycle => _t({
    'en': 'Billing Cycle',
    'ar': 'دورة الفوترة',
    'fr': 'Cycle de facturation',
    'es': 'Ciclo de facturación',
    'ko': '결제 주기',
  });

  String get nextPayment => _t({
    'en': 'Next Payment',
    'ar': 'الدفعة القادمة',
    'fr': 'Prochain paiement',
    'es': 'Próximo pago',
    'ko': '다음 결제',
  });

  String get monthly => _t({
    'en': 'Monthly',
    'ar': 'شهري',
    'fr': 'Mensuel',
    'es': 'Mensual',
    'ko': '월간',
  });

  String get yearly => _t({
    'en': 'Yearly',
    'ar': 'سنوي',
    'fr': 'Annuel',
    'es': 'Anual',
    'ko': '연간',
  });

  // Add/Edit Subscription
  String get addSubscription => _t({
    'en': 'Add Subscription',
    'ar': 'إضافة اشتراك',
    'fr': 'Ajouter un abonnement',
    'es': 'Añadir suscripción',
    'ko': '구독 추가',
  });

  String get editSubscription => _t({
    'en': 'Edit Subscription',
    'ar': 'تعديل الاشتراك',
    'fr': 'Modifier l\'abonnement',
    'es': 'Editar suscripción',
    'ko': '구독 수정',
  });

  String get subscriptionName => _t({
    'en': 'Subscription Name',
    'ar': 'اسم الاشتراك',
    'fr': 'Nom de l\'abonnement',
    'es': 'Nombre de suscripción',
    'ko': '구독 이름',
  });

  String get selectBrand => _t({
    'en': 'Select Brand',
    'ar': 'اختر العلامة التجارية',
    'fr': 'Sélectionner la marque',
    'es': 'Seleccionar marca',
    'ko': '브랜드 선택',
  });

  String get selectCurrency => _t({
    'en': 'Select Currency',
    'ar': 'اختر العملة',
    'fr': 'Sélectionner la devise',
    'es': 'Seleccionar moneda',
    'ko': '통화 선택',
  });

  // History Screen
  String get noPaymentHistory => _t({
    'en': 'No Payment History',
    'ar': 'لا يوجد سجل دفع',
    'fr': 'Pas d\'historique de paiement',
    'es': 'Sin historial de pagos',
    'ko': '결제 내역 없음',
  });

  String get paymentHistoryWillAppear => _t({
    'en': 'Your payment records will appear here',
    'ar': 'ستظهر سجلات الدفع الخاصة بك هنا',
    'fr': 'Vos relevés de paiement apparaîtront ici',
    'es': 'Tus registros de pago aparecerán aquí',
    'ko': '결제 기록이 여기에 표시됩니다',
  });

  String get recentPayments => _t({
    'en': 'Recent Payments',
    'ar': 'المدفوعات الأخيرة',
    'fr': 'Paiements récents',
    'es': 'Pagos recientes',
    'ko': '최근 결제',
  });

  String get overview => _t({
    'en': 'Overview',
    'ar': 'نظرة عامة',
    'fr': 'Aperçu',
    'es': 'Resumen',
    'ko': '개요',
  });

  String get thisMonth => _t({
    'en': 'This Month',
    'ar': 'هذا الشهر',
    'fr': 'Ce mois',
    'es': 'Este mes',
    'ko': '이번 달',
  });

  String get thisYear => _t({
    'en': 'This Year',
    'ar': 'هذا العام',
    'fr': 'Cette année',
    'es': 'Este año',
    'ko': '올해',
  });

  String get totalSpent => _t({
    'en': 'Total Spent',
    'ar': 'إجمالي الإنفاق',
    'fr': 'Total dépensé',
    'es': 'Total gastado',
    'ko': '총 지출',
  });

  String get payments => _t({
    'en': 'Payments',
    'ar': 'المدفوعات',
    'fr': 'Paiements',
    'es': 'Pagos',
    'ko': '결제',
  });

  // Mark as Paid
  String get markAsPaid => _t({
    'en': 'Mark as Paid',
    'ar': 'تعليم كمدفوع',
    'fr': 'Marquer comme payé',
    'es': 'Marcar como pagado',
    'ko': '결제 완료로 표시',
  });

  String get paid => _t({
    'en': 'Paid',
    'ar': 'مدفوع',
    'fr': 'Payé',
    'es': 'Pagado',
    'ko': '결제됨',
  });

  String get paymentRecorded => _t({
    'en': 'Payment recorded',
    'ar': 'تم تسجيل الدفعة',
    'fr': 'Paiement enregistré',
    'es': 'Pago registrado',
    'ko': '결제가 기록되었습니다',
  });

  // Settings
  String get language => _t({
    'en': 'Language',
    'ar': 'اللغة',
    'fr': 'Langue',
    'es': 'Idioma',
    'de': 'Sprache',
    'pt': 'Idioma',
    'ja': '言語',
    'tr': 'Dil',
    'zh': '语言',
    'ko': '언어',
  });

  String get selectLanguage => _t({
    'en': 'Select your preferred language',
    'ar': 'اختر لغتك المفضلة',
    'fr': 'Sélectionnez votre langue préférée',
    'es': 'Selecciona tu idioma preferido',
    'de': 'Wähle deine bevorzugte Sprache',
    'pt': 'Selecione seu idioma preferido',
    'ja': '希望の言語を選択してください',
    'tr': 'Tercih ettiğiniz dili seçin',
    'zh': '选择你的首选语言',
    'ko': '선호하는 언어를 선택하세요',
  });

  String get about => _t({
    'en': 'About',
    'ar': 'حول',
    'fr': 'À propos',
    'es': 'Acerca de',
    'ko': '정보',
  });

  String get appVersion => _t({
    'en': 'App Version',
    'ar': 'إصدار التطبيق',
    'fr': 'Version de l\'application',
    'es': 'Versión de la app',
    'ko': '앱 버전',
  });

  String get trackSubscriptions => _t({
    'en': 'Track and manage your subscriptions',
    'ar': 'تتبع وإدارة اشتراكاتك',
    'fr': 'Suivez et gérez vos abonnements',
    'es': 'Rastrea y gestiona tus suscripciones',
    'ko': '구독을 추적하고 관리하세요',
  });

  String languageChangedTo(String lang) => _t({
    'en': 'Language changed to $lang',
    'ar': 'تم تغيير اللغة إلى $lang',
    'fr': 'Langue changée en $lang',
    'es': 'Idioma cambiado a $lang',
    'de': 'Sprache geändert zu $lang',
    'pt': 'Idioma alterado para $lang',
    'ja': '言語が$langに変更されました',
    'tr': 'Dil $lang olarak değiştirildi',
    'zh': '语言已更改为$lang',
    'ko': '언어가 $lang(으)로 변경되었습니다',
  });

  // Cancellation
  String get cancelSubscription => _t({
    'en': 'Cancel Subscription',
    'ar': 'إلغاء الاشتراك',
    'fr': 'Annuler l\'abonnement',
    'es': 'Cancelar suscripción',
    'ko': '구독 취소',
  });

  String get cancelSubscriptionOnline => _t({
    'en': 'Cancel Subscription Online',
    'ar': 'إلغاء الاشتراك عبر الإنترنت',
    'fr': 'Annuler l\'abonnement en ligne',
    'es': 'Cancelar suscripción en línea',
    'ko': '온라인으로 구독 취소',
  });

  String get howToCancel => _t({
    'en': 'How to Cancel',
    'ar': 'كيفية الإلغاء',
    'fr': 'Comment annuler',
    'es': 'Cómo cancelar',
    'ko': '취소 방법',
  });

  String get markAsCancelled => _t({
    'en': 'Mark as Cancelled',
    'ar': 'تعليم كملغى',
    'fr': 'Marquer comme annulé',
    'es': 'Marcar como cancelado',
    'ko': '취소됨으로 표시',
  });

  String get reactivateSubscription => _t({
    'en': 'Reactivate Subscription',
    'ar': 'إعادة تفعيل الاشتراك',
    'fr': 'Réactiver l\'abonnement',
    'es': 'Reactivar suscripción',
    'ko': '구독 재활성화',
  });

  String get deleteSubscription => _t({
    'en': 'Delete Subscription',
    'ar': 'حذف الاشتراك',
    'fr': 'Supprimer l\'abonnement',
    'es': 'Eliminar suscripción',
    'ko': '구독 삭제',
  });

  String deleteConfirmation(String name) => _t({
    'en': 'Are you sure you want to delete "$name"? This action cannot be undone.',
    'ar': 'هل أنت متأكد من حذف "$name"؟ لا يمكن التراجع عن هذا الإجراء.',
    'fr': 'Êtes-vous sûr de vouloir supprimer "$name" ? Cette action est irréversible.',
    'es': '¿Estás seguro de que quieres eliminar "$name"? Esta acción no se puede deshacer.',
    'ko': '"$name"을(를) 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.',
  });

  // Sign Out
  String get signOutConfirmation => _t({
    'en': 'Are you sure you want to sign out?',
    'ar': 'هل أنت متأكد من تسجيل الخروج؟',
    'fr': 'Êtes-vous sûr de vouloir vous déconnecter ?',
    'es': '¿Estás seguro de que quieres cerrar sesión?',
    'ko': '로그아웃 하시겠습니까?',
  });

  // Login
  String get welcomeBack => _t({
    'en': 'Welcome Back!',
    'ar': 'مرحباً بعودتك!',
    'fr': 'Bienvenue !',
    'es': '¡Bienvenido!',
    'ko': '다시 오신 것을 환영합니다!',
  });

  String get signInToContinue => _t({
    'en': 'Sign in to continue',
    'ar': 'سجل الدخول للمتابعة',
    'fr': 'Connectez-vous pour continuer',
    'es': 'Inicia sesión para continuar',
    'ko': '계속하려면 로그인하세요',
  });

  String get signInWithGoogle => _t({
    'en': 'Sign in with Google',
    'ar': 'تسجيل الدخول بـ Google',
    'fr': 'Se connecter avec Google',
    'es': 'Iniciar sesión con Google',
    'ko': 'Google로 로그인',
  });

  // Error messages
  String get errorLoadingSubscriptions => _t({
    'en': 'Error loading subscriptions',
    'ar': 'خطأ في تحميل الاشتراكات',
    'fr': 'Erreur lors du chargement des abonnements',
    'es': 'Error al cargar suscripciones',
    'ko': '구독을 불러오는 중 오류 발생',
  });

  String get retry => _t({
    'en': 'Retry',
    'ar': 'إعادة المحاولة',
    'fr': 'Réessayer',
    'es': 'Reintentar',
    'ko': '다시 시도',
  });

  // Where to Watch Screen
  String get searchMoviesAndShows => _t({
    'en': 'Search movies and TV shows...',
    'ar': 'ابحث عن الأفلام والمسلسلات...',
    'fr': 'Rechercher des films et des séries...',
    'es': 'Buscar películas y series...',
    'ko': '영화와 TV 프로그램 검색...',
  });

  String get trending => _t({
    'en': 'Trending',
    'ar': 'الشائع',
    'fr': 'Tendances',
    'es': 'Tendencias',
    'ko': '인기',
  });

  String get searchResults => _t({
    'en': 'Search Results',
    'ar': 'نتائج البحث',
    'fr': 'Résultats de recherche',
    'es': 'Resultados de búsqueda',
    'ko': '검색 결과',
  });

  String get movie => _t({
    'en': 'Movie',
    'ar': 'فيلم',
    'fr': 'Film',
    'es': 'Película',
    'ko': '영화',
  });

  String get tvShow => _t({
    'en': 'TV Show',
    'ar': 'مسلسل',
    'fr': 'Série TV',
    'es': 'Serie de TV',
    'ko': 'TV 프로그램',
  });

  String get availableOn => _t({
    'en': 'Available on',
    'ar': 'متاح على',
    'fr': 'Disponible sur',
    'es': 'Disponible en',
    'ko': '시청 가능',
  });

  String get notAvailableForStreaming => _t({
    'en': 'Not available for streaming',
    'ar': 'غير متاح للبث',
    'fr': 'Non disponible en streaming',
    'es': 'No disponible para streaming',
    'ko': '스트리밍 불가',
  });

  String get stream => _t({
    'en': 'Stream',
    'ar': 'بث',
    'fr': 'Diffusion',
    'es': 'Transmisión',
    'ko': '스트리밍',
  });

  String get rent => _t({
    'en': 'Rent',
    'ar': 'إيجار',
    'fr': 'Location',
    'es': 'Alquilar',
    'ko': '대여',
  });

  String get buy => _t({
    'en': 'Buy',
    'ar': 'شراء',
    'fr': 'Acheter',
    'es': 'Comprar',
    'ko': '구매',
  });

  String get youHaveSubscription => _t({
    'en': 'You have this subscription',
    'ar': 'لديك هذا الاشتراك',
    'fr': 'Vous avez cet abonnement',
    'es': 'Tienes esta suscripción',
    'ko': '이 구독이 있습니다',
  });

  String get addThisSubscription => _t({
    'en': 'Add this subscription?',
    'ar': 'إضافة هذا الاشتراك؟',
    'fr': 'Ajouter cet abonnement ?',
    'es': '¿Añadir esta suscripción?',
    'ko': '이 구독을 추가하시겠습니까?',
  });

  String get noResultsFound => _t({
    'en': 'No results found',
    'ar': 'لم يتم العثور على نتائج',
    'fr': 'Aucun résultat trouvé',
    'es': 'No se encontraron resultados',
    'ko': '결과를 찾을 수 없습니다',
  });

  String get tryDifferentSearch => _t({
    'en': 'Try a different search term',
    'ar': 'جرب مصطلح بحث مختلف',
    'fr': 'Essayez un autre terme de recherche',
    'es': 'Prueba con otro término de búsqueda',
    'ko': '다른 검색어를 시도해 보세요',
  });

  String get findWhereToWatch => _t({
    'en': 'Find where to watch your favorite\nmovies and TV shows',
    'ar': 'اعثر على مكان مشاهدة أفلامك\nومسلسلاتك المفضلة',
    'fr': 'Trouvez où regarder vos films\net séries préférés',
    'es': 'Encuentra dónde ver tus películas\ny series favoritas',
    'ko': '좋아하는 영화와 TV 프로그램을\n어디서 볼 수 있는지 찾아보세요',
  });

  // Music Search Screen
  String get musicSearch => _t({
    'en': 'Music Search',
    'ar': 'بحث الموسيقى',
    'fr': 'Recherche musicale',
    'es': 'Búsqueda de música',
    'ko': '음악 검색',
  });

  String get searchSongsAndArtists => _t({
    'en': 'Search songs, artists...',
    'ar': 'ابحث عن الأغاني والفنانين...',
    'fr': 'Rechercher des chansons, artistes...',
    'es': 'Buscar canciones, artistas...',
    'ko': '노래, 아티스트 검색...',
  });

  String get topCharts => _t({
    'en': 'Top Charts',
    'ar': 'أفضل الأغاني',
    'fr': 'Top des charts',
    'es': 'Más populares',
    'ko': '인기 차트',
  });

  String get findYourMusic => _t({
    'en': 'Search for your favorite songs\nand find where to listen',
    'ar': 'ابحث عن أغانيك المفضلة\nواكتشف أين تستمع',
    'fr': 'Recherchez vos chansons préférées\net trouvez où les écouter',
    'es': 'Busca tus canciones favoritas\ny encuentra dónde escucharlas',
    'ko': '좋아하는 노래를 검색하고\n어디서 들을 수 있는지 찾아보세요',
  });

  String get listenOn => _t({
    'en': 'Listen on',
    'ar': 'استمع على',
    'fr': 'Écouter sur',
    'es': 'Escuchar en',
    'ko': '듣기',
  });

  // Deals Screen
  String get deals => _t({
    'en': 'Deals & Offers',
    'ar': 'العروض والخصومات',
    'fr': 'Offres et réductions',
    'es': 'Ofertas y descuentos',
    'ko': '할인 및 혜택',
  });

  String get allDeals => _t({
    'en': 'All',
    'ar': 'الكل',
    'fr': 'Tout',
    'es': 'Todo',
    'ko': '전체',
  });

  String get noDealsFound => _t({
    'en': 'No deals found',
    'ar': 'لم يتم العثور على عروض',
    'fr': 'Aucune offre trouvée',
    'es': 'No se encontraron ofertas',
    'ko': '할인을 찾을 수 없습니다',
  });

  String get affiliateDisclosure => _t({
    'en': 'We may earn a commission from purchases made through these links. This helps support our app at no extra cost to you.',
    'ar': 'قد نحصل على عمولة من المشتريات عبر هذه الروابط. هذا يساعد في دعم تطبيقنا دون أي تكلفة إضافية عليك.',
    'fr': 'Nous pouvons percevoir une commission sur les achats effectués via ces liens. Cela nous aide à soutenir notre application sans frais supplémentaires pour vous.',
    'es': 'Podemos ganar una comisión de las compras realizadas a través de estos enlaces. Esto ayuda a mantener nuestra aplicación sin costo adicional para ti.',
    'ko': '이 링크를 통한 구매에서 수수료를 받을 수 있습니다. 이는 추가 비용 없이 앱을 지원하는 데 도움이 됩니다.',
  });

  String get getDeal => _t({
    'en': 'Get Deal',
    'ar': 'احصل على العرض',
    'fr': 'Obtenir l\'offre',
    'es': 'Obtener oferta',
    'ko': '할인 받기',
  });

  // Region-based deals
  String get showingDealsFor => _t({
    'en': 'Showing deals for',
    'ar': 'عرض العروض لـ',
    'fr': 'Offres pour',
    'es': 'Mostrando ofertas para',
    'ko': '다음 지역의 할인',
  });

  String get showingAllDeals => _t({
    'en': 'Showing all deals worldwide',
    'ar': 'عرض جميع العروض في العالم',
    'fr': 'Affichage de toutes les offres mondiales',
    'es': 'Mostrando todas las ofertas mundiales',
    'ko': '전 세계 모든 할인 표시',
  });

  String get showAllDeals => _t({
    'en': 'Show all deals',
    'ar': 'عرض جميع العروض',
    'fr': 'Afficher toutes les offres',
    'es': 'Mostrar todas las ofertas',
    'ko': '모든 할인 보기',
  });

  String get yourLocation => _t({
    'en': 'Your Location',
    'ar': 'موقعك',
    'fr': 'Votre emplacement',
    'es': 'Tu ubicación',
    'ko': '내 위치',
  });

  String get regionExplanation => _t({
    'en': 'We detect your location to show deals available in your region. Some deals are only available in certain countries. Turn off the filter to see all deals worldwide.',
    'ar': 'نكتشف موقعك لعرض العروض المتاحة في منطقتك. بعض العروض متاحة فقط في بلدان معينة. أوقف الفلتر لرؤية جميع العروض العالمية.',
    'fr': 'Nous détectons votre emplacement pour afficher les offres disponibles dans votre région. Certaines offres ne sont disponibles que dans certains pays. Désactivez le filtre pour voir toutes les offres mondiales.',
    'es': 'Detectamos tu ubicación para mostrar ofertas disponibles en tu región. Algunas ofertas solo están disponibles en ciertos países. Desactiva el filtro para ver todas las ofertas mundiales.',
    'ko': '지역에서 사용 가능한 할인을 표시하기 위해 위치를 감지합니다. 일부 할인은 특정 국가에서만 사용 가능합니다. 필터를 끄면 전 세계 모든 할인을 볼 수 있습니다.',
  });

  String get refreshLocation => _t({
    'en': 'Refresh Location',
    'ar': 'تحديث الموقع',
    'fr': 'Actualiser la position',
    'es': 'Actualizar ubicación',
    'ko': '위치 새로고침',
  });

  // ==================== PREMIUM FEATURES ====================

  // Invite Friends / Referral
  String get inviteFriends => _t({
    'en': 'Invite Friends',
    'ar': 'دعوة الأصدقاء',
    'fr': 'Inviter des amis',
    'es': 'Invitar amigos',
    'ko': '친구 초대',
  });

  String get premiumActive => _t({
    'en': 'Premium Active',
    'ar': 'بريميوم نشط',
    'fr': 'Premium Actif',
    'es': 'Premium Activo',
    'ko': '프리미엄 활성',
  });

  String get freePlan => _t({
    'en': 'Free Plan',
    'ar': 'الخطة المجانية',
    'fr': 'Plan Gratuit',
    'es': 'Plan Gratis',
    'ko': '무료 플랜',
  });

  String get lifetimePremium => _t({
    'en': 'Lifetime Premium',
    'ar': 'بريميوم مدى الحياة',
    'fr': 'Premium à vie',
    'es': 'Premium de por vida',
    'ko': '평생 프리미엄',
  });

  String daysRemaining(int days) => _t({
    'en': '$days days remaining',
    'ar': '$days يوم متبقي',
    'fr': '$days jours restants',
    'es': '$days días restantes',
    'ko': '$days일 남음',
  });

  String get inviteToGetPremium => _t({
    'en': 'Invite friends to get free Premium!',
    'ar': 'ادعُ أصدقاءك للحصول على بريميوم مجاني!',
    'fr': 'Invitez des amis pour obtenir Premium gratuit!',
    'es': '¡Invita amigos para obtener Premium gratis!',
    'ko': '친구를 초대하고 무료 프리미엄을 받으세요!',
  });

  String get yourReferralCode => _t({
    'en': 'Your Referral Code',
    'ar': 'رمز الإحالة الخاص بك',
    'fr': 'Votre code de parrainage',
    'es': 'Tu código de referido',
    'ko': '당신의 추천 코드',
  });

  String get copyCode => _t({
    'en': 'Copy Code',
    'ar': 'نسخ الرمز',
    'fr': 'Copier le code',
    'es': 'Copiar código',
    'ko': '코드 복사',
  });

  String get share => _t({
    'en': 'Share',
    'ar': 'مشاركة',
    'fr': 'Partager',
    'es': 'Compartir',
    'ko': '공유',
  });

  String get howItWorks => _t({
    'en': 'How It Works',
    'ar': 'كيف تعمل',
    'fr': 'Comment ça marche',
    'es': 'Cómo funciona',
    'ko': '이용 방법',
  });

  String get step1Title => _t({
    'en': 'Share your code',
    'ar': 'شارك رمزك',
    'fr': 'Partagez votre code',
    'es': 'Comparte tu código',
    'ko': '코드 공유하기',
  });

  String get step1Description => _t({
    'en': 'Send your unique code to friends',
    'ar': 'أرسل رمزك الفريد للأصدقاء',
    'fr': 'Envoyez votre code unique à vos amis',
    'es': 'Envía tu código único a amigos',
    'ko': '친구에게 고유 코드를 보내세요',
  });

  String get step2Title => _t({
    'en': 'Friend signs up',
    'ar': 'صديقك يسجل',
    'fr': 'Ami s\'inscrit',
    'es': 'Amigo se registra',
    'ko': '친구가 가입',
  });

  String get step2Description => _t({
    'en': 'They enter your code when joining',
    'ar': 'يدخلون رمزك عند الانضمام',
    'fr': 'Ils entrent votre code en s\'inscrivant',
    'es': 'Ingresan tu código al unirse',
    'ko': '가입 시 코드를 입력합니다',
  });

  String get step3Title => _t({
    'en': 'Both get Premium',
    'ar': 'كلاكما يحصل على بريميوم',
    'fr': 'Les deux obtiennent Premium',
    'es': 'Ambos obtienen Premium',
    'ko': '둘 다 프리미엄 획득',
  });

  String get step3Description => _t({
    'en': 'You and your friend each get 7 days of Premium!',
    'ar': 'أنت وصديقك تحصلان على 7 أيام بريميوم!',
    'fr': 'Vous et votre ami obtenez chacun 7 jours de Premium!',
    'es': '¡Tú y tu amigo obtienen 7 días de Premium!',
    'ko': '당신과 친구 모두 7일 프리미엄을 받습니다!',
  });

  String get friendsInvited => _t({
    'en': 'Friends Invited',
    'ar': 'الأصدقاء المدعوون',
    'fr': 'Amis invités',
    'es': 'Amigos invitados',
    'ko': '초대한 친구',
  });

  String get daysEarned => _t({
    'en': 'Days Earned',
    'ar': 'الأيام المكتسبة',
    'fr': 'Jours gagnés',
    'es': 'Días ganados',
    'ko': '획득한 일수',
  });

  String get haveReferralCode => _t({
    'en': 'Have a referral code?',
    'ar': 'لديك رمز إحالة؟',
    'fr': 'Avez-vous un code de parrainage?',
    'es': '¿Tienes un código de referido?',
    'ko': '추천 코드가 있으신가요?',
  });

  String get enterCode => _t({
    'en': 'Enter code',
    'ar': 'أدخل الرمز',
    'fr': 'Entrer le code',
    'es': 'Ingresa el código',
    'ko': '코드 입력',
  });

  String get apply => _t({
    'en': 'Apply',
    'ar': 'تطبيق',
    'fr': 'Appliquer',
    'es': 'Aplicar',
    'ko': '적용',
  });

  String shareMessage(String code) => _t({
    'en': 'Join Subscription Alert and track your subscriptions! Use my referral code "$code" to get 7 days of Premium for free! Download: https://example.com/app',
    'ar': 'انضم إلى Subscription Alert وتتبع اشتراكاتك! استخدم رمز الإحالة "$code" للحصول على 7 أيام بريميوم مجاناً! التحميل: https://example.com/app',
    'fr': 'Rejoignez Subscription Alert et suivez vos abonnements! Utilisez mon code "$code" pour 7 jours de Premium gratuit! Télécharger: https://example.com/app',
    'es': '¡Únete a Subscription Alert y rastrea tus suscripciones! Usa mi código "$code" para obtener 7 días de Premium gratis! Descargar: https://example.com/app',
    'ko': 'Subscription Alert에 가입하고 구독을 추적하세요! 내 추천 코드 "$code"를 사용하면 7일 프리미엄을 무료로 받을 수 있습니다! 다운로드: https://example.com/app',
  });

  // Premium Currency Conversion
  String get upgradeToPremiumConversion => _t({
    'en': 'Upgrade to Premium to see total in one currency',
    'ar': 'قم بالترقية لرؤية المجموع بعملة واحدة',
    'fr': 'Passez à Premium pour voir le total en une devise',
    'es': 'Actualiza a Premium para ver el total en una moneda',
    'ko': '프리미엄으로 업그레이드하여 한 통화로 총액 보기',
  });

  String get baseCurrency => _t({
    'en': 'Base Currency',
    'ar': 'العملة الأساسية',
    'fr': 'Devise de base',
    'es': 'Moneda base',
    'ko': '기준 통화',
  });

  String get selectBaseCurrency => _t({
    'en': 'Select your base currency',
    'ar': 'اختر عملتك الأساسية',
    'fr': 'Sélectionnez votre devise de base',
    'es': 'Selecciona tu moneda base',
    'ko': '기준 통화를 선택하세요',
  });

  String get currencyConversionPremium => _t({
    'en': 'Currency conversion is a Premium feature',
    'ar': 'تحويل العملات ميزة بريميوم',
    'fr': 'La conversion de devises est une fonctionnalité Premium',
    'es': 'La conversión de moneda es una función Premium',
    'ko': '통화 변환은 프리미엄 기능입니다',
  });

  // Theme Settings
  String get theme => _t({
    'en': 'Theme',
    'ar': 'المظهر',
    'fr': 'Thème',
    'es': 'Tema',
    'ko': '테마',
  });

  String get systemDefault => _t({
    'en': 'System Default',
    'ar': 'افتراضي النظام',
    'fr': 'Par défaut du système',
    'es': 'Por defecto del sistema',
    'ko': '시스템 기본값',
  });

  String get lightMode => _t({
    'en': 'Light',
    'ar': 'فاتح',
    'fr': 'Clair',
    'es': 'Claro',
    'ko': '라이트',
  });

  String get darkMode => _t({
    'en': 'Dark',
    'ar': 'داكن',
    'fr': 'Sombre',
    'es': 'Oscuro',
    'ko': '다크',
  });

  String get themePremiumOnly => _t({
    'en': 'Manual theme selection is a Premium feature',
    'ar': 'اختيار المظهر يدوياً ميزة بريميوم',
    'fr': 'La sélection manuelle du thème est une fonctionnalité Premium',
    'es': 'La selección manual del tema es una función Premium',
    'ko': '수동 테마 선택은 프리미엄 기능입니다',
  });

  // Calendar Sync
  String get calendarSync => _t({
    'en': 'Calendar Sync',
    'ar': 'مزامنة التقويم',
    'fr': 'Sync Calendrier',
    'es': 'Sincronizar Calendario',
    'ko': '캘린더 동기화',
  });

  String get connectCalendar => _t({
    'en': 'Connect Calendar',
    'ar': 'ربط التقويم',
    'fr': 'Connecter le calendrier',
    'es': 'Conectar calendario',
    'ko': '캘린더 연결',
  });

  String get calendarSyncDescription => _t({
    'en': 'Sync your subscription renewals with your calendar',
    'ar': 'مزامنة تجديدات اشتراكاتك مع تقويمك',
    'fr': 'Synchronisez vos renouvellements avec votre calendrier',
    'es': 'Sincroniza tus renovaciones con tu calendario',
    'ko': '구독 갱신을 캘린더와 동기화',
  });

  String get calendarSyncPremiumOnly => _t({
    'en': 'Calendar sync is a Premium feature',
    'ar': 'مزامنة التقويم ميزة بريميوم',
    'fr': 'La sync calendrier est une fonctionnalité Premium',
    'es': 'La sincronización de calendario es una función Premium',
    'ko': '캘린더 동기화는 프리미엄 기능입니다',
  });

  // Premium General
  String get premium => _t({
    'en': 'Premium',
    'ar': 'بريميوم',
    'fr': 'Premium',
    'es': 'Premium',
    'ko': '프리미엄',
  });

  String get upgradeToPremium => _t({
    'en': 'Upgrade to Premium',
    'ar': 'الترقية إلى بريميوم',
    'fr': 'Passer à Premium',
    'es': 'Actualizar a Premium',
    'ko': '프리미엄으로 업그레이드',
  });

  String get premiumFeatures => _t({
    'en': 'Premium Features',
    'ar': 'ميزات بريميوم',
    'fr': 'Fonctionnalités Premium',
    'es': 'Funciones Premium',
    'ko': '프리미엄 기능',
  });

  String get premiumFeature => _t({
    'en': 'Premium Feature',
    'ar': 'ميزة بريميوم',
    'fr': 'Fonctionnalité Premium',
    'es': 'Función Premium',
    'ko': '프리미엄 기능',
  });

  String get removeAds => _t({
    'en': 'Remove Ads',
    'ar': 'إزالة الإعلانات',
    'fr': 'Supprimer les publicités',
    'es': 'Eliminar anuncios',
    'ko': '광고 제거',
  });

  String get oneTimePurchase => _t({
    'en': 'One-time purchase',
    'ar': 'شراء لمرة واحدة',
    'fr': 'Achat unique',
    'es': 'Compra única',
    'ko': '일회성 구매',
  });

  // Reports
  String get reports => _t({
    'en': 'Reports',
    'ar': 'التقارير',
    'fr': 'Rapports',
    'es': 'Informes',
    'ko': '보고서',
  });

  String get generateReport => _t({
    'en': 'Generate Report',
    'ar': 'إنشاء تقرير',
    'fr': 'Générer un rapport',
    'es': 'Generar informe',
    'ko': '보고서 생성',
  });

  String get monthlyReport => _t({
    'en': 'Monthly Report',
    'ar': 'تقرير شهري',
    'fr': 'Rapport mensuel',
    'es': 'Informe mensual',
    'ko': '월간 보고서',
  });

  String get yearlyReport => _t({
    'en': 'Yearly Report',
    'ar': 'تقرير سنوي',
    'fr': 'Rapport annuel',
    'es': 'Informe anual',
    'ko': '연간 보고서',
  });

  String get customDateRange => _t({
    'en': 'Custom Date Range',
    'ar': 'نطاق تاريخ مخصص',
    'fr': 'Plage de dates personnalisée',
    'es': 'Rango de fechas personalizado',
    'ko': '사용자 정의 날짜 범위',
  });

  String get reportGeneratedSuccess => _t({
    'en': 'Report generated successfully!',
    'ar': 'تم إنشاء التقرير بنجاح!',
    'fr': 'Rapport généré avec succès!',
    'es': '¡Informe generado con éxito!',
    'ko': '보고서가 성공적으로 생성되었습니다!',
  });

  // Trial Guard
  String get freeTrial => _t({
    'en': 'Free Trial',
    'ar': 'تجربة مجانية',
    'fr': 'Essai gratuit',
    'es': 'Prueba gratuita',
    'ko': '무료 체험',
  });

  String get trialSubscription => _t({
    'en': 'Trial Subscription',
    'ar': 'اشتراك تجريبي',
    'fr': 'Abonnement d\'essai',
    'es': 'Suscripción de prueba',
    'ko': '체험 구독',
  });

  String get trialEndsOn => _t({
    'en': 'Trial ends on',
    'ar': 'تنتهي التجربة في',
    'fr': 'L\'essai se termine le',
    'es': 'La prueba termina el',
    'ko': '체험 종료일',
  });

  String get trialEndDate => _t({
    'en': 'Trial End Date',
    'ar': 'تاريخ انتهاء التجربة',
    'fr': 'Date de fin d\'essai',
    'es': 'Fecha de fin de prueba',
    'ko': '체험 종료 날짜',
  });

  String get trialExpiresTomorrow => _t({
    'en': 'Trial expires tomorrow!',
    'ar': 'تنتهي التجربة غداً!',
    'fr': 'L\'essai expire demain!',
    'es': '¡La prueba expira mañana!',
    'ko': '체험이 내일 종료됩니다!',
  });

  String trialExpiresInDays(int days) => _t({
    'en': 'Trial expires in $days days',
    'ar': 'تنتهي التجربة خلال $days أيام',
    'fr': 'L\'essai expire dans $days jours',
    'es': 'La prueba expira en $days días',
    'ko': '$days일 후 체험 종료',
  });

  String get trialExpired => _t({
    'en': 'Trial Expired',
    'ar': 'انتهت التجربة',
    'fr': 'Essai expiré',
    'es': 'Prueba expirada',
    'ko': '체험 만료됨',
  });

  String get markAsTrial => _t({
    'en': 'This is a free trial',
    'ar': 'هذه تجربة مجانية',
    'fr': 'C\'est un essai gratuit',
    'es': 'Esta es una prueba gratuita',
    'ko': '무료 체험입니다',
  });

  String get trialWarningTitle => _t({
    'en': 'Trial Expiring Soon!',
    'ar': 'التجربة تنتهي قريباً!',
    'fr': 'L\'essai expire bientôt!',
    'es': '¡La prueba expira pronto!',
    'ko': '체험이 곧 종료됩니다!',
  });

  String trialWarningBody(String name, int days) => _t({
    'en': 'Your $name trial expires in $days day${days == 1 ? '' : 's'}. Cancel now to avoid charges.',
    'ar': 'تنتهي تجربة $name خلال $days يوم${days == 1 ? '' : 'اً'}. قم بالإلغاء الآن لتجنب الرسوم.',
    'fr': 'Votre essai $name expire dans $days jour${days == 1 ? '' : 's'}. Annulez maintenant pour éviter les frais.',
    'es': 'Tu prueba de $name expira en $days día${days == 1 ? '' : 's'}. Cancela ahora para evitar cargos.',
    'ko': '$name 체험이 $days일 후 종료됩니다. 요금 청구를 피하려면 지금 취소하세요.',
  });

  // ==================== TIMELINE FEATURE ====================

  String get timeline => _t({
    'en': 'Timeline',
    'ar': 'الجدول الزمني',
    'fr': 'Chronologie',
    'es': 'Cronología',
    'ko': '타임라인',
  });

  String get paymentTimeline => _t({
    'en': 'Payment Timeline',
    'ar': 'جدول المدفوعات',
    'fr': 'Chronologie des paiements',
    'es': 'Cronología de pagos',
    'ko': '결제 타임라인',
  });

  String get noTimelineData => _t({
    'en': 'No timeline data',
    'ar': 'لا توجد بيانات',
    'fr': 'Pas de données',
    'es': 'Sin datos',
    'ko': '타임라인 데이터 없음',
  });

  String get addSubscriptionsToSeeTimeline => _t({
    'en': 'Add subscriptions to see your payment timeline',
    'ar': 'أضف اشتراكات لرؤية جدول المدفوعات',
    'fr': 'Ajoutez des abonnements pour voir votre chronologie',
    'es': 'Añade suscripciones para ver tu cronología',
    'ko': '결제 타임라인을 보려면 구독을 추가하세요',
  });

  String get pastSpending => _t({
    'en': 'Past Spending',
    'ar': 'الإنفاق السابق',
    'fr': 'Dépenses passées',
    'es': 'Gastos pasados',
    'ko': '과거 지출',
  });

  String get upcomingSpending => _t({
    'en': 'Upcoming',
    'ar': 'القادم',
    'fr': 'À venir',
    'es': 'Próximo',
    'ko': '예정',
  });

  String lastMonths(int count) => _t({
    'en': 'Last $count months',
    'ar': 'آخر $count أشهر',
    'fr': '$count derniers mois',
    'es': 'Últimos $count meses',
    'ko': '지난 $count개월',
  });

  String nextPaymentIn(int days) => _t({
    'en': 'Next payment in $days day${days == 1 ? '' : 's'}',
    'ar': 'الدفعة التالية خلال $days يوم',
    'fr': 'Prochain paiement dans $days jour${days == 1 ? '' : 's'}',
    'es': 'Próximo pago en $days día${days == 1 ? '' : 's'}',
    'ko': '$days일 후 다음 결제',
  });

  String get noUpcomingPayments => _t({
    'en': 'No upcoming payments',
    'ar': 'لا توجد مدفوعات قادمة',
    'fr': 'Pas de paiements à venir',
    'es': 'Sin pagos próximos',
    'ko': '예정된 결제 없음',
  });

  String get unlockFullTimeline => _t({
    'en': 'Unlock Full Timeline',
    'ar': 'فتح الجدول الكامل',
    'fr': 'Débloquer la chronologie complète',
    'es': 'Desbloquear cronología completa',
    'ko': '전체 타임라인 잠금 해제',
  });

  String get timelinePremiumDescription => _t({
    'en': 'See up to 12 months of history and 6 months of upcoming payments',
    'ar': 'شاهد حتى 12 شهرًا من السجل و 6 أشهر من المدفوعات القادمة',
    'fr': 'Voir jusqu\'à 12 mois d\'historique et 6 mois de paiements à venir',
    'es': 'Ver hasta 12 meses de historial y 6 meses de pagos próximos',
    'ko': '최대 12개월 기록과 6개월 예정 결제 보기',
  });

  String get upgrade => _t({
    'en': 'Upgrade',
    'ar': 'ترقية',
    'fr': 'Mettre à niveau',
    'es': 'Mejorar',
    'ko': '업그레이드',
  });

  // ==================== WISHLISTS FEATURE ====================

  String get wishlist => _t({
    'en': 'Wishlist',
    'ar': 'قائمة الرغبات',
    'fr': 'Liste de souhaits',
    'es': 'Lista de deseos',
    'ko': '위시리스트',
  });

  String get wishlists => _t({
    'en': 'Wishlists',
    'ar': 'قوائم الرغبات',
    'fr': 'Listes de souhaits',
    'es': 'Listas de deseos',
    'ko': '위시리스트',
  });

  String get noWishlists => _t({
    'en': 'No wishlists yet',
    'ar': 'لا توجد قوائم رغبات',
    'fr': 'Pas encore de listes',
    'es': 'Sin listas aún',
    'ko': '아직 위시리스트가 없습니다',
  });

  String get createWishlistToStart => _t({
    'en': 'Create your first wishlist to save subscription ideas',
    'ar': 'أنشئ قائمتك الأولى لحفظ أفكار الاشتراكات',
    'fr': 'Créez votre première liste pour sauvegarder des idées',
    'es': 'Crea tu primera lista para guardar ideas de suscripciones',
    'ko': '구독 아이디어를 저장할 첫 번째 위시리스트를 만드세요',
  });

  String get createFirstWishlist => _t({
    'en': 'Create First Wishlist',
    'ar': 'إنشاء أول قائمة',
    'fr': 'Créer la première liste',
    'es': 'Crear primera lista',
    'ko': '첫 번째 위시리스트 만들기',
  });

  String get newWishlist => _t({
    'en': 'New Wishlist',
    'ar': 'قائمة جديدة',
    'fr': 'Nouvelle liste',
    'es': 'Nueva lista',
    'ko': '새 위시리스트',
  });

  String get createWishlist => _t({
    'en': 'Create Wishlist',
    'ar': 'إنشاء قائمة',
    'fr': 'Créer une liste',
    'es': 'Crear lista',
    'ko': '위시리스트 만들기',
  });

  String get editWishlist => _t({
    'en': 'Edit Wishlist',
    'ar': 'تعديل القائمة',
    'fr': 'Modifier la liste',
    'es': 'Editar lista',
    'ko': '위시리스트 수정',
  });

  String get deleteWishlist => _t({
    'en': 'Delete Wishlist',
    'ar': 'حذف القائمة',
    'fr': 'Supprimer la liste',
    'es': 'Eliminar lista',
    'ko': '위시리스트 삭제',
  });

  String deleteWishlistConfirmation(String name) => _t({
    'en': 'Are you sure you want to delete "$name"? All items will be removed.',
    'ar': 'هل أنت متأكد من حذف "$name"؟ سيتم حذف جميع العناصر.',
    'fr': 'Êtes-vous sûr de vouloir supprimer "$name" ? Tous les éléments seront supprimés.',
    'es': '¿Estás seguro de que quieres eliminar "$name"? Todos los elementos serán eliminados.',
    'ko': '"$name"을(를) 삭제하시겠습니까? 모든 항목이 삭제됩니다.',
  });

  String get wishlistName => _t({
    'en': 'Wishlist Name',
    'ar': 'اسم القائمة',
    'fr': 'Nom de la liste',
    'es': 'Nombre de la lista',
    'ko': '위시리스트 이름',
  });

  String get wishlistNameHint => _t({
    'en': 'e.g., Services to try, Future subscriptions...',
    'ar': 'مثال: خدمات للتجربة، اشتراكات مستقبلية...',
    'fr': 'ex: Services à essayer, Abonnements futurs...',
    'es': 'ej: Servicios a probar, Suscripciones futuras...',
    'ko': '예: 시도할 서비스, 미래 구독...',
  });

  String get description => _t({
    'en': 'Description',
    'ar': 'الوصف',
    'fr': 'Description',
    'es': 'Descripción',
    'ko': '설명',
  });

  String get wishlistDescriptionHint => _t({
    'en': 'Add an optional description...',
    'ar': 'أضف وصفًا اختياريًا...',
    'fr': 'Ajoutez une description optionnelle...',
    'es': 'Añade una descripción opcional...',
    'ko': '선택적 설명 추가...',
  });

  String get create => _t({
    'en': 'Create',
    'ar': 'إنشاء',
    'fr': 'Créer',
    'es': 'Crear',
    'ko': '만들기',
  });

  String get wishlistCreated => _t({
    'en': 'Wishlist created',
    'ar': 'تم إنشاء القائمة',
    'fr': 'Liste créée',
    'es': 'Lista creada',
    'ko': '위시리스트 생성됨',
  });

  String get wishlistUpdated => _t({
    'en': 'Wishlist updated',
    'ar': 'تم تحديث القائمة',
    'fr': 'Liste mise à jour',
    'es': 'Lista actualizada',
    'ko': '위시리스트 업데이트됨',
  });

  String get wishlistDeleted => _t({
    'en': 'Wishlist deleted',
    'ar': 'تم حذف القائمة',
    'fr': 'Liste supprimée',
    'es': 'Lista eliminada',
    'ko': '위시리스트 삭제됨',
  });

  String wishlistLimitInfo(int current, int max) => _t({
    'en': 'You have $current of $max wishlists',
    'ar': 'لديك $current من $max قوائم',
    'fr': 'Vous avez $current sur $max listes',
    'es': 'Tienes $current de $max listas',
    'ko': '$max개 중 $current개 위시리스트',
  });

  String get noItemsInWishlist => _t({
    'en': 'No items yet',
    'ar': 'لا توجد عناصر',
    'fr': 'Pas d\'éléments',
    'es': 'Sin elementos',
    'ko': '아직 항목이 없습니다',
  });

  String get addItemsToWishlist => _t({
    'en': 'Add subscription ideas to this wishlist',
    'ar': 'أضف أفكار الاشتراكات لهذه القائمة',
    'fr': 'Ajoutez des idées d\'abonnements à cette liste',
    'es': 'Añade ideas de suscripciones a esta lista',
    'ko': '이 위시리스트에 구독 아이디어 추가',
  });

  String get addItem => _t({
    'en': 'Add Item',
    'ar': 'إضافة عنصر',
    'fr': 'Ajouter un élément',
    'es': 'Añadir elemento',
    'ko': '항목 추가',
  });

  String get addToWishlist => _t({
    'en': 'Add to Wishlist',
    'ar': 'إضافة للقائمة',
    'fr': 'Ajouter à la liste',
    'es': 'Añadir a lista',
    'ko': '위시리스트에 추가',
  });

  String get serviceName => _t({
    'en': 'Service Name',
    'ar': 'اسم الخدمة',
    'fr': 'Nom du service',
    'es': 'Nombre del servicio',
    'ko': '서비스 이름',
  });

  String get serviceNameHint => _t({
    'en': 'e.g., Netflix, Spotify...',
    'ar': 'مثال: نتفليكس، سبوتيفاي...',
    'fr': 'ex: Netflix, Spotify...',
    'es': 'ej: Netflix, Spotify...',
    'ko': '예: Netflix, Spotify...',
  });

  String get estimatedPrice => _t({
    'en': 'Estimated Price',
    'ar': 'السعر التقديري',
    'fr': 'Prix estimé',
    'es': 'Precio estimado',
    'ko': '예상 가격',
  });

  String get estimatedPriceHint => _t({
    'en': 'Monthly cost',
    'ar': 'التكلفة الشهرية',
    'fr': 'Coût mensuel',
    'es': 'Costo mensual',
    'ko': '월 비용',
  });

  String get note => _t({
    'en': 'Note',
    'ar': 'ملاحظة',
    'fr': 'Note',
    'es': 'Nota',
    'ko': '메모',
  });

  String get noteHint => _t({
    'en': 'Why you want this subscription...',
    'ar': 'لماذا تريد هذا الاشتراك...',
    'fr': 'Pourquoi voulez-vous cet abonnement...',
    'es': 'Por qué quieres esta suscripción...',
    'ko': '이 구독을 원하는 이유...',
  });

  String get itemAdded => _t({
    'en': 'Item added',
    'ar': 'تمت الإضافة',
    'fr': 'Élément ajouté',
    'es': 'Elemento añadido',
    'ko': '항목 추가됨',
  });

  String get itemRemoved => _t({
    'en': 'Item removed',
    'ar': 'تم الحذف',
    'fr': 'Élément supprimé',
    'es': 'Elemento eliminado',
    'ko': '항목 삭제됨',
  });

  String itemsLimitInfo(int current, int max) => _t({
    'en': '$current of $max items',
    'ar': '$current من $max عناصر',
    'fr': '$current sur $max éléments',
    'es': '$current de $max elementos',
    'ko': '$max개 중 $current개 항목',
  });

  String get wishlistPremiumBenefits => _t({
    'en': 'Upgrade to Premium to unlock all wishlist features:',
    'ar': 'قم بالترقية لفتح جميع ميزات القوائم:',
    'fr': 'Passez à Premium pour débloquer toutes les fonctionnalités:',
    'es': 'Actualiza a Premium para desbloquear todas las funciones:',
    'ko': '모든 위시리스트 기능을 잠금 해제하려면 프리미엄으로 업그레이드하세요:',
  });

  String get unlimitedWishlists => _t({
    'en': 'Unlimited wishlists',
    'ar': 'قوائم غير محدودة',
    'fr': 'Listes illimitées',
    'es': 'Listas ilimitadas',
    'ko': '무제한 위시리스트',
  });

  String get unlimitedItemsPerList => _t({
    'en': 'Unlimited items per list',
    'ar': 'عناصر غير محدودة لكل قائمة',
    'fr': 'Éléments illimités par liste',
    'es': 'Elementos ilimitados por lista',
    'ko': '목록당 무제한 항목',
  });

  String get moveItemsBetweenLists => _t({
    'en': 'Move items between lists',
    'ar': 'نقل العناصر بين القوائم',
    'fr': 'Déplacer des éléments entre listes',
    'es': 'Mover elementos entre listas',
    'ko': '목록 간 항목 이동',
  });

  String get maybeLater => _t({
    'en': 'Maybe Later',
    'ar': 'ربما لاحقاً',
    'fr': 'Peut-être plus tard',
    'es': 'Quizás más tarde',
    'ko': '나중에',
  });

  String get error => _t({
    'en': 'Error',
    'ar': 'خطأ',
    'fr': 'Erreur',
    'es': 'Error',
    'ko': '오류',
  });

  // ==================== SPEND HEALTH FEATURE ====================

  String get spendHealth => _t({
    'en': 'Spend Health',
    'ar': 'صحة الإنفاق',
    'fr': 'Santé des dépenses',
    'es': 'Salud de gastos',
    'ko': '지출 건강',
  });

  String get excellentHealth => _t({
    'en': 'Excellent',
    'ar': 'ممتاز',
    'fr': 'Excellent',
    'es': 'Excelente',
    'ko': '훌륭함',
  });

  String get goodHealth => _t({
    'en': 'Good',
    'ar': 'جيد',
    'fr': 'Bien',
    'es': 'Bueno',
    'ko': '좋음',
  });

  String get warningHealth => _t({
    'en': 'Needs Attention',
    'ar': 'يحتاج اهتمام',
    'fr': 'Attention requise',
    'es': 'Necesita atención',
    'ko': '주의 필요',
  });

  String get criticalHealth => _t({
    'en': 'Critical',
    'ar': 'حرج',
    'fr': 'Critique',
    'es': 'Crítico',
    'ko': '심각',
  });

  String get excellentHealthDesc => _t({
    'en': 'Your subscription spending is well optimized!',
    'ar': 'إنفاقك على الاشتراكات محسّن جيداً!',
    'fr': 'Vos dépenses d\'abonnement sont bien optimisées!',
    'es': '¡Tu gasto en suscripciones está bien optimizado!',
    'ko': '구독 지출이 잘 최적화되어 있습니다!',
  });

  String get goodHealthDesc => _t({
    'en': 'Your spending is healthy with minor improvements possible',
    'ar': 'إنفاقك صحي مع إمكانية تحسينات طفيفة',
    'fr': 'Vos dépenses sont saines avec des améliorations mineures possibles',
    'es': 'Tu gasto es saludable con mejoras menores posibles',
    'ko': '지출이 건강하며 약간의 개선이 가능합니다',
  });

  String get warningHealthDesc => _t({
    'en': 'Consider reviewing your subscriptions',
    'ar': 'فكر في مراجعة اشتراكاتك',
    'fr': 'Pensez à revoir vos abonnements',
    'es': 'Considera revisar tus suscripciones',
    'ko': '구독을 검토해 보세요',
  });

  String get criticalHealthDesc => _t({
    'en': 'Your spending needs immediate attention',
    'ar': 'إنفاقك يحتاج اهتمام فوري',
    'fr': 'Vos dépenses nécessitent une attention immédiate',
    'es': 'Tu gasto necesita atención inmediata',
    'ko': '지출에 즉각적인 주의가 필요합니다',
  });

  String get suggestions => _t({
    'en': 'Suggestions',
    'ar': 'اقتراحات',
    'fr': 'Suggestions',
    'es': 'Sugerencias',
    'ko': '제안',
  });

  String get noSuggestions => _t({
    'en': 'Great job! No suggestions at this time.',
    'ar': 'عمل رائع! لا توجد اقتراحات حالياً.',
    'fr': 'Bravo! Pas de suggestions pour le moment.',
    'es': '¡Buen trabajo! Sin sugerencias por ahora.',
    'ko': '잘하고 있습니다! 현재 제안이 없습니다.',
  });

  String get unlockFullAnalysis => _t({
    'en': 'Unlock Full Analysis',
    'ar': 'فتح التحليل الكامل',
    'fr': 'Débloquer l\'analyse complète',
    'es': 'Desbloquear análisis completo',
    'ko': '전체 분석 잠금 해제',
  });

  String get spendHealthPremiumDescription => _t({
    'en': 'Get detailed breakdown, score factors, and category analysis',
    'ar': 'احصل على تحليل مفصل وعوامل التقييم وتحليل الفئات',
    'fr': 'Obtenez une analyse détaillée, les facteurs de score et l\'analyse par catégorie',
    'es': 'Obtén desglose detallado, factores de puntuación y análisis por categoría',
    'ko': '상세 분석, 점수 요인 및 카테고리 분석 받기',
  });

  String get detailedAnalysis => _t({
    'en': 'Detailed Analysis',
    'ar': 'تحليل مفصل',
    'fr': 'Analyse détaillée',
    'es': 'Análisis detallado',
    'ko': '상세 분석',
  });

  String get monthlySpend => _t({
    'en': 'Monthly Spend',
    'ar': 'الإنفاق الشهري',
    'fr': 'Dépenses mensuelles',
    'es': 'Gasto mensual',
    'ko': '월간 지출',
  });

  String get yearlyProjection => _t({
    'en': 'Yearly Projection',
    'ar': 'التوقع السنوي',
    'fr': 'Projection annuelle',
    'es': 'Proyección anual',
    'ko': '연간 예상',
  });

  String get avgPerSubscription => _t({
    'en': 'Avg per Subscription',
    'ar': 'المتوسط لكل اشتراك',
    'fr': 'Moyenne par abonnement',
    'es': 'Promedio por suscripción',
    'ko': '구독당 평균',
  });

  String get categoryBreakdown => _t({
    'en': 'Category Breakdown',
    'ar': 'تفصيل الفئات',
    'fr': 'Répartition par catégorie',
    'es': 'Desglose por categoría',
    'ko': '카테고리별 분석',
  });

  String get scoreFactors => _t({
    'en': 'Score Factors',
    'ar': 'عوامل التقييم',
    'fr': 'Facteurs de score',
    'es': 'Factores de puntuación',
    'ko': '점수 요인',
  });

  // ==================== REGIONAL PRICE COMPARATOR ====================

  String get regionalPriceComparison => _t({
    'en': 'Regional Price Comparison',
    'ar': 'مقارنة الأسعار الإقليمية',
    'fr': 'Comparaison des prix régionaux',
    'es': 'Comparación de precios regionales',
    'ko': '지역별 가격 비교',
  });

  String get premiumOnlyFeature => _t({
    'en': 'Premium Feature',
    'ar': 'ميزة بريميوم',
    'fr': 'Fonctionnalité Premium',
    'es': 'Función Premium',
    'ko': '프리미엄 기능',
  });

  String regionalPriceDescription(String service) => _t({
    'en': 'Compare $service prices across different regions to find the best deals',
    'ar': 'قارن أسعار $service عبر مناطق مختلفة للعثور على أفضل العروض',
    'fr': 'Comparez les prix de $service dans différentes régions pour trouver les meilleures offres',
    'es': 'Compara los precios de $service en diferentes regiones para encontrar las mejores ofertas',
    'ko': '최고의 거래를 찾기 위해 다른 지역의 $service 가격을 비교하세요',
  });

  String get unlockNow => _t({
    'en': 'Unlock Now',
    'ar': 'فتح الآن',
    'fr': 'Débloquer maintenant',
    'es': 'Desbloquear ahora',
    'ko': '지금 잠금 해제',
  });

  String noPriceDataAvailable(String service) => _t({
    'en': 'No price data available for $service',
    'ar': 'لا تتوفر بيانات أسعار لـ $service',
    'fr': 'Pas de données de prix disponibles pour $service',
    'es': 'No hay datos de precios disponibles para $service',
    'ko': '$service에 대한 가격 데이터가 없습니다',
  });

  String get loadingPrices => _t({
    'en': 'Loading prices...',
    'ar': 'جاري تحميل الأسعار...',
    'fr': 'Chargement des prix...',
    'es': 'Cargando precios...',
    'ko': '가격 로딩 중...',
  });

  String get regionsCompared => _t({
    'en': 'regions compared',
    'ar': 'مناطق مقارنة',
    'fr': 'régions comparées',
    'es': 'regiones comparadas',
    'ko': '지역 비교됨',
  });

  String get potentialSavings => _t({
    'en': 'Save',
    'ar': 'وفر',
    'fr': 'Économisez',
    'es': 'Ahorra',
    'ko': '절약',
  });

  String cheapestInRegion(String region, String price) => _t({
    'en': 'Cheapest in $region at $price',
    'ar': 'الأرخص في $region بسعر $price',
    'fr': 'Le moins cher en $region à $price',
    'es': 'Más barato en $region a $price',
    'ko': '$region에서 $price로 가장 저렴',
  });

  String get priceDisclaimer => _t({
    'en': 'Prices may vary. Some services require regional payment methods or VPN.',
    'ar': 'قد تختلف الأسعار. بعض الخدمات تتطلب وسائل دفع إقليمية أو VPN.',
    'fr': 'Les prix peuvent varier. Certains services nécessitent des moyens de paiement régionaux ou un VPN.',
    'es': 'Los precios pueden variar. Algunos servicios requieren métodos de pago regionales o VPN.',
    'ko': '가격은 다를 수 있습니다. 일부 서비스는 지역 결제 수단이나 VPN이 필요합니다.',
  });

  String regionalPricesFor(String service) => _t({
    'en': '$service Prices by Region',
    'ar': 'أسعار $service حسب المنطقة',
    'fr': 'Prix de $service par région',
    'es': 'Precios de $service por región',
    'ko': '지역별 $service 가격',
  });

  String get supportedServices => _t({
    'en': 'Supported Services',
    'ar': 'الخدمات المدعومة',
    'fr': 'Services pris en charge',
    'es': 'Servicios compatibles',
    'ko': '지원되는 서비스',
  });

  // ==================== GEO DEALS FEATURE ====================

  String get dealsInYourRegion => _t({
    'en': 'Deals in Your Region',
    'ar': 'عروض في منطقتك',
    'fr': 'Offres dans votre région',
    'es': 'Ofertas en tu región',
    'ko': '내 지역 할인',
  });

  String basedOnLocation(String country) => _t({
    'en': 'Based on $country',
    'ar': 'بناءً على $country',
    'fr': 'Basé sur $country',
    'es': 'Basado en $country',
    'ko': '$country 기준',
  });

  String get limitedView => _t({
    'en': 'Limited',
    'ar': 'محدود',
    'fr': 'Limité',
    'es': 'Limitado',
    'ko': '제한됨',
  });

  String get noDealsInRegion => _t({
    'en': 'No deals in your region',
    'ar': 'لا توجد عروض في منطقتك',
    'fr': 'Pas d\'offres dans votre région',
    'es': 'Sin ofertas en tu región',
    'ko': '내 지역에 할인 없음',
  });

  String get checkBackLater => _t({
    'en': 'Check back later for new deals',
    'ar': 'تحقق لاحقاً للعروض الجديدة',
    'fr': 'Revenez plus tard pour de nouvelles offres',
    'es': 'Vuelve más tarde para nuevas ofertas',
    'ko': '새 할인을 위해 나중에 확인하세요',
  });

  String get unlockAllDeals => _t({
    'en': 'Unlock All Deals',
    'ar': 'فتح جميع العروض',
    'fr': 'Débloquer toutes les offres',
    'es': 'Desbloquear todas las ofertas',
    'ko': '모든 할인 잠금 해제',
  });

  String get geoDealsPremiuDescription => _t({
    'en': 'Access all deals from every region',
    'ar': 'الوصول لجميع العروض من كل منطقة',
    'fr': 'Accédez à toutes les offres de chaque région',
    'es': 'Accede a todas las ofertas de cada región',
    'ko': '모든 지역의 모든 할인에 접근',
  });

  String expiresIn(int days) => _t({
    'en': 'Expires in $days day${days == 1 ? '' : 's'}',
    'ar': 'تنتهي خلال $days يوم',
    'fr': 'Expire dans $days jour${days == 1 ? '' : 's'}',
    'es': 'Expira en $days día${days == 1 ? '' : 's'}',
    'ko': '$days일 후 만료',
  });

  String get noDealsAvailable => _t({
    'en': 'No deals available',
    'ar': 'لا توجد عروض متاحة',
    'fr': 'Aucune offre disponible',
    'es': 'Sin ofertas disponibles',
    'ko': '사용 가능한 할인 없음',
  });

  String get allRegions => _t({
    'en': 'All Regions',
    'ar': 'جميع المناطق',
    'fr': 'Toutes les régions',
    'es': 'Todas las regiones',
    'ko': '모든 지역',
  });

  // Deal Categories
  String get categoryStreaming => _t({
    'en': 'Streaming',
    'ar': 'البث',
    'fr': 'Streaming',
    'es': 'Streaming',
    'ko': '스트리밍',
  });

  String get categoryMusic => _t({
    'en': 'Music',
    'ar': 'موسيقى',
    'fr': 'Musique',
    'es': 'Música',
    'ko': '음악',
  });

  String get categoryGaming => _t({
    'en': 'Gaming',
    'ar': 'ألعاب',
    'fr': 'Jeux',
    'es': 'Juegos',
    'ko': '게임',
  });

  String get categoryCloud => _t({
    'en': 'Cloud',
    'ar': 'سحابة',
    'fr': 'Cloud',
    'es': 'Nube',
    'ko': '클라우드',
  });

  String get categorySoftware => _t({
    'en': 'Software',
    'ar': 'برمجيات',
    'fr': 'Logiciel',
    'es': 'Software',
    'ko': '소프트웨어',
  });

  String get categoryVpn => _t({
    'en': 'VPN',
    'ar': 'VPN',
    'fr': 'VPN',
    'es': 'VPN',
    'ko': 'VPN',
  });

  String get categoryEducation => _t({
    'en': 'Education',
    'ar': 'تعليم',
    'fr': 'Éducation',
    'es': 'Educación',
    'ko': '교육',
  });

  String get categoryFitness => _t({
    'en': 'Fitness',
    'ar': 'لياقة',
    'fr': 'Fitness',
    'es': 'Fitness',
    'ko': '피트니스',
  });

  String get categoryOther => _t({
    'en': 'Other',
    'ar': 'أخرى',
    'fr': 'Autre',
    'es': 'Otro',
    'ko': '기타',
  });

  // ============================================================
  // Usage Tracking Strings
  // ============================================================

  String get usageAnalytics => _t({
    'en': 'Usage Analytics',
    'ar': 'تحليلات الاستخدام',
    'fr': 'Analyses d\'utilisation',
    'es': 'Análisis de uso',
    'ko': '사용 분석',
  });

  String get usageTracker => _t({
    'en': 'Usage Tracker',
    'ar': 'متتبع الاستخدام',
    'fr': 'Suivi d\'utilisation',
    'es': 'Rastreador de uso',
    'ko': '사용 추적기',
  });

  String get totalUsage => _t({
    'en': 'Total Usage',
    'ar': 'الاستخدام الكلي',
    'fr': 'Utilisation totale',
    'es': 'Uso total',
    'ko': '총 사용량',
  });

  String get averageDaily => _t({
    'en': 'Average Daily',
    'ar': 'المتوسط اليومي',
    'fr': 'Moyenne quotidienne',
    'es': 'Promedio diario',
    'ko': '일 평균',
  });

  String get topUsed => _t({
    'en': 'Top Used',
    'ar': 'الأكثر استخداماً',
    'fr': 'Les plus utilisés',
    'es': 'Más usados',
    'ko': '가장 많이 사용',
  });

  String get underused => _t({
    'en': 'Underused',
    'ar': 'قليل الاستخدام',
    'fr': 'Sous-utilisé',
    'es': 'Poco usado',
    'ko': '사용 부족',
  });

  String get noUsageData => _t({
    'en': 'No usage data available',
    'ar': 'لا تتوفر بيانات استخدام',
    'fr': 'Aucune donnée d\'utilisation',
    'es': 'No hay datos de uso',
    'ko': '사용 데이터 없음',
  });

  String get usagePermissionRequired => _t({
    'en': 'Usage Permission Required',
    'ar': 'إذن الاستخدام مطلوب',
    'fr': 'Autorisation d\'utilisation requise',
    'es': 'Permiso de uso requerido',
    'ko': '사용 권한 필요',
  });

  String get usagePermissionDesc => _t({
    'en': 'To track your app usage, we need permission to access usage statistics.',
    'ar': 'لتتبع استخدامك للتطبيقات، نحتاج إلى إذن للوصول إلى إحصائيات الاستخدام.',
    'fr': 'Pour suivre votre utilisation, nous avons besoin d\'accéder aux statistiques.',
    'es': 'Para rastrear el uso, necesitamos permiso para acceder a estadísticas.',
    'ko': '앱 사용량을 추적하려면 사용 통계에 접근할 권한이 필요합니다.',
  });

  String get grantPermission => _t({
    'en': 'Grant Permission',
    'ar': 'منح الإذن',
    'fr': 'Accorder l\'autorisation',
    'es': 'Conceder permiso',
    'ko': '권한 부여',
  });

  String get hours => _t({
    'en': 'hours',
    'ar': 'ساعات',
    'fr': 'heures',
    'es': 'horas',
    'ko': '시간',
  });

  String get minutes => _t({
    'en': 'minutes',
    'ar': 'دقائق',
    'fr': 'minutes',
    'es': 'minutos',
    'ko': '분',
  });

  String get launches => _t({
    'en': 'launches',
    'ar': 'إطلاقات',
    'fr': 'lancements',
    'es': 'lanzamientos',
    'ko': '실행',
  });

  String get manualLog => _t({
    'en': 'Manual Log',
    'ar': 'سجل يدوي',
    'fr': 'Journal manuel',
    'es': 'Registro manual',
    'ko': '수동 기록',
  });

  String get addManualLog => _t({
    'en': 'Add Usage Log',
    'ar': 'إضافة سجل استخدام',
    'fr': 'Ajouter un journal',
    'es': 'Agregar registro',
    'ko': '사용 기록 추가',
  });

  String get selectSubscription => _t({
    'en': 'Select Subscription',
    'ar': 'اختر الاشتراك',
    'fr': 'Sélectionner l\'abonnement',
    'es': 'Seleccionar suscripción',
    'ko': '구독 선택',
  });

  String get selectDuration => _t({
    'en': 'Select Duration',
    'ar': 'اختر المدة',
    'fr': 'Sélectionner la durée',
    'es': 'Seleccionar duración',
    'ko': '기간 선택',
  });

  String get addNotes => _t({
    'en': 'Add Notes (optional)',
    'ar': 'إضافة ملاحظات (اختياري)',
    'fr': 'Ajouter des notes (optionnel)',
    'es': 'Agregar notas (opcional)',
    'ko': '메모 추가 (선택사항)',
  });

  String get usageLogAdded => _t({
    'en': 'Usage log added',
    'ar': 'تمت إضافة سجل الاستخدام',
    'fr': 'Journal d\'utilisation ajouté',
    'es': 'Registro de uso agregado',
    'ko': '사용 기록 추가됨',
  });

  String get trendIncreasing => _t({
    'en': 'Increasing',
    'ar': 'متزايد',
    'fr': 'En hausse',
    'es': 'Aumentando',
    'ko': '증가',
  });

  String get trendDecreasing => _t({
    'en': 'Decreasing',
    'ar': 'متناقص',
    'fr': 'En baisse',
    'es': 'Disminuyendo',
    'ko': '감소',
  });

  String get trendStable => _t({
    'en': 'Stable',
    'ar': 'مستقر',
    'fr': 'Stable',
    'es': 'Estable',
    'ko': '안정',
  });

  String get usageHistory => _t({
    'en': 'Usage History',
    'ar': 'تاريخ الاستخدام',
    'fr': 'Historique d\'utilisation',
    'es': 'Historial de uso',
    'ko': '사용 기록',
  });

  String get consideCancelling => _t({
    'en': 'Consider cancelling - low usage',
    'ar': 'فكر في الإلغاء - استخدام منخفض',
    'fr': 'Envisagez d\'annuler - faible utilisation',
    'es': 'Considere cancelar - poco uso',
    'ko': '해지 고려 - 사용량 적음',
  });

  String get manualTrackingTip => _t({
    'en': 'Tip: On iOS, use manual logging to track your usage.',
    'ar': 'نصيحة: على iOS، استخدم التسجيل اليدوي لتتبع استخدامك.',
    'fr': 'Astuce: Sur iOS, utilisez le journal manuel.',
    'es': 'Consejo: En iOS, use el registro manual.',
    'ko': '팁: iOS에서는 수동 기록을 사용하세요.',
  });

  String get unlockUsageTracking => _t({
    'en': 'Unlock usage tracking with Premium',
    'ar': 'فتح تتبع الاستخدام مع Premium',
    'fr': 'Débloquez le suivi avec Premium',
    'es': 'Desbloquee el seguimiento con Premium',
    'ko': '프리미엄으로 사용 추적 잠금 해제',
  });

  String get recentLogs => _t({
    'en': 'Recent Logs',
    'ar': 'السجلات الأخيرة',
    'fr': 'Journaux récents',
    'es': 'Registros recientes',
    'ko': '최근 기록',
  });

  // Drawer Section Headers
  String get freeFeatures => _t({
    'en': 'FREE FEATURES',
    'ar': 'الميزات المجانية',
    'fr': 'FONCTIONNALITÉS GRATUITES',
    'es': 'FUNCIONES GRATUITAS',
    'ko': '무료 기능',
  });

  String get trialEndsIn => _t({
    'en': 'Trial ends in',
    'ar': 'تنتهي الفترة التجريبية في',
    'fr': 'L\'essai se termine dans',
    'es': 'La prueba termina en',
    'ko': '체험 종료까지',
  });

  String get days => _t({
    'en': 'days',
    'ar': 'أيام',
    'fr': 'jours',
    'es': 'días',
    'ko': '일',
  });

  // Helper method to get translation
  String _t(Map<String, String> translations) {
    // Exact match first (e.g., zh_TW).
    final exact = translations[code];
    if (exact != null) return exact;

    // Fallback to base language (e.g., zh from zh_TW, pt from pt_BR).
    final base = code.split('_').first;
    final baseHit = translations[base];
    if (baseHit != null) return baseHit;

    // Final fallback to English.
    return translations['en'] ?? '';
  }
}
