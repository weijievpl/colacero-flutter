import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appTitle => _t('appTitle');
  String get joinTitle => _t('joinTitle');
  String get joinSubtitle => _t('joinSubtitle');
  String get nameOptional => _t('nameOptional');
  String get visitReason => _t('visitReason');
  String get people => _t('people');
  String get person => _t('person');
  String get phoneOptional => _t('phoneOptional');
  String get getTicket => _t('getTicket');
  String get generating => _t('generating');
  String get adminAccess => _t('adminAccess');
  String get recoverTicket => _t('recoverTicket');
  String get scheduleAppointment => _t('scheduleAppointment');
  String get waitTitle => _t('waitTitle');
  String get yourNumber => _t('yourNumber');
  String get waiting => _t('waiting');
  String get served => _t('served');
  String get cancelled => _t('cancelled');
  String get position => _t('position');
  String get estWait => _t('estWait');
  String get minutes => _t('minutes');
  String get nextInLine => _t('nextInLine');
  String get beforeYou => _t('beforeYou');
  String get scanToShare => _t('scanToShare');
  String get backToHome => _t('backToHome');
  String get recoveryTitle => _t('recoveryTitle');
  String get lostYourTicket => _t('lostYourTicket');
  String get recoverySubtitle => _t('recoverySubtitle');
  String get phone => _t('phone');
  String get ticketCode => _t('ticketCode');
  String get search => _t('search');
  String get searching => _t('searching');
  String get noTicketFound => _t('noTicketFound');
  String get enterAtLeastOne => _t('enterAtLeastOne');
  String get appointmentTitle => _t('appointmentTitle');
  String get fullNameRequired => _t('fullNameRequired');
  String get reason => _t('reason');
  String get date => _t('date');
  String get selectDate => _t('selectDate');
  String get availableSlots => _t('availableSlots');
  String get additionalNotes => _t('additionalNotes');
  String get confirmAppointment => _t('confirmAppointment');
  String get scheduling => _t('scheduling');
  String get slotTaken => _t('slotTaken');
  String get dashboardTitle => _t('dashboardTitle');
  String get dashboardSubtitle => _t('dashboardSubtitle');
  String get inQueue => _t('inQueue');
  String get servedToday => _t('servedToday');
  String get currentQueue => _t('currentQueue');
  String get callNext => _t('callNext');
  String get noTicketsWaiting => _t('noTicketsWaiting');
  String get noTicketsSubtitle => _t('noTicketsSubtitle');
  String get analytics => _t('analytics');
  String get auditLog => _t('auditLog');
  String get brandConfig => _t('brandConfig');
  String get analysisTitle => _t('analysisTitle');
  String get todaySummary => _t('todaySummary');
  String get created => _t('created');
  String get avgWait => _t('avgWait');
  String get noShow => _t('noShow');
  String get statusDistribution => _t('statusDistribution');
  String get backToDashboard => _t('backToDashboard');
  String get auditTitle => _t('auditTitle');
  String get exportCsv => _t('exportCsv');
  String get all => _t('all');
  String get noEvents => _t('noEvents');
  String get noEventsSubtitle => _t('noEventsSubtitle');
  String get copiedToClipboard => _t('copiedToClipboard');
  String get brandConfigTitle => _t('brandConfigTitle');
  String get preview => _t('preview');
  String get businessName => _t('businessName');
  String get brandColor => _t('brandColor');
  String get welcomeMessage => _t('welcomeMessage');
  String get notifPrefix => _t('notifPrefix');
  String get saveChanges => _t('saveChanges');
  String get saving => _t('saving');
  String get resetDefaults => _t('resetDefaults');
  String get resetConfirmTitle => _t('resetConfirmTitle');
  String get resetConfirmBody => _t('resetConfirmBody');
  String get cancel => _t('cancel');
  String get restore => _t('restore');
  String get savedSuccess => _t('savedSuccess');
  String get lowContrastWarning => _t('lowContrastWarning');
  String get pinTitle => _t('pinTitle');
  String get pinSubtitle => _t('pinSubtitle');
  String get pinLabel => _t('pinLabel');
  String get login => _t('login');
  String get wrongPin => _t('wrongPin');
  String get tooManyAttempts => _t('tooManyAttempts');
  String get syncError => _t('syncError');
  String get offline => _t('offline');
  String get pendingChanges => _t('pendingChanges');
  String get syncing => _t('syncing');
  String get retry => _t('retry');
  String get retryingSync => _t('retryingSync');
  String get errorPrefix => _t('errorPrefix');
  String get ticketServedMsg => _t('ticketServedMsg');
  String get turnApproaching => _t('turnApproaching');
  String get itsYourTurn => _t('itsYourTurn');
  String get approachCounter => _t('approachCounter');
  String get appointmentReminder => _t('appointmentReminder');
  String get syncComplete => _t('syncComplete');
  String get itemsSynced => _t('itemsSynced');
  String get ticketRecovered => _t('ticketRecovered');
  String get restoredSuccessfully => _t('restoredSuccessfully');
  // Onboarding
  String get onboardingTitle1 => _t('onboardingTitle1');
  String get onboardingSubtitle1 => _t('onboardingSubtitle1');
  String get onboardingTitle2 => _t('onboardingTitle2');
  String get onboardingSubtitle2 => _t('onboardingSubtitle2');
  String get onboardingTitle3 => _t('onboardingTitle3');
  String get onboardingSubtitle3 => _t('onboardingSubtitle3');
  String get skip => _t('skip');
  String get next => _t('next');
  String get getStarted => _t('getStarted');
  // Offline / Sync
  String get offlineMode => _t('offlineMode');
  String get backOnline => _t('backOnline');
  String get lastSynced => _t('lastSynced');
  String get retryAll => _t('retryAll');
  String get retryFailed => _t('retryFailed');
  String get syncFailedCount => _t('syncFailedCount');
  // Confirmations
  String get confirmCancelTitle => _t('confirmCancelTitle');
  String get confirmCancelBody => _t('confirmCancelBody');
  String get confirmNoShowTitle => _t('confirmNoShowTitle');
  String get confirmNoShowBody => _t('confirmNoShowBody');
  String get confirmClearQueueTitle => _t('confirmClearQueueTitle');
  String get confirmClearQueueBody => _t('confirmClearQueueBody');
  String get confirmLogoutTitle => _t('confirmLogoutTitle');
  String get confirmLogoutBody => _t('confirmLogoutBody');
  String get doNotAskAgain => _t('doNotAskAgain');
  String get confirm => _t('confirm');

  String _t(String key) {
    final lang = locale.languageCode;
    return _translations[lang]?[key] ?? _translations['es']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'es': {
      'appTitle': 'ColaCero',
      'joinTitle': 'Sacar turno',
      'joinSubtitle': 'Selecciona tu motivo y espera cómodamente',
      'nameOptional': 'Nombre (opcional)',
      'visitReason': 'Motivo de visita',
      'people': 'personas',
      'person': 'persona',
      'phoneOptional': 'Teléfono (opcional)',
      'getTicket': 'Sacar turno',
      'generating': 'Generando...',
      'adminAccess': 'Acceso administrador',
      'recoverTicket': 'Recuperar turno perdido',
      'scheduleAppointment': 'Agendar cita',
      'waitTitle': 'Esperando',
      'yourNumber': 'TU NÚMERO',
      'waiting': 'Esperando',
      'served': '¡Atendido!',
      'cancelled': 'Cancelado',
      'position': 'Posición',
      'estWait': 'Espera est.',
      'minutes': 'minutos',
      'nextInLine': '¡Eres el siguiente!',
      'beforeYou': 'antes de ti',
      'scanToShare': 'Escanea para compartir tu estado',
      'backToHome': 'Volver al inicio',
      'recoveryTitle': 'Recuperar turno',
      'lostYourTicket': '¿Perdiste tu turno?',
      'recoverySubtitle': 'Busca por teléfono o código de recuperación para volver a tu lugar en la fila',
      'phone': 'Teléfono',
      'ticketCode': 'Código de turno',
      'search': 'Recuperar turno',
      'searching': 'Buscando...',
      'noTicketFound': 'No se encontró ningún turno activo con esos datos',
      'enterAtLeastOne': 'Ingresa al menos un dato para buscar',
      'appointmentTitle': 'Agendar cita',
      'fullNameRequired': 'Nombre completo *',
      'reason': 'Motivo',
      'date': 'Fecha',
      'selectDate': 'Seleccionar fecha',
      'availableSlots': 'Horario disponible',
      'additionalNotes': 'Notas adicionales',
      'confirmAppointment': 'Confirmar cita',
      'scheduling': 'Agendando...',
      'slotTaken': 'Este horario ya está ocupado. Elige otro.',
      'dashboardTitle': 'Panel Admin',
      'dashboardSubtitle': 'Gestión de turnos en tiempo real',
      'inQueue': 'En cola',
      'servedToday': 'Atendidos hoy',
      'currentQueue': 'Cola actual',
      'callNext': 'Llamar siguiente',
      'noTicketsWaiting': 'No hay turnos en espera',
      'noTicketsSubtitle': 'Los nuevos turnos aparecerán aquí automáticamente',
      'analytics': 'Análisis',
      'auditLog': 'Historial de eventos',
      'brandConfig': 'Configuración de marca',
      'analysisTitle': 'Análisis del día',
      'todaySummary': 'Resumen de hoy',
      'created': 'Creados',
      'avgWait': 'Espera promedio',
      'noShow': 'No-show',
      'statusDistribution': 'Distribución de estados',
      'backToDashboard': 'Volver al panel',
      'auditTitle': 'Historial de eventos',
      'exportCsv': 'Exportar CSV',
      'all': 'Todos',
      'noEvents': 'Sin eventos registrados',
      'noEventsSubtitle': 'Los eventos aparecerán aquí cuando se realicen acciones',
      'copiedToClipboard': 'registros copiados al portapapeles',
      'brandConfigTitle': 'Configuración de marca',
      'preview': 'Vista previa',
      'businessName': 'Nombre del negocio',
      'brandColor': 'Color de marca',
      'welcomeMessage': 'Mensaje de bienvenida',
      'notifPrefix': 'Prefijo de notificaciones',
      'saveChanges': 'Guardar cambios',
      'saving': 'Guardando...',
      'resetDefaults': 'Restaurar predeterminados',
      'resetConfirmTitle': 'Restaurar valores predeterminados',
      'resetConfirmBody': 'Esto restablecerá toda la configuración de marca a los valores originales. ¿Continuar?',
      'cancel': 'Cancelar',
      'restore': 'Restaurar',
      'savedSuccess': 'Configuración de marca guardada',
      'lowContrastWarning': 'Este color puede tener bajo contraste con texto blanco',
      'pinTitle': 'Acceso de operador',
      'pinSubtitle': 'Ingresa tu PIN para acceder al panel',
      'pinLabel': 'PIN',
      'login': 'Ingresar',
      'wrongPin': 'PIN incorrecto',
      'tooManyAttempts': 'Demasiados intentos. Espera un momento.',
      'syncError': 'Error de sync',
      'offline': 'Sin conexión',
      'pendingChanges': 'cambios pendientes',
      'syncing': 'Sincronizando...',
      'retry': 'Reintentar',
      'retryingSync': 'Reintentando sincronización...',
      'errorPrefix': 'Error',
      'ticketServedMsg': 'atendido',
      'turnApproaching': '¡Tu turno se acerca!',
      'itsYourTurn': '¡Es tu turno!',
      'approachCounter': 'acércate al mostrador',
      'appointmentReminder': 'Recordatorio de cita',
      'syncComplete': 'Sincronización completada',
      'itemsSynced': 'cambios sincronizados correctamente',
      'ticketRecovered': 'Turno recuperado',
      'restoredSuccessfully': 'ha sido restaurado',
      'onboardingTitle1': 'Saca tu turno',
      'onboardingSubtitle1': 'Elige tu motivo y obtén un número al instante. Sin esperas innecesarias.',
      'onboardingTitle2': 'Espera cómodamente',
      'onboardingSubtitle2': 'Recibe notificaciones en tiempo real sobre tu posición y tiempo estimado.',
      'onboardingTitle3': 'Gestiona fácilmente',
      'onboardingSubtitle3': 'Panel admin para llamar turnos, ver análisis y configurar tu marca.',
      'skip': 'Omitir',
      'next': 'Siguiente',
      'getStarted': 'Comenzar',
      'offlineMode': 'Sin conexión — trabajando offline',
      'backOnline': 'Conexión restaurada',
      'lastSynced': 'Última sync',
      'retryAll': 'Reintentar todo',
      'retryFailed': 'Reintentar fallidos',
      'syncFailedCount': 'fallidos',
      'confirmCancelTitle': 'Cancelar turno',
      'confirmCancelBody': '¿Estás seguro de que deseas cancelar este turno? Esta acción no se puede deshacer.',
      'confirmNoShowTitle': 'Marcar como no-show',
      'confirmNoShowBody': '¿El cliente no se presentó? Esto marcará el turno como ausente.',
      'confirmClearQueueTitle': 'Vaciar cola',
      'confirmClearQueueBody': 'Esto cancelará todos los turnos pendientes. ¿Continuar?',
      'confirmLogoutTitle': 'Cerrar sesión',
      'confirmLogoutBody': '¿Salir del panel de operador?',
      'doNotAskAgain': 'No volver a preguntar',
      'confirm': 'Confirmar',
    },
    'en': {
      'appTitle': 'ColaCero',
      'joinTitle': 'Get a ticket',
      'joinSubtitle': 'Select your reason and wait comfortably',
      'nameOptional': 'Name (optional)',
      'visitReason': 'Visit reason',
      'people': 'people',
      'person': 'person',
      'phoneOptional': 'Phone (optional)',
      'getTicket': 'Get ticket',
      'generating': 'Generating...',
      'adminAccess': 'Admin access',
      'recoverTicket': 'Recover lost ticket',
      'scheduleAppointment': 'Schedule appointment',
      'waitTitle': 'Waiting',
      'yourNumber': 'YOUR NUMBER',
      'waiting': 'Waiting',
      'served': 'Served!',
      'cancelled': 'Cancelled',
      'position': 'Position',
      'estWait': 'Est. wait',
      'minutes': 'minutes',
      'nextInLine': "You're next!",
      'beforeYou': 'ahead of you',
      'scanToShare': 'Scan to share your status',
      'backToHome': 'Back to home',
      'recoveryTitle': 'Recover ticket',
      'lostYourTicket': 'Lost your ticket?',
      'recoverySubtitle': 'Search by phone or recovery code to get back in line',
      'phone': 'Phone',
      'ticketCode': 'Ticket code',
      'search': 'Recover ticket',
      'searching': 'Searching...',
      'noTicketFound': 'No active ticket found with that information',
      'enterAtLeastOne': 'Enter at least one field to search',
      'appointmentTitle': 'Schedule appointment',
      'fullNameRequired': 'Full name *',
      'reason': 'Reason',
      'date': 'Date',
      'selectDate': 'Select date',
      'availableSlots': 'Available slots',
      'additionalNotes': 'Additional notes',
      'confirmAppointment': 'Confirm appointment',
      'scheduling': 'Scheduling...',
      'slotTaken': 'This slot is already taken. Choose another.',
      'dashboardTitle': 'Admin Panel',
      'dashboardSubtitle': 'Real-time queue management',
      'inQueue': 'In queue',
      'servedToday': 'Served today',
      'currentQueue': 'Current queue',
      'callNext': 'Call next',
      'noTicketsWaiting': 'No tickets waiting',
      'noTicketsSubtitle': 'New tickets will appear here automatically',
      'analytics': 'Analytics',
      'auditLog': 'Event log',
      'brandConfig': 'Brand settings',
      'analysisTitle': 'Daily analysis',
      'todaySummary': "Today's summary",
      'created': 'Created',
      'avgWait': 'Average wait',
      'noShow': 'No-show',
      'statusDistribution': 'Status distribution',
      'backToDashboard': 'Back to dashboard',
      'auditTitle': 'Event log',
      'exportCsv': 'Export CSV',
      'all': 'All',
      'noEvents': 'No events recorded',
      'noEventsSubtitle': 'Events will appear here when actions are performed',
      'copiedToClipboard': 'records copied to clipboard',
      'brandConfigTitle': 'Brand settings',
      'preview': 'Preview',
      'businessName': 'Business name',
      'brandColor': 'Brand color',
      'welcomeMessage': 'Welcome message',
      'notifPrefix': 'Notification prefix',
      'saveChanges': 'Save changes',
      'saving': 'Saving...',
      'resetDefaults': 'Reset to defaults',
      'resetConfirmTitle': 'Reset to defaults',
      'resetConfirmBody': 'This will restore all brand settings to original values. Continue?',
      'cancel': 'Cancel',
      'restore': 'Restore',
      'savedSuccess': 'Brand settings saved',
      'lowContrastWarning': 'This color may have low contrast with white text',
      'pinTitle': 'Operator access',
      'pinSubtitle': 'Enter your PIN to access the panel',
      'pinLabel': 'PIN',
      'login': 'Login',
      'wrongPin': 'Incorrect PIN',
      'tooManyAttempts': 'Too many attempts. Please wait.',
      'syncError': 'Sync error',
      'offline': 'Offline',
      'pendingChanges': 'pending changes',
      'syncing': 'Syncing...',
      'retry': 'Retry',
      'retryingSync': 'Retrying sync...',
      'errorPrefix': 'Error',
      'ticketServedMsg': 'served',
      'turnApproaching': 'Your turn is coming!',
      'itsYourTurn': "It's your turn!",
      'approachCounter': 'please approach the counter',
      'appointmentReminder': 'Appointment reminder',
      'syncComplete': 'Sync complete',
      'itemsSynced': 'changes synced successfully',
      'ticketRecovered': 'Ticket recovered',
      'restoredSuccessfully': 'has been restored',
      'onboardingTitle1': 'Get your ticket',
      'onboardingSubtitle1': 'Choose your reason and get a number instantly. No unnecessary waiting.',
      'onboardingTitle2': 'Wait comfortably',
      'onboardingSubtitle2': 'Receive real-time notifications about your position and estimated time.',
      'onboardingTitle3': 'Manage easily',
      'onboardingSubtitle3': 'Admin panel to call tickets, view analytics, and configure your brand.',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get started',
      'offlineMode': 'No connection — working offline',
      'backOnline': 'Connection restored',
      'lastSynced': 'Last synced',
      'retryAll': 'Retry all',
      'retryFailed': 'Retry failed',
      'syncFailedCount': 'failed',
      'confirmCancelTitle': 'Cancel ticket',
      'confirmCancelBody': 'Are you sure you want to cancel this ticket? This action cannot be undone.',
      'confirmNoShowTitle': 'Mark as no-show',
      'confirmNoShowBody': 'Did the customer not show up? This will mark the ticket as absent.',
      'confirmClearQueueTitle': 'Clear queue',
      'confirmClearQueueBody': 'This will cancel all pending tickets. Continue?',
      'confirmLogoutTitle': 'Log out',
      'confirmLogoutBody': 'Exit the operator panel?',
      'doNotAskAgain': "Don't ask again",
      'confirm': 'Confirm',
    },
    'pt': {
      'appTitle': 'ColaCero',
      'joinTitle': 'Pegar senha',
      'joinSubtitle': 'Selecione o motivo e aguarde confortavelmente',
      'nameOptional': 'Nome (opcional)',
      'visitReason': 'Motivo da visita',
      'people': 'pessoas',
      'person': 'pessoa',
      'phoneOptional': 'Telefone (opcional)',
      'getTicket': 'Pegar senha',
      'generating': 'Gerando...',
      'adminAccess': 'Acesso admin',
      'recoverTicket': 'Recuperar senha perdida',
      'scheduleAppointment': 'Agendar consulta',
      'dashboardTitle': 'Painel Admin',
      'dashboardSubtitle': 'Gestão de filas em tempo real',
      'inQueue': 'Na fila',
      'servedToday': 'Atendidos hoje',
      'callNext': 'Chamar próximo',
      'noTicketsWaiting': 'Nenhuma senha em espera',
      'analytics': 'Análises',
      'auditLog': 'Histórico de eventos',
      'brandConfig': 'Configuração de marca',
      'pinTitle': 'Acesso do operador',
      'pinSubtitle': 'Digite seu PIN para acessar o painel',
      'login': 'Entrar',
      'wrongPin': 'PIN incorreto',
      'cancel': 'Cancelar',
      'saveChanges': 'Salvar alterações',
      'saving': 'Salvando...',
      'retry': 'Tentar novamente',
      'syncing': 'Sincronizando...',
      'offlineMode': 'Sem conexão — trabalhando offline',
      'backOnline': 'Conexão restaurada',
      'skip': 'Pular',
      'next': 'Próximo',
      'getStarted': 'Começar',
      'confirm': 'Confirmar',
      'doNotAskAgain': 'Não perguntar novamente',
      'waitTitle': 'Aguardando',
      'yourNumber': 'SEU NÚMERO',
      'waiting': 'Aguardando',
      'served': 'Atendido!',
      'cancelled': 'Cancelado',
      'position': 'Posição',
      'estWait': 'Espera est.',
      'minutes': 'minutos',
      'nextInLine': 'Você é o próximo!',
      'beforeYou': 'antes de você',
      'scanToShare': 'Escaneie para compartilhar',
      'backToHome': 'Voltar ao início',
      'recoveryTitle': 'Recuperar senha',
      'lostYourTicket': 'Perdeu sua senha?',
      'recoverySubtitle': 'Busque por telefone ou código para voltar à fila',
      'phone': 'Telefone',
      'ticketCode': 'Código da senha',
      'search': 'Recuperar',
      'searching': 'Buscando...',
      'noTicketFound': 'Nenhuma senha ativa encontrada',
      'enterAtLeastOne': 'Insira pelo menos um dado',
      'appointmentTitle': 'Agendar consulta',
      'fullNameRequired': 'Nome completo *',
      'reason': 'Motivo',
      'date': 'Data',
      'selectDate': 'Selecionar data',
      'availableSlots': 'Horários disponíveis',
      'additionalNotes': 'Notas adicionais',
      'confirmAppointment': 'Confirmar',
      'scheduling': 'Agendando...',
      'slotTaken': 'Este horário já está ocupado',
      'currentQueue': 'Fila atual',
      'noTicketsSubtitle': 'Novas senhas aparecerão aqui',
      'analysisTitle': 'Análise do dia',
      'todaySummary': 'Resumo de hoje',
      'created': 'Criados',
      'avgWait': 'Espera média',
      'noShow': 'Não compareceu',
      'statusDistribution': 'Distribuição de status',
      'backToDashboard': 'Voltar ao painel',
      'auditTitle': 'Histórico de eventos',
      'exportCsv': 'Exportar CSV',
      'all': 'Todos',
      'noEvents': 'Sem eventos registrados',
      'noEventsSubtitle': 'Eventos aparecerão aqui',
      'copiedToClipboard': 'registros copiados',
      'brandConfigTitle': 'Configuração de marca',
      'preview': 'Prévia',
      'businessName': 'Nome do negócio',
      'brandColor': 'Cor da marca',
      'welcomeMessage': 'Mensagem de boas-vindas',
      'notifPrefix': 'Prefixo de notificações',
      'resetDefaults': 'Restaurar padrões',
      'resetConfirmTitle': 'Restaurar padrões',
      'resetConfirmBody': 'Isso restaurará todas as configurações. Continuar?',
      'restore': 'Restaurar',
      'savedSuccess': 'Configurações salvas',
      'lowContrastWarning': 'Esta cor pode ter baixo contraste',
      'tooManyAttempts': 'Muitas tentativas. Aguarde.',
      'syncError': 'Erro de sync',
      'offline': 'Offline',
      'pendingChanges': 'alterações pendentes',
      'retryingSync': 'Retentando sync...',
      'errorPrefix': 'Erro',
      'ticketServedMsg': 'atendido',
      'turnApproaching': 'Sua vez está chegando!',
      'itsYourTurn': 'É sua vez!',
      'approachCounter': 'aproxime-se do balcão',
      'appointmentReminder': 'Lembrete de consulta',
      'syncComplete': 'Sync concluída',
      'itemsSynced': 'alterações sincronizadas',
      'ticketRecovered': 'Senha recuperada',
      'restoredSuccessfully': 'foi restaurada',
      'onboardingTitle1': 'Pegue sua senha',
      'onboardingSubtitle1': 'Escolha o motivo e receba um número instantaneamente.',
      'onboardingTitle2': 'Aguarde confortavelmente',
      'onboardingSubtitle2': 'Receba notificações em tempo real sobre sua posição.',
      'onboardingTitle3': 'Gerencie facilmente',
      'onboardingSubtitle3': 'Painel admin para chamar senhas e ver análises.',
      'lastSynced': 'Última sync',
      'retryAll': 'Tentar tudo',
      'retryFailed': 'Tentar falhas',
      'syncFailedCount': 'falhas',
      'confirmCancelTitle': 'Cancelar senha',
      'confirmCancelBody': 'Tem certeza? Esta ação não pode ser desfeita.',
      'confirmNoShowTitle': 'Marcar como ausente',
      'confirmNoShowBody': 'O cliente não compareceu?',
      'confirmClearQueueTitle': 'Limpar fila',
      'confirmClearQueueBody': 'Isso cancelará todas as senhas pendentes.',
      'confirmLogoutTitle': 'Sair',
      'confirmLogoutBody': 'Sair do painel do operador?',
    },
    'fr': {
      'appTitle': 'ColaCero',
      'joinTitle': 'Prendre un ticket',
      'joinSubtitle': 'Sélectionnez votre motif et attendez confortablement',
      'nameOptional': 'Nom (facultatif)',
      'visitReason': 'Motif de visite',
      'people': 'personnes',
      'person': 'personne',
      'phoneOptional': 'Téléphone (facultatif)',
      'getTicket': 'Prendre un ticket',
      'generating': 'Génération...',
      'adminAccess': 'Accès administrateur',
      'recoverTicket': 'Récupérer le ticket perdu',
      'scheduleAppointment': 'Planifier un rendez-vous',
      'dashboardTitle': 'Panneau admin',
      'dashboardSubtitle': 'Gestion des files en temps réel',
      'inQueue': 'En file',
      'servedToday': 'Servis aujourd\'hui',
      'callNext': 'Appeler le suivant',
      'noTicketsWaiting': 'Aucun ticket en attente',
      'analytics': 'Analyses',
      'auditLog': 'Journal d\'événements',
      'brandConfig': 'Paramètres de marque',
      'pinTitle': 'Accès opérateur',
      'pinSubtitle': 'Entrez votre PIN pour accéder au panneau',
      'login': 'Connexion',
      'wrongPin': 'PIN incorrect',
      'cancel': 'Annuler',
      'saveChanges': 'Enregistrer',
      'saving': 'Enregistrement...',
      'retry': 'Réessayer',
      'syncing': 'Synchronisation...',
      'offlineMode': 'Pas de connexion — mode hors ligne',
      'backOnline': 'Connexion rétablie',
      'skip': 'Passer',
      'next': 'Suivant',
      'getStarted': 'Commencer',
      'confirm': 'Confirmer',
      'doNotAskAgain': 'Ne plus demander',
      'waitTitle': 'En attente',
      'yourNumber': 'VOTRE NUMÉRO',
      'waiting': 'En attente',
      'served': 'Servi !',
      'cancelled': 'Annulé',
      'position': 'Position',
      'estWait': 'Attente est.',
      'minutes': 'minutes',
      'nextInLine': 'Vous êtes le suivant !',
      'beforeYou': 'avant vous',
      'scanToShare': 'Scannez pour partager',
      'backToHome': "Retour à l'accueil",
      'recoveryTitle': 'Récupérer le ticket',
      'lostYourTicket': 'Ticket perdu ?',
      'recoverySubtitle': 'Recherchez par téléphone ou code de récupération',
      'phone': 'Téléphone',
      'ticketCode': 'Code du ticket',
      'search': 'Récupérer',
      'searching': 'Recherche...',
      'noTicketFound': 'Aucun ticket actif trouvé',
      'enterAtLeastOne': 'Entrez au moins une donnée',
      'appointmentTitle': 'Planifier un rendez-vous',
      'fullNameRequired': 'Nom complet *',
      'reason': 'Motif',
      'date': 'Date',
      'selectDate': 'Sélectionner la date',
      'availableSlots': 'Créneaux disponibles',
      'additionalNotes': 'Notes supplémentaires',
      'confirmAppointment': 'Confirmer',
      'scheduling': 'Planification...',
      'slotTaken': 'Ce créneau est déjà pris',
      'currentQueue': 'File actuelle',
      'noTicketsSubtitle': 'Les nouveaux tickets apparaîtront ici',
      'analysisTitle': 'Analyse du jour',
      'todaySummary': "Résumé d'aujourd'hui",
      'created': 'Créés',
      'avgWait': 'Attente moyenne',
      'noShow': 'Absence',
      'statusDistribution': 'Distribution des statuts',
      'backToDashboard': 'Retour au tableau de bord',
      'auditTitle': "Journal d'événements",
      'exportCsv': 'Exporter CSV',
      'all': 'Tous',
      'noEvents': 'Aucun événement enregistré',
      'noEventsSubtitle': 'Les événements apparaîtront ici',
      'copiedToClipboard': 'enregistrements copiés',
      'brandConfigTitle': 'Paramètres de marque',
      'preview': 'Aperçu',
      'businessName': "Nom de l'entreprise",
      'brandColor': 'Couleur de marque',
      'welcomeMessage': 'Message de bienvenue',
      'notifPrefix': 'Préfixe de notifications',
      'resetDefaults': 'Réinitialiser',
      'resetConfirmTitle': 'Réinitialiser les paramètres',
      'resetConfirmBody': 'Cela restaurera tous les paramètres. Continuer ?',
      'restore': 'Restaurer',
      'savedSuccess': 'Paramètres enregistrés',
      'lowContrastWarning': 'Cette couleur peut avoir un faible contraste',
      'tooManyAttempts': 'Trop de tentatives. Veuillez patienter.',
      'syncError': 'Erreur de sync',
      'offline': 'Hors ligne',
      'pendingChanges': 'modifications en attente',
      'retryingSync': 'Nouvelle tentative...',
      'errorPrefix': 'Erreur',
      'ticketServedMsg': 'servi',
      'turnApproaching': 'Votre tour approche !',
      'itsYourTurn': "C'est votre tour !",
      'approachCounter': 'approchez-vous du comptoir',
      'appointmentReminder': 'Rappel de rendez-vous',
      'syncComplete': 'Sync terminée',
      'itemsSynced': 'modifications synchronisées',
      'ticketRecovered': 'Ticket récupéré',
      'restoredSuccessfully': 'a été restauré',
      'onboardingTitle1': 'Prenez votre ticket',
      'onboardingSubtitle1': 'Choisissez votre motif et obtenez un numéro instantanément.',
      'onboardingTitle2': 'Attendez confortablement',
      'onboardingSubtitle2': 'Recevez des notifications en temps réel sur votre position.',
      'onboardingTitle3': 'Gérez facilement',
      'onboardingSubtitle3': "Tableau de bord admin pour appeler les tickets et voir les analyses.",
      'lastSynced': 'Dernière sync',
      'retryAll': 'Tout réessayer',
      'retryFailed': 'Réessayer les échecs',
      'syncFailedCount': 'échoués',
      'confirmCancelTitle': 'Annuler le ticket',
      'confirmCancelBody': 'Êtes-vous sûr ? Cette action est irréversible.',
      'confirmNoShowTitle': "Marquer comme absent",
      'confirmNoShowBody': 'Le client ne s\'est pas présenté ?',
      'confirmClearQueueTitle': 'Vider la file',
      'confirmClearQueueBody': 'Cela annulera tous les tickets en attente.',
      'confirmLogoutTitle': 'Déconnexion',
      'confirmLogoutBody': "Quitter le panneau opérateur ?",
    },
    'de': {
      'appTitle': 'ColaCero',
      'joinTitle': 'Nummer ziehen',
      'joinSubtitle': 'Wählen Sie Ihren Grund und warten Sie bequem',
      'nameOptional': 'Name (optional)',
      'visitReason': 'Besuchsgrund',
      'people': 'Personen',
      'person': 'Person',
      'phoneOptional': 'Telefon (optional)',
      'getTicket': 'Nummer ziehen',
      'generating': 'Generierung...',
      'adminAccess': 'Admin-Zugang',
      'recoverTicket': 'Verlorene Nummer wiederherstellen',
      'scheduleAppointment': 'Termin vereinbaren',
      'dashboardTitle': 'Admin-Panel',
      'dashboardSubtitle': 'Echtzeit-Warteschlangenverwaltung',
      'inQueue': 'In Warteschlange',
      'servedToday': 'Heute bedient',
      'callNext': 'Nächsten aufrufen',
      'noTicketsWaiting': 'Keine Tickets wartend',
      'analytics': 'Analysen',
      'auditLog': 'Ereignisprotokoll',
      'brandConfig': 'Markeneinstellungen',
      'pinTitle': 'Operator-Zugang',
      'pinSubtitle': 'Geben Sie Ihre PIN ein, um auf das Panel zuzugreifen',
      'login': 'Anmelden',
      'wrongPin': 'Falsche PIN',
      'cancel': 'Abbrechen',
      'saveChanges': 'Änderungen speichern',
      'saving': 'Speichern...',
      'retry': 'Erneut versuchen',
      'syncing': 'Synchronisierung...',
      'offlineMode': 'Keine Verbindung — Offline-Modus',
      'backOnline': 'Verbindung wiederhergestellt',
      'skip': 'Überspringen',
      'next': 'Weiter',
      'getStarted': 'Loslegen',
      'confirm': 'Bestätigen',
      'doNotAskAgain': 'Nicht mehr fragen',
      'waitTitle': 'Warten',
      'yourNumber': 'IHRE NUMMER',
      'waiting': 'Wartend',
      'served': 'Bedient!',
      'cancelled': 'Storniert',
      'position': 'Position',
      'estWait': 'Geschätzte Wartezeit',
      'minutes': 'Minuten',
      'nextInLine': 'Sie sind der Nächste!',
      'beforeYou': 'vor Ihnen',
      'scanToShare': 'Scannen zum Teilen',
      'backToHome': 'Zurück zur Startseite',
      'recoveryTitle': 'Nummer wiederherstellen',
      'lostYourTicket': 'Nummer verloren?',
      'recoverySubtitle': 'Suche per Telefon oder Wiederherstellungscode',
      'phone': 'Telefon',
      'ticketCode': 'Nummerncode',
      'search': 'Wiederherstellen',
      'searching': 'Suche...',
      'noTicketFound': 'Keine aktive Nummer gefunden',
      'enterAtLeastOne': 'Geben Sie mindestens eine Angabe ein',
      'appointmentTitle': 'Termin vereinbaren',
      'fullNameRequired': 'Vollständiger Name *',
      'reason': 'Grund',
      'date': 'Datum',
      'selectDate': 'Datum auswählen',
      'availableSlots': 'Verfügbare Zeiten',
      'additionalNotes': 'Zusätzliche Notizen',
      'confirmAppointment': 'Bestätigen',
      'scheduling': 'Planung...',
      'slotTaken': 'Diese Zeit ist bereits belegt',
      'currentQueue': 'Aktuelle Warteschlange',
      'noTicketsSubtitle': 'Neue Nummern erscheinen hier',
      'analysisTitle': 'Tagesanalyse',
      'todaySummary': 'Heutige Zusammenfassung',
      'created': 'Erstellt',
      'avgWait': 'Durchschn. Wartezeit',
      'noShow': 'Nicht erschienen',
      'statusDistribution': 'Statusverteilung',
      'backToDashboard': 'Zurück zum Dashboard',
      'auditTitle': 'Ereignisprotokoll',
      'exportCsv': 'CSV exportieren',
      'all': 'Alle',
      'noEvents': 'Keine Ereignisse aufgezeichnet',
      'noEventsSubtitle': 'Ereignisse erscheinen hier',
      'copiedToClipboard': 'Datensätze kopiert',
      'brandConfigTitle': 'Markeneinstellungen',
      'preview': 'Vorschau',
      'businessName': 'Unternehmensname',
      'brandColor': 'Markenfarbe',
      'welcomeMessage': 'Willkommensnachricht',
      'notifPrefix': 'Benachrichtigungspräfix',
      'resetDefaults': 'Zurücksetzen',
      'resetConfirmTitle': 'Auf Standard zurücksetzen',
      'resetConfirmBody': 'Alle Einstellungen werden zurückgesetzt. Fortfahren?',
      'restore': 'Wiederherstellen',
      'savedSuccess': 'Einstellungen gespeichert',
      'lowContrastWarning': 'Diese Farbe hat möglicherweise geringen Kontrast',
      'tooManyAttempts': 'Zu viele Versuche. Bitte warten.',
      'syncError': 'Sync-Fehler',
      'offline': 'Offline',
      'pendingChanges': 'ausstehende Änderungen',
      'retryingSync': 'Sync wird wiederholt...',
      'errorPrefix': 'Fehler',
      'ticketServedMsg': 'bedient',
      'turnApproaching': 'Ihr Turnus nähert sich!',
      'itsYourTurn': 'Sie sind dran!',
      'approachCounter': 'bitte zum Schalter kommen',
      'appointmentReminder': 'Terminerinnerung',
      'syncComplete': 'Sync abgeschlossen',
      'itemsSynced': 'Änderungen synchronisiert',
      'ticketRecovered': 'Nummer wiederhergestellt',
      'restoredSuccessfully': 'wurde wiederhergestellt',
      'onboardingTitle1': 'Nummer ziehen',
      'onboardingSubtitle1': 'Wählen Sie Ihren Grund und erhalten Sie sofort eine Nummer.',
      'onboardingTitle2': 'Komfortabel warten',
      'onboardingSubtitle2': 'Echtzeit-Benachrichtigungen über Ihre Position.',
      'onboardingTitle3': 'Einfach verwalten',
      'onboardingSubtitle3': 'Admin-Panel zum Aufrufen von Nummern und Anzeigen von Analysen.',
      'lastSynced': 'Letzte Sync',
      'retryAll': 'Alle wiederholen',
      'retryFailed': 'Fehlgeschlagene wiederholen',
      'syncFailedCount': 'fehlgeschlagen',
      'confirmCancelTitle': 'Nummer stornieren',
      'confirmCancelBody': 'Sind Sie sicher? Diese Aktion kann nicht rückgängig gemacht werden.',
      'confirmNoShowTitle': 'Als abwesend markieren',
      'confirmNoShowBody': 'Der Kunde ist nicht erschienen?',
      'confirmClearQueueTitle': 'Warteschlange leeren',
      'confirmClearQueueBody': 'Alle ausstehenden Nummern werden storniert.',
      'confirmLogoutTitle': 'Abmelden',
      'confirmLogoutBody': 'Das Operator-Panel verlassen?',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['es', 'en', 'pt', 'fr', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
