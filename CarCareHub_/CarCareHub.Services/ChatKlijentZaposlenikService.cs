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
        public async Task<IQueryable<PorukaKZDTO>> GetMessagesAsync(int klijentId, int zaposlenikId)
        {
            var poruke = _context.ChatKlijentZaposleniks
                .Include(p => p.Klijent)
                .Include(p => p.Zaposlenik)
                .Where(p => p.KlijentId == klijentId && p.ZaposlenikId == zaposlenikId);
            // Mapiranje na model
            var result = poruke.Select(p => new PorukaKZDTO
            {
                Id = p.ChatKlijentZaposlenikId,
                KlijentId = p.KlijentId,
                KlijentIme = p.Klijent.Ime,
                ZaposlenikId = p.ZaposlenikId,
                ZaposlenikIme = p.Zaposlenik.Ime,
                Poruka = p.Poruka,
                PoslanoOdKlijenta = p.PoslanoOdKlijenta,
                VrijemeSlanja = p.VrijemeSlanja
            }
             ).ToList();
            return result.AsQueryable();
        }
        public class PorukaKZDTO
        {
            public int Id { get; set; }
            public int KlijentId { get; set; }
            public string KlijentIme { get; set; }
            public string ZaposlenikIme { get; set; }
            public int ZaposlenikId { get; set; }
            public string Poruka { get; set; }
            public bool PoslanoOdKlijenta { get; set; }
            public DateTime VrijemeSlanja { get; set; }
        }
        public List<PorukaKZDTO> GetByID_(int targetId)
        {
            var user = _httpContextAccessor.HttpContext.User;
            var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var userRole = user?.FindFirst(ClaimTypes.Role)?.Value;
            Console.WriteLine($"UserID: {userId}");
            Console.WriteLine($"UserRole: {userRole}");
            if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int parsedUserId))
                throw new Exception("Invalid or missing User ID.");
            if (userRole == "Klijent" && targetId == parsedUserId)
            {
                var chatRecords = _context.ChatKlijentZaposleniks.AsNoTracking()
                    .Where(x => x.KlijentId == parsedUserId)
                    .Include(x => x.Zaposlenik)
                    .Include(x => x.Klijent)
                    .GroupBy(x => x.ZaposlenikId)
                    .Select(g => g.First())
                    .ToList();
                                if (!chatRecords.Any())
                    throw new Exception("No data found.");
                return chatRecords.Select(x => new PorukaKZDTO
                {
                    KlijentId = x.Klijent.KlijentId,
                    KlijentIme = x.Klijent.Ime,
                    ZaposlenikId = x.Zaposlenik.ZaposlenikId,
                    ZaposlenikIme = x.Zaposlenik.Ime,
                }).ToList();
            }
            else if (userRole == "Zaposlenik" && targetId == parsedUserId)
            {
                var chatRecords = _context.ChatKlijentZaposleniks.AsNoTracking()
                    .Where(x => x.ZaposlenikId == parsedUserId)
                    .Include(x => x.Zaposlenik) 
                    .Include(x => x.Klijent)    
                    .GroupBy(x => x.KlijentId)
                    .Select(g => g.First())
                    .ToList();
                if (!chatRecords.Any())
                {
                    Console.WriteLine("No data found for the zaposlenik.");
                    throw new Exception("No data found.");
                }
                return chatRecords.Select(x => new PorukaKZDTO
                {
                    KlijentId = x.Klijent.KlijentId,
                    KlijentIme = x.Klijent.Ime,
                    ZaposlenikId = x.Zaposlenik.ZaposlenikId,
                    ZaposlenikIme = x.Zaposlenik.Ime
                }).ToList();
            }
            throw new Exception("Unauthorized access or unsupported role.");
        }
    }
}
