using MimeKit;
using MailKit.Net.Smtp;
using System.Threading.Tasks;
using EmailService.Models;

namespace EmailService
{
    public class EmailSender
    {
        public async Task SendEmailAsync(NarudzbaMessage message)
        {
            try
            {
                // Log: Start sending email
                Console.WriteLine($"Start sending email to: {message.Email}");

                var email = new MimeMessage();
                email.From.Add(MailboxAddress.Parse("carcarehub3@gmail.com"));
                email.To.Add(MailboxAddress.Parse(message.Email));
                email.Subject = "Potvrda narudžbe";

                email.Body = new TextPart(MimeKit.Text.TextFormat.Plain)
                {
                    Text = $"Poštovani {message.ImePrezime},\n\nVaša narudžba broj {message.BrojNarudzbe} je uspješno zaprimljena dana {message.DatumNarudzbe:d}.\n\nHvala na povjerenju!"
                };

                using var smtp = new SmtpClient();
                await smtp.ConnectAsync("smtp.gmail.com", 587, false);
                await smtp.AuthenticateAsync("carcarehub3@gmail.com", "ggta vluj nkrw lqps");
                await smtp.SendAsync(email);
                await smtp.DisconnectAsync(true);

                // Log: Email sent successfully
                Console.WriteLine($"Email sent successfully to: {message.Email}");
            }
            catch (Exception ex)
            {
                // Log: Error in sending email
                Console.WriteLine($"Error while sending email to {message.Email}: {ex.Message}");
            }
        }
    }
}
