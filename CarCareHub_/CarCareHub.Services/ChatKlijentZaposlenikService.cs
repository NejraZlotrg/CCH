using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using CarCareHub_.Hubs;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ChatKlijentZaposlenikService : IChatKlijentZaposlenikService
    {
        private readonly CchV2AliContext _context;
        private readonly IMapper _mapper;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IHubContext<ChatHub> _hubContext;

        public ChatKlijentZaposlenikService(CchV2AliContext context, IMapper mapper,
            IHttpContextAccessor httpContextAccessor,
            IHubContext<ChatHub> hubContext)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _httpContextAccessor = httpContextAccessor;
            _hubContext = hubContext;
        }

        // Snimanje poruke u bazu
        public async Task SendMessageAsync(ChatKlijentZaposlenikInsert request)
        {
            var user = _httpContextAccessor.HttpContext.User;
            var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int parsedUserId))
            {
                throw new Exception("Nevažeći korisnički ID.");
            }

            var userRole = user?.FindFirst(ClaimTypes.Role)?.Value;
            if (string.IsNullOrWhiteSpace(userRole))
            {
                throw new Exception("Uloga korisnika nije dostupna.");
            }

            // Postavljanje trenutnog vremena slanja
            request.VrijemeSlanja = DateTime.UtcNow;


            // Postavljanje vrijednosti PoslanoOdKlijenta na osnovu korisničke uloge

            bool poslanoOdKlijenta = userRole == "Klijent";


            // Prilagođavanje ID-jeva prema ulozi korisnika
            var chatPoruka = new Database.ChatKlijentZaposlenik
            {
                KlijentId = userRole == "Klijent" ? parsedUserId : request.KlijentId,
                ZaposlenikId = userRole == "Zaposlenik" ? parsedUserId : request.ZaposlenikId,
                Poruka = request.Poruka,
                PoslanoOdKlijenta = poslanoOdKlijenta,
                VrijemeSlanja = request.VrijemeSlanja
            };

            try
            {
                await _context.ChatKlijentZaposleniks.AddAsync(chatPoruka);

                await _hubContext.Clients.All.SendAsync($"ReceiveMessageZaposlenikKlijent#{chatPoruka.KlijentId}/{chatPoruka.ZaposlenikId}");
                await _hubContext.Clients.All.SendAsync($"ReceiveMessageZaposlenikKlijent#{chatPoruka.ZaposlenikId}/{chatPoruka.KlijentId}");

                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Greška prilikom snimanja poruke u bazu.", ex);
            }
        }

        public async Task<IQueryable<Model.ChatKlijentZaposlenik>> GetMessagesAsync(int klijentId, int zaposlenikId)
        {
            var poruke = _context.ChatKlijentZaposleniks
                .Include(p => p.Klijent).Include(p => p.Klijent.Grad)  // Učitaj povezani Klijent entitet
                .Include(p => p.Klijent.uloga)  // Učitaj povezani Klijent entitet
                .Include(p => p.Klijent.ChatAutoservisKlijent)  // Učitaj povezani Klijent entitet
                .Include(p => p.Klijent.ChatKlijentZaposlenik)  // Učitaj povezani Klijent entitet // Učitaj povezani Klijent entitet
                .Include(p => p.Zaposlenik)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Grad)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Grad.Drzava)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Uloga)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis.Uloga)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis.Zaposleniks)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis.Usluges)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis.Vozilo)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis.Grad)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.Autoservis.Grad.Drzava)  // Učitaj povezani Autoservis entitet

                .Include(p => p.Zaposlenik.FirmaAutodijelova)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.FirmaAutodijelova.Uloga)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.FirmaAutodijelova.Grad)  // Učitaj povezani Autoservis entitet
                .Include(p => p.Zaposlenik.FirmaAutodijelova.Grad.Drzava)  // Učitaj povezani Autoservis entitet
                .Where(p => p.KlijentId == klijentId && p.ZaposlenikId == zaposlenikId);

            // Mapiranje na model
            var result = poruke.Select(p => _mapper.Map<Model.ChatKlijentZaposlenik>(p));

            return result;
        }

        public List<Model.ChatKlijentZaposlenik> GetByID_(int targetId)
        {
            var user = _httpContextAccessor.HttpContext.User;

            // Retrieve user details from claims
            var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userRole = user?.FindFirst(ClaimTypes.Role)?.Value;

            Console.WriteLine($"UserID: {userId}");
            Console.WriteLine($"UserRole: {userRole}");

            // Validate user claims
            if (string.IsNullOrEmpty(userId))
                throw new Exception("User ID is missing from claims.");

            if (!int.TryParse(userId, out int parsedUserId))
                throw new Exception($"Invalid User ID: {userId}");

            // Determine the role and execute the corresponding logic
            if (userRole == "Klijent" && targetId == parsedUserId)
            {
                // Fetch chat records for the logged-in client
                var chatRecords = _context.ChatKlijentZaposleniks.AsNoTracking()
     .Where(x => x.KlijentId == parsedUserId)
     .Include(x => x.Zaposlenik) // Include Zaposlenik entity
     .ThenInclude(z => z.Uloga) // Include Uloga for Zaposlenik
     .Include(x => x.Zaposlenik.Autoservis) // Include Autoservis for Zaposlenik
     .ThenInclude(a => a.Usluges) // Include Usluges for Autoservis
     .Include(x => x.Zaposlenik.Autoservis.Vozilo) // Include Vozilo for Autoservis
     .Include(x => x.Zaposlenik.Autoservis.Grad) // Include Grad for Autoservis
     .ThenInclude(g => g.Drzava) // Include Drzava for Grad
     .Include(x => x.Klijent) // Include Klijent entity
     .ThenInclude(k => k.uloga) // Include Uloga for Klijent
     .Include(x => x.Klijent.Grad) // Include Grad for Klijent
     .ThenInclude(g => g.Drzava) // Include Drzava for Grad
     .GroupBy(x => x.ZaposlenikId)
     .Select(g => g.First())
     .ToList();


                // Check if any records were found
                if (chatRecords == null || !chatRecords.Any())
                {
                    Console.WriteLine("No data found for the client.");
                    throw new Exception("No data found.");
                }

                Console.WriteLine($"Found {chatRecords.Count} records for KlijentId: {parsedUserId}");
                return _mapper.Map<List<Model.ChatKlijentZaposlenik>>(chatRecords);
            }
            else if (userRole == "Zaposlenik" && targetId == parsedUserId)
            {
                // Fetch chat records for the logged-in autoservis
                var chatRecords = _context.ChatKlijentZaposleniks.AsNoTracking()
                    .Where(x => x.ZaposlenikId == parsedUserId)
                    .Include(x => x.Zaposlenik) // Include Autoservis entity
                    .Include(x => x.Klijent)    // Include Klijent entity
                    .GroupBy(x => x.KlijentId)
                    .Select(g => g.First())
                    .ToList();

                // Check if any records were found
                if (chatRecords == null || !chatRecords.Any())
                {
                    Console.WriteLine("No data found for the zaposlenik.");
                    throw new Exception("No data found.");
                }

                Console.WriteLine($"Found {chatRecords.Count} records for ZaposlenikId: {parsedUserId}");
                return _mapper.Map<List<Model.ChatKlijentZaposlenik>>(chatRecords);
            }

            // If the role or targetId doesn't match, throw an exception
            throw new Exception("Unauthorized access or unsupported role.");
        }

    }
}
