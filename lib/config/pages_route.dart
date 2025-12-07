
enum PagesRoute{
  welcomePage("/", "Welcome Page"),
  loginPage("/login", "Log In Page"),
  signupPage("/signup", "Sign Up Page"),
  homePage("/home", "Home Page"),
  accountCreatedPage("/account-created", "Account Created Page"),
  profilePage("/profile", "Profile Page"),
  changePasswordPage("/change-password", "Change Password Page"),
  addDocumentPage("/add-document", "Add Document Page"),
  deletePage("/delete", "Delete Account Page"),
  editDocumentPage("/edit-document", "Edit Document Page"),
  documentDetailsPage("/document-details", "Document Details Page"),
  cameraPage("/camera", "Camera Page"),
  previewPhotoPage("/preview-image", "Preview Image"),
  previewPDFPage("/preview-pdf", "Preview PDF"),
  editProfilePage("/edit-profile", "Edit Profile Page"),
  familyMemberPage("/family-member", "Family Page"),
  addFamilyMemberPage("/add-family-member", "Add Family Member Page"),

  ;

  const PagesRoute(this.path, this.name);
  final String path;
  final String name;
}