using CarCareHub.Model;
using System.Linq;
using System.Threading.Tasks;
using static CarCareHub.Services.ChatAutoservisKlijentService;

namespace CarCareHub.Services
{
    public interface IChatAutoservisKlijentService
    {
        Task SendMessageAsync(ChatAutoservisKlijentInsert request);
        Task<IQueryable<PorukaDTO>> GetMessagesAsync(int klijentId, int autoservisId);
        public List<PorukaDTO> GetByID_(int targetId);
    }
}
