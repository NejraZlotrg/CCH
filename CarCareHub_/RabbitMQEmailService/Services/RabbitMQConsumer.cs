using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text.Json;
using EmailService.Models;

namespace EmailService
{
    public class RabbitMQConsumer
    {
        public void Start()
        {
            var factory = new ConnectionFactory()
            {
                HostName = "localhost" // koristi "rabbitmq" kad pređeš na docker
            };

            try
            {
                Console.WriteLine("Connecting to RabbitMQ...");

                using var connection = factory.CreateConnection();
                using var channel = connection.CreateModel();

                // Log: RabbitMQ connection established
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
                        // Log: Message received
                        Console.WriteLine($"Received message: {message.BrojNarudzbe}, {message.Email}");

                        var sender = new EmailSender();
                        await sender.SendEmailAsync(message);

                        // Log: Email sent
                        Console.WriteLine($"Email sent to: {message.Email}");
                    }
                    else
                    {
                        // Log: Deserialization failed
                        Console.WriteLine("Failed to deserialize message.");
                    }
                };

                channel.BasicConsume(queue: "narudzba-email-queue",
                                     autoAck: true,
                                     consumer: consumer);

                Console.WriteLine(" [*] Waiting for messages...");
                Console.ReadLine(); // da aplikacija ne završi odmah
            }
            catch (Exception ex)
            {
                // Log: Error during RabbitMQ connection
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
