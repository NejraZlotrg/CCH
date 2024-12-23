using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
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

        public List<Model.ChatAutoservisKlijent> GetByID_()
        {
            var user = _httpContextAccessor.HttpContext.User;

            // Retrieve the logged-in user's ID from the claims (you can also add other user-specific data)
            var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userId))
            {
                throw new Exception("User ID is missing from claims.");
            }

            // Validate and parse userId
            if (!int.TryParse(userId, out int parsedUserId))
            {
                throw new Exception($"User ID '{userId}' is invalid or not a number.");
            }

            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole != null)
            {
                // Reset all IDs to null
                var noviId = 0;
                if (userRole == "Klijent")
                {
                    noviId = parsedUserId; // Set KlijentId for logged-in client

                    // Use Include before Select
                    var temp = _context.ChatAutoservisKlijents.AsNoTracking()
                        .Where(x => x.KlijentId == noviId)
                        .Include(x => x.Autoservis)  // Include the Autoservis entity before Select
                        .Include(x => x.Klijent)     // Include the Klijent entity before Select
                        .GroupBy(x => x.AutoservisId) // Group by AutoservisId
                        .Select(g => g.First())      // Take the first unique entry
                        .ToList(); // Execute the query and convert to a list

                    // Ispis koji ID je dodijeljen
                    Console.WriteLine($"Assigned KlijentId: {noviId} : {userRole}");
                    Console.WriteLine($"Assigned AutoservisId: {noviId} : {userRole}");

                    // Mapiraj rezultate na odgovarajući model
                    return _mapper.Map<List<Model.ChatAutoservisKlijent>>(temp);
                }
                else if (userRole == "Autoservis")
                {
                    noviId = parsedUserId; // Set AutoservisId for logged-in service

                    // Use Include before Select
                    var temp2 = _context.ChatAutoservisKlijents.AsNoTracking()
                        .Where(x => x.AutoservisId == noviId)
                        .Include(x => x.Autoservis)  // Include the Autoservis entity before Select
                        .Include(x => x.Klijent)     // Include the Klijent entity before Select
                        .GroupBy(x => x.KlijentId)  // Group by KlijentId
                        .Select(g => g.First())      // Take the first unique entry
                        .ToList(); // Execute the query and convert to a list

                    // Ispis koji ID je dodijeljen
                    Console.WriteLine($"Assigned KlijentId: {noviId} : {userRole}");
                    Console.WriteLine($"Assigned AutoservisId: {noviId} : {userRole}");

                    // Mapiraj rezultate na odgovarajući model
                    return _mapper.Map<List<Model.ChatAutoservisKlijent>>(temp2);
                }
            }
            else
            {
                throw new Exception("Unknown user role.");
            }

            return null;
        }


    }
}
