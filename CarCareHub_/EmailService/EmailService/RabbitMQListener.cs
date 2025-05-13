using EmailService.Models;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

public class RabbitMqListener : BackgroundService
{
    private readonly EmailSender _emailSender;

    public RabbitMqListener(IServiceProvider serviceProvider)
    {
        _emailSender = serviceProvider.CreateScope().ServiceProvider.GetRequiredService<EmailSender>();
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Console.WriteLine("[INFO] RabbitMQ Listener starting...");

        var factory = new ConnectionFactory() { HostName = "localhost" };
        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        Console.WriteLine("[INFO] RabbitMQ connection and channel established.");

        channel.QueueDeclare(queue: "email_queue",
                             durable: false,
                             exclusive: false,
                             autoDelete: false,
                             arguments: null);

        Console.WriteLine("[INFO] Queue declared: email_queue");
        Console.WriteLine("[INFO] Waiting for messages...");

        var consumer = new EventingBasicConsumer(channel);
        consumer.Received += async (model, ea) =>
        {
            Console.WriteLine("[INFO] Message received from RabbitMQ.");

            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);

            Console.WriteLine("[DEBUG] Raw message JSON: " + json);

            try
            {
                var message = JsonSerializer.Deserialize<EmailMessage>(json);
                if (message != null)
                {
                    Console.WriteLine("[INFO] Parsed EmailMessage:");
                    Console.WriteLine($"        To: {message.To}");
                    Console.WriteLine($"   Subject: {message.Subject}");
                    Console.WriteLine($"      Body: {message.Body}");

                    await _emailSender.SendEmailAsync(message);

                    Console.WriteLine("[SUCCESS] Email sent successfully.");
                }
                else
                {
                    Console.WriteLine("[ERROR] Deserialized message is null.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("[ERROR] Failed to process message: " + ex.Message);
            }
        };

        channel.BasicConsume(queue: "email_queue",
                             autoAck: true,
                             consumer: consumer);

        // Keep service alive
        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(1000, stoppingToken);
        }

        Console.WriteLine("[INFO] RabbitMQ Listener stopping...");
    }
}
