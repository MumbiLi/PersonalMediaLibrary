using System.Windows;

namespace PersonalMediaLibrary
{
    public partial class RegistrationPage : System.Windows.Controls.Page
    {
        public RegistrationPage()
        {
            InitializeComponent();
        }

        private void OnRegisterClick(object sender, RoutedEventArgs e)
        {
            string fullName = FullNameTextBox.Text;
            string email = EmailTextBox.Text;
            string password = PasswordBox.Password;
            string confirm = ConfirmPasswordBox.Password;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(password) || string.IsNullOrEmpty(confirm))
            {
                MessageBox.Show("Пожалуйста, заполните все поля.", "Ошибка регистрации",
                                MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            if (password != confirm)
            {
                MessageBox.Show("Пароли не совпадают!", "Ошибка",
                                MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            // Требование: "Регистрация в разработке"
            MessageBox.Show("Регистрация в разработке\n\nДанные не сохранены.",
                            "Информация", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void OnBackToLoginClick(object sender, RoutedEventArgs e)
        {
            LoginPage loginPage = new LoginPage();
            Window parentWindow = Window.GetWindow(this);
            if (parentWindow != null)
            {
                parentWindow.Content = loginPage;
            }
        }
    }
}
