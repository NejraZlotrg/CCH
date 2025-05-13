using RabbitMQ.Client;
using System.Text;
using System.Text.Json;
using CarCareHub.Model;

public class MessageProducer
{
    public void SendMessage(NarudzbaMessage message)
    {
        var factory = new ConnectionFactory() { HostName = "localhost" };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        channel.QueueDeclare(queue: "narudzba-email-queue",
                             durable: false,
                             exclusive: false,
                             autoDelete: false,
                             arguments: null);

        var json = JsonSerializer.Serialize(message);
        var body = Encoding.UTF8.GetBytes(json);

        channel.BasicPublish(exchange: "",
                             routingKey: "narudzba-email-queue",
                             basicProperties: null,
                             body: body);
    }
}
