using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CarCareHub.Services.ChatKlijentZaposlenikService;

namespace CarCareHub.Services
{
    public interface IChatKlijentZaposlenikService
    {
        Task SendMessageAsync(ChatKlijentZaposlenikInsert request);
        Task<IQueryable<PorukaKZDTO>> GetMessagesAsync(int klijentId, int zaposlenikId);
        public List<PorukaKZDTO> GetByID_(int targetId);
    }
}
