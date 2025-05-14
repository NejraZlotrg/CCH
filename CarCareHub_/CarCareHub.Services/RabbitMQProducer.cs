using CarCareHub.Services;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System.Text;
using Microsoft.Extensions.Logging;


public class RabbitMQProducer : IRabbitMQProducer
{
    private readonly ILogger<RabbitMQProducer> _logger;

    public RabbitMQProducer(ILogger<RabbitMQProducer> logger)
    {
        _logger = logger;
    }

    public void SendMessage<T>(T message)
    {
        try
        {
            var factory = new ConnectionFactory
            {
                HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
                Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
                DispatchConsumersAsync = true
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            string exchangeName = "EmailExchangeDurable";
            string routingKey = "email_queue";
            string queueName = "EmailQueue";

            channel.ExchangeDeclare(exchangeName, ExchangeType.Direct, durable: true);
            channel.QueueDeclare(queueName, durable: true, exclusive: false, autoDelete: false);
            channel.QueueBind(queueName, exchangeName, routingKey);

            var emailModelJson = JsonConvert.SerializeObject(message);
            var body = Encoding.UTF8.GetBytes(emailModelJson);

            var properties = channel.CreateBasicProperties();
            properties.Persistent = true;

            channel.BasicPublish(exchangeName, routingKey, properties, body);
            _logger.LogInformation("Message sent to RabbitMQ");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending message to RabbitMQ");
            throw; // Re-throw to let caller handle the error
        }
    }
}