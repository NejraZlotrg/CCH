using CarCareHub.Model;
using System.Linq;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IChatAutoservisKlijentService
    {
        // Metoda za slanje poruke
        Task SendMessageAsync(ChatAutoservisKlijentInsert request);

        // Metoda za preuzimanje svih poruka između klijenta i autoservisa
        Task<IQueryable<Model.ChatAutoservisKlijent>> GetMessagesAsync(int klijentId, int autoservisId);

        public List<Model.ChatAutoservisKlijent> GetByID_(int targetId);


    }
}
