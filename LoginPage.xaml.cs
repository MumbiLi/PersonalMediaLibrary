using System.Windows;
using System.Windows.Input;

namespace PersonalMediaLibrary
{
    public partial class LoginPage : System.Windows.Controls.Page
    {
        public LoginPage()
        {
            InitializeComponent();
        }

        private void OnLoginClick(object sender, RoutedEventArgs e)
        {
            string email = EmailTextBox.Text;
            string password = PasswordBox.Password;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                MessageBox.Show("Заполните все поля.", "Ошибка входа",
                                MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            // Здесь будет реальная авторизация (в ПР №15)
            MessageBox.Show($"Добро пожаловать, {email}!\n(Авторизация в разработке)",
                            "Успешно", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void OnRegisterLinkClick(object sender, MouseButtonEventArgs e)
        {
            // Открываем окно регистрации
            RegistrationPage regPage = new RegistrationPage();
            Window parentWindow = Window.GetWindow(this);
            if (parentWindow != null)
            {
                parentWindow.Content = regPage;
            }
        }
    }
}
