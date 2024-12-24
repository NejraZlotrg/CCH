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


        //    public List<Model.ChatAutoservisKlijent> GetByID_Klijent(int id_autoservis)
        //    {
        //        var user = _httpContextAccessor.HttpContext.User;

        //        // Retrieve user details from claims
        //        var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        //        var userRole = user?.FindFirst(ClaimTypes.Role)?.Value;

        //        Console.WriteLine($"UserID: {userId}");
        //        Console.WriteLine($"UserRole: {userRole}");

        //        // Validate user claims
        //        if (string.IsNullOrEmpty(userId))
        //            throw new Exception("User ID is missing from claims.");

        //        if (!int.TryParse(userId, out int parsedUserId))
        //            throw new Exception($"Invalid User ID: {userId}");

        //        // Check if the user has the Autoservis role and the ID matches
        //        if (userRole == "Autoservis" && id_autoservis.ToString() == userId)
        //        {
        //            // Query the database for relevant records
        //            var chatAutoservisKlijents = _context.ChatAutoservisKlijents.AsNoTracking()
        //                .Where(x => x.AutoservisId == parsedUserId)
        //                .Include(x => x.Autoservis) // Include Autoservis entity
        //                .Include(x => x.Klijent)    // Include Klijent entity
        //                .GroupBy(x => x.KlijentId) // Group by KlijentId
        //                .Select(g => g.First())    // Select the first entry from each group
        //                .ToList();

        //            // Check if the query returned results
        //            if (chatAutoservisKlijents == null || !chatAutoservisKlijents.Any())
        //            {
        //                Console.WriteLine("No data found.");
        //                throw new Exception("No data found.");
        //            }

        //            // Log the number of records found
        //            Console.WriteLine($"Found {chatAutoservisKlijents.Count} records for AutoservisID: {parsedUserId}");

        //            // Map the results to the model and return
        //            return _mapper.Map<List<Model.ChatAutoservisKlijent>>(chatAutoservisKlijents);
        //        }

        //        // Throw an exception for unauthorized access or unsupported role
        //        throw new Exception("Unauthorized access or unsupported role.");
        //    }


        //}
    }
}



