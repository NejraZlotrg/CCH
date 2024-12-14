using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.AspNetCore.Http; // To access the current user
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class KorpaService : BaseCRUDService<Model.Korpa, Database.Korpa, KorpaSearchObject, KorpaInsert, KorpaUpdate>, IKorpaService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public KorpaService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task<Model.Korpa> Insert(Model.KorpaInsert insert)
        {
            var korpa = _mapper.Map<Database.Korpa>(insert);

            // Dobavljanje cijene proizvoda iz baze podataka DODATI U KORPU
            var proizvod = await _dbContext.Proizvods.FindAsync(insert.ProizvodId);

            // Provjera da li je pronađen proizvod
            if (proizvod != null)
            {
                // Izračunavanje UkupneCijene
                korpa.UkupnaCijenaProizvoda = proizvod.CijenaSaPopustom != null ? proizvod.CijenaSaPopustom * insert.Kolicina : proizvod.Cijena * insert.Kolicina;

                // Postavljanje navigacionog property-ja Proizvod
                korpa.Proizvod = proizvod;
            }
            else
            {
                throw new Exception("Proizvod nije pronađen.");
            }

            // Get the logged-in user from the context
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

            var userRole = user?.FindFirst(ClaimTypes.Role)?.Value;

            if (userRole != null)
            {
                // Reset all IDs to null
                korpa.KlijentId = null;
                korpa.ZaposlenikId = null;
                korpa.AutoservisId = null;

                // Dodjeljivanje ID-a na osnovu uloge korisnika
                switch (userRole)
                {
                    case "Klijent":
                        korpa.KlijentId = parsedUserId; // Set KlijentId for logged-in client
                        break;

                    case "Zaposlenik":
                        korpa.ZaposlenikId = parsedUserId; // Set ZaposlenikId for logged-in employee
                        break;

                    case "Autoservis":
                        korpa.AutoservisId = parsedUserId; // Set AutoservisId for logged-in service
                        break;

                    default:
                        throw new Exception("Unknown user role.");
                }

                // Ispis koji ID je dodijeljen
                Console.WriteLine($"Assigned KlijentId: {korpa.KlijentId}");
                Console.WriteLine($"Assigned ZaposlenikId: {korpa.ZaposlenikId}");
                Console.WriteLine($"Assigned AutoservisId: {korpa.AutoservisId}");
            }
            else
            {
                throw new Exception("User role is not available.");
            }

            // Spremanje u bazu podataka
            await _dbContext.Korpas.AddAsync(korpa);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Korpa>(korpa);
        }

        public override IQueryable<Database.Korpa> AddInclude(IQueryable<Database.Korpa> query, KorpaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Proizvod);
                query = query.Include(z => z.NarudzbaStavkas);
                query = query.Include(z => z.Zaposlenik);
                query = query.Include(z => z.Autoservis);
                query = query.Include(z => z.Klijent);
            }
            return base.AddInclude(query, search);
        }

        public override async Task<List<Model.Korpa>> GetByID_(int id)
        {
            // Početni upit
            var query = _dbContext.Korpas.AsQueryable();

            // Dohvati trenutnu prijavljenu ulogu korisnika
            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            // Filtriranje na temelju korisničke uloge
            if (userRole != null)
            {
                switch (userRole)
                {
                    case "Klijent":
                        // Ako je korisnik Klijent, filtriraj samo po KlijentId
                        query = query.Where(x => x.KlijentId == id);
                        break;

                    case "Zaposlenik":
                        // Ako je korisnik Zaposlenik, filtriraj samo po ZaposlenikId
                        query = query.Where(x => x.ZaposlenikId == id);
                        break;

                    case "Autoservis":
                        // Ako je korisnik Autoservis, filtriraj samo po AutoservisId
                        query = query.Where(x => x.AutoservisId == id);
                        break;

                    default:
                        throw new Exception("Nepoznata uloga korisnika.");
                }
            }
            else
            {
                throw new Exception("Korisnička uloga nije dostupna.");
            }

            // Pretvaranje rezultata u listu i mapiranje na Model.Korpa
            var result = await query.ToListAsync();  // Koristimo ToListAsync() da bi operacija bila asinhrona

            return _mapper.Map<List<Model.Korpa>>(result);
        }


    }

}
