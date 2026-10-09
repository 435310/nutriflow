/// ============================================
/// TEXTOS DO NUTRIFLOW
/// ============================================
/// Todos os textos fixos do app ficam aqui.
/// Isso facilita tradução futura (i18n) e padronização.
class AppStrings {
  AppStrings._();

  // ============================================
  // APP
  // ============================================
  static const String appName = 'NutriFlow';
  static const String appTagline = 'Seu acompanhamento nutricional\nem um só lugar.';

  // ============================================
  // TELA: WELCOME (Boas-vindas)
  // ============================================
  static const String welcomeTitle = 'NutriFlow';
  static const String welcomeSubtitle =
      'Seu acompanhamento nutricional\nem um só lugar.';
  static const String welcomeButtonLogin = 'Entrar';
  static const String welcomeButtonSignup = 'Criar conta';

  // ============================================
  // TELA: ESCOLHA DE PERFIL
  // ============================================
  static const String profileChoiceTitle = 'Como você vai usar\no NutriFlow?';
  static const String profileChoiceSubtitle =
      'Escolha o tipo de conta para continuar.';

  static const String profilePatientTitle = 'Sou Paciente';
  static const String profilePatientSubtitle =
      'Quero acompanhar minha alimentação\ne evolução corporal.';

  static const String profileNutritionistTitle = 'Sou Nutricionista';
  static const String profileNutritionistSubtitle =
      'Quero acompanhar meus pacientes\ne organizar meu trabalho.';

  // ============================================
  // TELA: ESCOLHA DE AÇÃO (Já tenho conta / Sou novo)
  // ============================================
  static const String authChoiceTitle = 'Bem-vindo(a) ao NutriFlow';
  static const String authChoiceSubtitle =
      'Escolha como deseja continuar.';
  static const String authChoiceLogin = 'Já tenho conta';
  static const String authChoiceLoginSubtitle =
      'Acessar minha conta existente';
  static const String authChoiceSignup = 'Sou novo aqui';
  static const String authChoiceSignupSubtitle =
      'Criar uma nova conta gratuitamente';

  // ============================================
  // TELA: LOGIN
  // ============================================
  static const String loginTitle = 'Entrar';
  static const String loginSubtitle = 'Acesse sua conta para continuar.';
  static const String loginEmailLabel = 'E-mail';
  static const String loginEmailHint = 'seu@email.com';
  static const String loginPasswordLabel = 'Senha';
  static const String loginPasswordHint = '••••••••';
  static const String loginButton = 'Entrar';
  static const String loginForgotPassword = 'Esqueci minha senha';
  static const String loginNoAccount = 'Não tem conta? ';
  static const String loginCreateAccount = 'Criar conta';

  // ============================================
  // TELA: CADASTRO
  // ============================================
  static const String signupTitle = 'Criar conta';
  static const String signupSubtitle =
      'Preencha os dados para começar.';
  static const String signupNameLabel = 'Nome completo';
  static const String signupNameHint = 'Como você se chama?';
  static const String signupEmailLabel = 'E-mail';
  static const String signupEmailHint = 'seu@email.com';
  static const String signupPasswordLabel = 'Senha';
  static const String signupPasswordHint = 'Mínimo 6 caracteres';
  static const String signupConfirmPasswordLabel = 'Confirmar senha';
  static const String signupConfirmPasswordHint = 'Repita a senha';
  static const String signupTermsText =
      'Li e aceito os Termos de Uso e a Política de Privacidade (LGPD).';
  static const String signupButton = 'Criar minha conta';
  static const String signupAlreadyHaveAccount = 'Já tem conta? ';
  static const String signupLogin = 'Entrar';

  // ============================================
  // VALIDAÇÕES (mensagens de erro)
  // ============================================
  static const String validationEmailRequired = 'Informe seu e-mail';
  static const String validationEmailInvalid = 'E-mail inválido';
  static const String validationPasswordRequired = 'Informe sua senha';
  static const String validationPasswordShort =
      'A senha deve ter pelo menos 6 caracteres';
  static const String validationNameRequired = 'Informe seu nome';
  static const String validationNameShort =
      'O nome deve ter pelo menos 3 caracteres';
  static const String validationConfirmPasswordRequired =
      'Confirme sua senha';
  static const String validationPasswordMismatch =
      'As senhas não coincidem';
  static const String validationTermsRequired =
      'Você precisa aceitar os termos para continuar';

  // ============================================
  // MENSAGENS GERAIS
  // ============================================
  static const String comingSoon = 'Em breve';
  static const String errorGeneric = 'Algo deu errado. Tente novamente.';
  static const String errorConnection =
      'Não conseguimos conectar. Verifique sua internet.';
  static const String loading = 'Carregando...';
  static const String ok = 'OK';
  static const String cancel = 'Cancelar';
  static const String save = 'Salvar';
  static const String back = 'Voltar';

  // ============================================
  // MENSAGENS TEMPORÁRIAS (serão removidas depois)
  // ============================================
  static const String comingSoonLogin = 'Em breve: Login';
  static const String comingSoonSignup = 'Em breve: Cadastro';
}