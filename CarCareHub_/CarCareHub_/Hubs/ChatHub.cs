using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace CarCareHub_.Hubs
{
    public class ChatHub : Hub
    {
        // Metoda za slanje poruke
        public async Task PosaljiPoruku(int klijentId, int autoservisId, string poruka)
        {
            // Emituj poruku svim klijentima
            await Clients.All.SendAsync("PrimiPoruku", klijentId, autoservisId, poruka);
        }
    }
}
