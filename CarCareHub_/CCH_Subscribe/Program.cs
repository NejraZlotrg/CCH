// See https://aka.ms/new-console-template for more information
using EasyNetQ;
using CarCareHub.Model.Messages;
Console.WriteLine("Hello, World!");

var bus = RabbitHutch.CreateBus("host=localhost:5673");
await bus.PubSub.SubscribeAsync<ProizvodiActivated>("console_printer", msg => { Console.WriteLine($"productActivated{msg.Proizvod.Naziv}"); });

Console.WriteLine("Listening for messages, press <return> key to close");
Console.ReadLine();
