using MimeKit;
using MailKit.Net.Smtp;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using EmailService.Models;

public class EmailSender
{
    public async Task SendEmailAsync(EmailMessage message)
    {
        var email = new MimeMessage();
        email.From.Add(MailboxAddress.Parse("carcarehub3@gmail.com"));
        email.To.Add(MailboxAddress.Parse(message.To));
        email.Subject = message.Subject;
        email.Body = new TextPart(MimeKit.Text.TextFormat.Text) { Text = message.Body };

        using var smtp = new SmtpClient();
        await smtp.ConnectAsync("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
        await smtp.AuthenticateAsync("carcarehub3@gmail.com", "ggta vluj nkrw lqps");
        await smtp.SendAsync(email);
        await smtp.DisconnectAsync(true);
    }
}
