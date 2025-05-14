using MimeKit;
using MimeKit.Text;
using MailKit.Net.Smtp;
using Newtonsoft.Json;
using System.Net.Mail;
using SmtpClient = MailKit.Net.Smtp.SmtpClient;

namespace RabbitMQConsumer
{
    public class MailService
    {
        public void Send(string message)
        {
            try
            {
                // Učitavanje environment varijabli za SMTP
                string smtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER") ?? "smtp.gmail.com";
                int smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "465");
                string fromMail = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "carcarehub3@gmail.com";
                string password = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "ggta vluj nkrw lqps";

                // Deserijalizacija poruke u MailDto objekt
                var emailData = JsonConvert.DeserializeObject<MailDto>(message);
                if (emailData == null)
                {
                    Console.WriteLine("Deserialization failed, message is null or in incorrect format.");
                    return;
                }

                // Provjera polja unutar MailDto
                string recipientEmail = emailData.Email;
                string subject = $"Potvrda narudžbe: {emailData.BrojNarudzbe}";
                string content = $"Poštovani {emailData.ImePrezime},\n\n" +
                                 $"Vaša narudžba sa brojem {emailData.BrojNarudzbe} je zaprimljena.\n" +
                                 $"Datum narudžbe: {emailData.DatumNarudzbe.ToString("dd.MM.yyyy")}\n\n" +
                                 "Hvala na povjerenju!";

                // Kreiranje emaila
                var mailObj = new MimeMessage();
                mailObj.Sender = MailboxAddress.Parse(fromMail);
                mailObj.To.Add(MailboxAddress.Parse(recipientEmail));
                mailObj.Subject = subject;
                mailObj.Body = new TextPart(TextFormat.Plain)
                {
                    Text = content
                };

                // Slanje emaila putem SMTP klijenta
                using (var smtpClient = new SmtpClient())
                {
                    smtpClient.Connect(smtpServer, smtpPort, true);
                    smtpClient.Authenticate(fromMail, password);
                    smtpClient.Send(mailObj);
                    Console.WriteLine("Email sent successfully to: " + recipientEmail);
                    smtpClient.Disconnect(true);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending email: {ex.Message}");
            }
        }
    }
}
