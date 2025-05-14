using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using EmailService.Models;
using EmailService;

public class RabbitMQConsumer
{
    private readonly CancellationTokenSource _cancellationTokenSource = new();

    public async Task Start()
    {
        var factory = new ConnectionFactory()
        {
            HostName = "rabbitmq",
            UserName = "guest",
            Password = "guest",
            Port = 5672
        };

        try
        {
            Console.WriteLine("Connecting to RabbitMQ...");

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            Console.WriteLine("Connected to RabbitMQ");

            channel.QueueDeclare(queue: "narudzba-email-queue",
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var json = Encoding.UTF8.GetString(body);
                var message = JsonSerializer.Deserialize<NarudzbaMessage>(json);

                if (message != null)
                {
                    Console.WriteLine($"Received message: {message.BrojNarudzbe}, {message.Email}");
                    var sender = new EmailSender();
                    await sender.SendEmailAsync(message);
                    Console.WriteLine($"Email sent to: {message.Email}");
                }
                else
                {
                    Console.WriteLine("Failed to deserialize message.");
                }
            };

            channel.BasicConsume(queue: "narudzba-email-queue",
                               autoAck: true,
                               consumer: consumer);

            Console.WriteLine(" [*] Waiting for messages...");

            // Čekamo dok se ne zatraži prekid
            await Task.Delay(Timeout.Infinite, _cancellationTokenSource.Token);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
            throw; // Dodaj throw da bi Docker video da je došlo do greške  
        }
    }

    public void Stop()
    {
        _cancellationTokenSource.Cancel();
    }
}