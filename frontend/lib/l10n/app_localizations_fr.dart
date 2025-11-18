// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get home => 'Accueil';

  @override
  String get login => 'Se connecter';

  @override
  String get signin => 'S\'inscrire';

  @override
  String get account => 'Mon compte';

  @override
  String get admin => 'Admin';

  @override
  String get welcomeBack => 'Bienvenue !';

  @override
  String get readyToFeur => 'Prêt à FEUR ?';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? Créez-en un !';

  @override
  String get alreadyHaveAccount =>
      'Vous avez déjà un compte ? Connectez-vous !';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get repeatPassword => 'Répétez le mot de passe';

  @override
  String get email => 'Email';

  @override
  String get name => 'Nom';

  @override
  String get title => 'Titre';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get userInformation => 'Informations utilisateur';

  @override
  String get id => 'ID';

  @override
  String get createdAt => 'Créé le';

  @override
  String get editUser => 'Modifier l\'utilisateur';

  @override
  String get createUser => 'Nouvel utilisateur';

  @override
  String get save => 'Enregistrer';

  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get userCreated => 'Utilisateur créé avec succès';

  @override
  String get userCreationFailed => 'Échec de la création de l\'utilisateur';

  @override
  String get logoutSuccess => 'Déconnexion réussie';

  @override
  String get updateSuccess => 'Mise à jour réussie';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String get deleteSuccess => 'Suppression réussie';

  @override
  String get deleteFailed => 'Échec de la suppression de l\'utilisateur';

  @override
  String get postCreatedSuccess => 'Publication créée avec succès';

  @override
  String get postCreationFailed => 'Échec de la création de la publication';

  @override
  String get postDeletedSuccess => 'Publication supprimée avec succès';

  @override
  String get postDeletedFailed => 'Échec de la suppression de la publication';

  @override
  String get postHint => 'Quoi de neuf ?';

  @override
  String get likePostFailed => 'Échec du like de la publication';

  @override
  String get unlikePostFailed => 'Échec du unlike de la publication';

  @override
  String get createPost => 'Publier';

  @override
  String get loading => 'Chargement...';

  @override
  String get readyToStart => 'Prêt à commencer ?';

  @override
  String get thisIsThePlace =>
      'C\'est l\'endroit idéal pour partager vos pensées.';

  @override
  String get signinHeader => 'FEUR';

  @override
  String get createAccountMessage =>
      'Créez votre compte et commencez à partager vos pensées avec le monde.';

  @override
  String get hello => 'Bonjour';

  @override
  String get areYouReady => 'Êtes-vous prêt à créer un nouveau FEUR ?';

  @override
  String get madeWithLove => 'Fait avec';

  @override
  String get footer => 'Arthur Pinel 2025';

  @override
  String get dismiss => 'Masquer';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get usernameRequired => 'Nom d\'utilisateur requis';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get passwordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get repeatPasswordRequired => 'Veuillez répéter votre mot de passe';

  @override
  String get justNow => 'à l\'instant';

  @override
  String get oops => 'Oups !';

  @override
  String get pageNotFound =>
      'La page que vous avez demandée n\'a pas pu être trouvée.';

  @override
  String get areYouLost => 'Es-tu perdu, mon gars ?';

  @override
  String pathNotFound(Object error) {
    return 'Chemin non trouvé : $error';
  }

  @override
  String get errorLoadingUsers => 'Erreur lors du chargement des utilisateurs';

  @override
  String get failedToLoadUsers => 'Échec du chargement des utilisateurs';

  @override
  String get noUsersAvaible => 'Aucun utilisateur disponible.';

  @override
  String error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get isAdmin => 'Est administrateur';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get nothingToSeeThere => 'Rien à voir par ici...';

  @override
  String get beThe1stOneToCreatePost =>
      'Sois le premier à créer une publication !';

  @override
  String get failedToLoadPosts => 'Échec du chargement des publications';

  @override
  String get noUserDataAvaible => 'Aucune donnée utilisateur disponible';

  @override
  String get areYouAGhost => 'Es-tu un fantôme ?';
}
