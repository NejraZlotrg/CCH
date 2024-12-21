using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using Microsoft.AspNetCore.Http;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ChatAutoservisKlijentService : IChatAutoservisKlijentService
    {
        private readonly CchV2AliContext _context;
        private readonly IMapper _mapper;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ChatAutoservisKlijentService(CchV2AliContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _httpContextAccessor = httpContextAccessor;
        }

        // Snimanje poruke u bazu
        public async Task SendMessageAsync(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
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

            if (string.IsNullOrWhiteSpace(poruka))
            {
                throw new ArgumentException("Poruka ne smije biti prazna.", nameof(poruka));
            }

            var chatPoruka = new Database.ChatAutoservisKlijent
            {
                KlijentId = userRole == "Klijent" ? parsedUserId : klijentId,
                AutoservisId = userRole == "Autoservis" ? parsedUserId : autoservisId,
                Poruka = poruka,
                PoslanoOdKlijenta = poslanoOdKlijenta,
                VrijemeSlanja = DateTime.UtcNow
            };

            try
            {
                _context.ChatAutoservisKlijents.Add(chatPoruka);
                await _context.SaveChangesAsync();



            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("Greška prilikom snimanja poruke u bazu.", ex);
            }
        }

        // Dohvaćanje poruka između klijenta i autoservisa
        public async Task<IQueryable<Model.ChatAutoservisKlijent>> GetMessagesAsync(int klijentId, int autoservisId) 
        {
            var poruke = _context.ChatAutoservisKlijents
                .Where(p => p.KlijentId == klijentId && p.AutoservisId == autoservisId);

            var result = poruke.Select(p => _mapper.Map<Model.ChatAutoservisKlijent>(p));
            return await Task.FromResult(result.AsQueryable());
        }
    }
}
