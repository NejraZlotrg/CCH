namespace EmailService
{
    internal class Program
    {
        public static async Task Main(string[] args)
        {
            Console.WriteLine("Starting RabbitMQ Consumer...");

            var maxRetries = 5;
            var retryCount = 0;

            while (retryCount < maxRetries)
            {
                try
                {
                    var consumer = new RabbitMQConsumer();
                    await consumer.Start();

                    // Ako se StartAsync vrati (što ne bi trebalo), čekamo beskonačno
                    await Task.Delay(Timeout.Infinite);
                }
                catch (Exception ex)
                {
                    retryCount++;
                    Console.WriteLine($"ERROR (Attempt {retryCount}/{maxRetries}): {ex}");
                    await Task.Delay(5000); // Čekaj 5 sekundi pre ponovnog pokušaja
                }
            }

            Console.WriteLine("Max retries reached. Exiting...");
            Environment.Exit(1);
        }
    }
}
