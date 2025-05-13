using EmailService.Services;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using Microsoft.Extensions.DependencyInjection;
using RabbitMQ.Client.Events;

var builder = WebApplication.CreateBuilder(args);

// Dodaj RabbitMQ postavke
builder.Services.Configure<RabbitMQSettings>(builder.Configuration.GetSection("RabbitMQSettings"));

// Registruj servis za slanje emailova
builder.Services.AddSingleton<EmailSenders>();

// Registruj RabbitMqListener servis kao background worker
builder.Services.AddHostedService<RabbitMqListener>();

// Add services to the container.
builder.Services.AddOpenApi();

// Build aplikaciju
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

// Kreiraj klasu za RabbitMQ postavke
public class RabbitMQSettings
{
    public string HostName { get; set; }
    public string QueueName { get; set; }
}

// Kreiraj servis za slanje emailova (EmailSender)
namespace EmailService.Services
{
    public class EmailSenders
    {
        private readonly RabbitMQSettings _rabbitMQSettings;
        public EmailSenders(IOptions<RabbitMQSettings> options)
        {
            _rabbitMQSettings = options.Value;
        }

        public void SendEmail(string to, string subject, string body)
        {
            // Ovdje ide logika za slanje emaila preko RabbitMQ-a
            Console.WriteLine($"Sending email to {to} with subject {subject}");
        }
    }
}

// Kreiraj listener servis koji sluša poruke sa RabbitMQ-a
public class RabbitMqListener : BackgroundService
{
    private readonly IOptions<RabbitMQSettings> _settings;
    private readonly EmailSenders _emailSender;

    public RabbitMqListener(IOptions<RabbitMQSettings> settings, EmailSenders emailSender)
    {
        _settings = settings;
        _emailSender = emailSender;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory() { HostName = _settings.Value.HostName };
        using (var connection = factory.CreateConnection())
        using (var channel = connection.CreateModel())
        {
            channel.QueueDeclare(queue: _settings.Value.QueueName,
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);

            Console.WriteLine("Waiting for messages.");

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = System.Text.Encoding.UTF8.GetString(body);
                Console.WriteLine("Received message: {0}", message);

                // Ovdje možeš implementirati slanje emaila na osnovu poruke
                _emailSender.SendEmail("recipient@example.com", "Subject", message);
            };

            channel.BasicConsume(queue: _settings.Value.QueueName,
                                 autoAck: true,
                                 consumer: consumer);

            await Task.CompletedTask;
        }
    }
}

// Kreiraj record za WeatherForecast
record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
