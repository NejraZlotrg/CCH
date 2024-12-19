using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.AspNetCore.Http;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ChatAutoservisKlijentService : BaseCRUDService<Model.ChatAutoservisKlijent, Database.ChatAutoservisKlijent, ChatAKSearchObject, ChatAutoservisKlijentInsert, ChatAutoservisKlijentUpdate>, IChatAutoservisKlijentService
    {
        private readonly CchV2AliContext _context;
        private readonly IMapper _mapper;
        private readonly IHttpContextAccessor _httpContextAccessor;


        public ChatAutoservisKlijentService(CchV2AliContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _httpContextAccessor = httpContextAccessor;

        }

        // Snimanje poruke u bazu
        public async Task SendMessageAsync(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
        {

            // Get the logged-in user from the context
            var user = _httpContextAccessor.HttpContext.User;

            // Retrieve the logged-in user's ID from the claims (you can also add other user-specific data)
            var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            //var who=user;

            if (string.IsNullOrEmpty(userId))
            {
                throw new Exception("User ID is missing from claims. ");
            }

            // Validate and parse userId
            if (!int.TryParse(userId, out int parsedUserId))
            {
                throw new Exception($"User ID '{userId}' is invalid or not a number.");
            }

            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            var chatPoruka = new ChatAutoservisKlijentInsert
            {
                KlijentId = klijentId,
                AutoservisId = autoservisId,
                Poruka = poruka,
                PoslanoOdKlijenta = poslanoOdKlijenta,
                VrijemeSlanja = DateTime.UtcNow
            };

            if (userRole != null)
            {
                if (userRole != null)
                {
                    // Dodjeljivanje ID-a na osnovu uloge korisnika
                    switch (userRole)
                    {
                        case "Klijent":
                            chatPoruka.KlijentId = parsedUserId; // Set KlijentId for logged-in client
                            break;
                        case "Autoservis":
                            chatPoruka.AutoservisId = parsedUserId; // Set AutoservisId for logged-in service
                            break;

                        default:
                            throw new Exception("Unknown user role.");
                    }
                }

                // Ispis koji ID je dodijeljen
            }
            else
            {
                throw new Exception("User role is not available.");
            }

            if (string.IsNullOrWhiteSpace(poruka))
            {
                throw new ArgumentException("Poruka ne smije biti prazna.", nameof(poruka));
            }


            try
            {
                // Mapiranje objekta
                var temp = _mapper.Map<Database.ChatAutoservisKlijent>(chatPoruka);

                // Dodavanje u bazu
                _context.ChatAutoservisKlijents.Add(temp);
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                // Logujte grešku ili ponovo bacite izuzetak za praćenje
                throw new InvalidOperationException("Greška prilikom snimanja poruke u bazu.", ex);
            }
        }
    }
}
