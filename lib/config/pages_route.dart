
enum PagesRoute{
  welcomePage("/", "Welcome Page"),
  loginPage("/login", "Log In Page"),
  signupPage("/signup", "Sign Up Page"),
  homePage("/home", "Home Page"),
  accountCreatedPage("/account-created", "Account Created Page"),
  ;

  const PagesRoute(this.path, this.name);
  final String path;
  final String name;
}