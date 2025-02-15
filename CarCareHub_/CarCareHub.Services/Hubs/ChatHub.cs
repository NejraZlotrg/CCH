using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace CarCareHub_.Hubs
{
    public class ChatHub : Hub
    {
        // Kada korisnik pošalje poruku
        public async Task SendMessage(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
        {
            var groupName = GetChatGroupName(klijentId, autoservisId);
            // Emituj poruku samo korisnicima u specifičnoj grupi (klijent + autoservis)
            await Clients.Group(groupName).SendAsync("ReceiveMessage", klijentId, autoservisId, poruka, poslanoOdKlijenta);
        }

        // Pomoćna metoda za generisanje imena grupe
        private string GetChatGroupName(int klijentId, int autoservisId)
        {
            // Kreira jedinstveno ime grupe na osnovu ID-eva klijenta i autoservisa
            return $"{klijentId}-{autoservisId}";
        }

        // Kada se korisnik pridruži chat sobi (grupi)
        public async Task JoinGroup(int klijentId, int autoservisId)
        {
            var groupName = GetChatGroupName(klijentId, autoservisId);
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName); // Dodajte korisnika u grupu
        }

        // Kada korisnik napusti chat sobu (grupu)
        public async Task LeaveGroup(int klijentId, int autoservisId)
        {
            var groupName = GetChatGroupName(klijentId, autoservisId);
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName); // Uklonite korisnika iz grupe
        }
    }
}
