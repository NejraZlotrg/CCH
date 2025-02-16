using CarCareHub.Model;
using System.Linq;
using System.Threading.Tasks;
using static CarCareHub.Services.ChatAutoservisKlijentService;

namespace CarCareHub.Services
{
    public interface IChatAutoservisKlijentService
    {
        // Metoda za slanje poruke
        Task SendMessageAsync(ChatAutoservisKlijentInsert request);

        // Metoda za preuzimanje svih poruka između klijenta i autoservisa
        Task<IQueryable<PorukaDTO>> GetMessagesAsync(int klijentId, int autoservisId);

        public List<PorukaDTO> GetByID_(int targetId);


    }
}
