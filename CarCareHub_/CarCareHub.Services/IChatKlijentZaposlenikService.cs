using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IChatKlijentZaposlenikService
    {
        // Metoda za slanje poruke
        Task SendMessageAsync(ChatKlijentZaposlenikInsert request);

        // Metoda za preuzimanje svih poruka između klijenta i autoservisa
        Task<IQueryable<Model.ChatKlijentZaposlenik>> GetMessagesAsync(int klijentId, int zaposlenikId);

        public List<Model.ChatKlijentZaposlenik> GetByID_(int targetId);


    }
}
