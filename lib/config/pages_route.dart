
enum PagesRoute{
  loginPage("/", "Log In Page");

  const PagesRoute(this.path, this.name);
  final String path;
  final String name;
}