using CarCareHub.Services.Database;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ChatService : IChatService
    {
        private readonly CchV2AliContext _context;

        public ChatService(CchV2AliContext context)
        {
            _context = context;
        }

        // Snimanje poruke u bazu
        public async Task SnimiPorukuAsync(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
        {
            var chatPoruka = new ChatAutoservisKlijent
            {
                KlijentId = klijentId,
                AutoservisId = autoservisId,
                Poruka = poruka,
                PoslanoOdKlijenta = poslanoOdKlijenta,
                VrijemeSlanja = DateTime.UtcNow
            };

            _context.ChatAUtoservisKlijents.Add(chatPoruka);
            await _context.SaveChangesAsync();
        }
    }
}
