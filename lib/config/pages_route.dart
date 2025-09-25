
enum PagesRoute{
  welcomePage("/", "Welcome Page"),
  loginPage("/login", "Log In Page"),
  signupPage("/signup", "Sign Up Page"),
  homePage("/home", "Home Page"),
  accountCreatedPage("/account-created", "Account Created Page"),
  profilePage("/profile", "Profile Page"),
  changePasswordPage("/change-password", "Change Password Page"),
  addDocumentPage("/add-document", "Add Document Page"),
  logoutPage("/logout", "Logout Page"),
  deletePage("/delete", "Delete Account Page"),

  ;

  const PagesRoute(this.path, this.name);
  final String path;
  final String name;
}