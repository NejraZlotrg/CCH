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
        public async Task SendMessageAsync(ChatAutoservisKlijentInsert request)
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
            var chatPoruka = new Database.ChatAutoservisKlijent
            {
                KlijentId = userRole == "Klijent" ? parsedUserId : request.KlijentId,
                AutoservisId = userRole == "Autoservis" ? parsedUserId : request.AutoservisId,
                Poruka = request.Poruka,
                PoslanoOdKlijenta = poslanoOdKlijenta,
                VrijemeSlanja = request.VrijemeSlanja
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

        public async Task<IQueryable<Model.ChatAutoservisKlijent>> GetMessagesAsync(int klijentId, int autoservisId)
        {
            var poruke = _context.ChatAutoservisKlijents
                .Include(p => p.Klijent)  // Učitaj povezani Klijent entitet
                .Include(p => p.Autoservis)  // Učitaj povezani Autoservis entitet
                .Where(p => p.KlijentId == klijentId && p.AutoservisId == autoservisId);

            // Mapiranje na model
            var result = poruke.Select(p => _mapper.Map<Model.ChatAutoservisKlijent>(p));

            return await Task.FromResult(result.AsQueryable());
        }

        public List<Model.ChatAutoservisKlijent> GetByID_(int targetId)
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
                var chatRecords = _context.ChatAutoservisKlijents.AsNoTracking()
                    .Where(x => x.KlijentId == parsedUserId)
                    .Include(x => x.Autoservis) // Include Autoservis entity
                    .Include(x => x.Klijent)    // Include Klijent entity
                    .GroupBy(x => x.AutoservisId)
                    .Select(g => g.First())
                    .ToList();

                // Check if any records were found
                if (chatRecords == null || !chatRecords.Any())
                {
                    Console.WriteLine("No data found for the client.");
                    throw new Exception("No data found.");
                }

                Console.WriteLine($"Found {chatRecords.Count} records for KlijentId: {parsedUserId}");
                return _mapper.Map<List<Model.ChatAutoservisKlijent>>(chatRecords);
            }
            else if (userRole == "Autoservis" && targetId == parsedUserId)
            {
                // Fetch chat records for the logged-in autoservis
                var chatRecords = _context.ChatAutoservisKlijents.AsNoTracking()
                    .Where(x => x.AutoservisId == parsedUserId)
                    .Include(x => x.Autoservis) // Include Autoservis entity
                    .Include(x => x.Klijent)    // Include Klijent entity
                    .GroupBy(x => x.KlijentId)
                    .Select(g => g.First())
                    .ToList();

                // Check if any records were found
                if (chatRecords == null || !chatRecords.Any())
                {
                    Console.WriteLine("No data found for the autoservis.");
                    throw new Exception("No data found.");
                }

                Console.WriteLine($"Found {chatRecords.Count} records for AutoservisId: {parsedUserId}");
                return _mapper.Map<List<Model.ChatAutoservisKlijent>>(chatRecords);
            }

            // If the role or targetId doesn't match, throw an exception
            throw new Exception("Unauthorized access or unsupported role.");
        }

    }
}



