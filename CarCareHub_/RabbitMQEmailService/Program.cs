namespace EmailService
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var consumer = new RabbitMQConsumer();
            consumer.Start();  // Početak slušanja poruka
        }
    }
}
