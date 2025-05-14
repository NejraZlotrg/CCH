using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using RabbitMQConsumer;
using System.Text;

public class Program
{
    public static void Main(string[] args)
    {
        var factory = new ConnectionFactory
        {
            HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
            Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
            UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
            Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
            RequestedConnectionTimeout = TimeSpan.FromSeconds(30),
            RequestedHeartbeat = TimeSpan.FromSeconds(60),
            AutomaticRecoveryEnabled = true,
            NetworkRecoveryInterval = TimeSpan.FromSeconds(10),
        };

        factory.ClientProvidedName = "Rabbit Test Consumer";

        try
        {
            Console.WriteLine($"[INFO] Connecting to RabbitMQ at {factory.HostName}:{factory.Port} with user {factory.UserName}");
            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                Console.WriteLine("[INFO] Connected to RabbitMQ successfully.");

                string exchangeName = "EmailExchangeDurable";
                string routingKey = "email_queue";
                string queueName = "EmailQueue";

                channel.ExchangeDeclare(exchange: exchangeName, type: ExchangeType.Direct, durable: true);
                Console.WriteLine($"[INFO] Exchange '{exchangeName}' declared.");

                channel.QueueDeclare(queueName, durable: true, exclusive: false, autoDelete: false, arguments: null);
                channel.QueueBind(queueName, exchangeName, routingKey);

                Console.WriteLine($"[INFO] Exchange '{exchangeName}' and queue '{queueName}' bound with routing key '{routingKey}'.");

                var consumer = new EventingBasicConsumer(channel);

                consumer.Received += (sender, args) =>
                {
                    Console.WriteLine("[INFO] >>> Received message <<<");

                    var body = args.Body.ToArray();
                    string message = Encoding.UTF8.GetString(body);

                    Console.WriteLine($"[DEBUG] Raw message: {message}");

                    try
                    {
                        MailService emailService = new MailService();

                        Console.WriteLine("[INFO] Calling MailService.Send...");
                        emailService.Send(message);
                        Console.WriteLine("[INFO] MailService.Send completed.");

                        channel.BasicAck(args.DeliveryTag, false);
                        Console.WriteLine("[INFO] Message acknowledged (ACK).");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[ERROR] Failed to process message: {ex.Message}");
                    }
                };

                channel.BasicConsume(queueName, autoAck: false, consumer);

                Console.WriteLine("[INFO] Waiting for messages. Press CTRL+C to quit.");
                Thread.Sleep(Timeout.Infinite);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ERROR] Connection to RabbitMQ failed: {ex.Message}");
            Console.WriteLine(ex.ToString());
        }
    }
}
