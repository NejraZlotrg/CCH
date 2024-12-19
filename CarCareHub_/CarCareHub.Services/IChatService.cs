using CarCareHub.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IChatService
    {
        // Metoda za slanje poruke
        Task SendMessageAsync(int klijentId, int autoservisId, string message, bool poslanoOdKlijenta);

        // Metoda za preuzimanje svih poruka između klijenta i autoservisa
        Task<List<Poruka>> GetMessagesAsync(int klijentId, int autoservisId);
    }
}
