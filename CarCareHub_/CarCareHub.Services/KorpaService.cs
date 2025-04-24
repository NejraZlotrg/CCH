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
        public KorpaService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }
        public async void KreirajNarudzbu(long userId)
        {
            var korpa = await _dbContext.Korpas.Where(x => x.KlijentId == userId).ToListAsync(); 
            var narudzba = new Narudzba();

            await _dbContext.AddAsync(narudzba);
            await _dbContext.SaveChangesAsync();

            foreach (var stavka in korpa)
            {
                var stavkaNarudzbe = new NarudzbaStavka
                {
                    NarudzbaId = narudzba.NarudzbaId,
                    ProizvodId = stavka.ProizvodId,
                    Vidljivo=true,
                };
                await _dbContext.AddAsync(stavkaNarudzbe);
            }
            narudzba.UkupnaCijenaNarudzbe = korpa.Sum(x => x.UkupnaCijenaProizvoda);
            narudzba.ZavrsenaNarudzba = true;
            await _dbContext.SaveChangesAsync();
        }
        public override async Task<Model.Korpa> Insert(Model.KorpaInsert insert)
        {
            var korpa = _mapper.Map<Database.Korpa>(insert);
            var proizvod = await _dbContext.Proizvods.FindAsync(insert.ProizvodId);
            if (proizvod != null)
            {
                 korpa.UkupnaCijenaProizvoda = proizvod.CijenaSaPopustom != null ? proizvod.CijenaSaPopustom * insert.Kolicina : proizvod.Cijena * insert.Kolicina;
                korpa.Proizvod = proizvod;
            }
            else
            {
                throw new Exception("Proizvod nije pronađen.");
            }
            var user = _httpContextAccessor.HttpContext.User;
            var userId = user?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userId))
            {
                throw new Exception("User ID is missing from claims. ");
            }
            if (!int.TryParse(userId, out int parsedUserId))
            {
                throw new Exception($"User ID '{userId}' is invalid or not a number.");
            }

            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;
            
            if (userRole != null)
            {
                korpa.KlijentId = null;
                korpa.ZaposlenikId = null;
                korpa.AutoservisId = null;
                if(userRole!=null)
                {
                    switch (userRole)
                {
                    case "Klijent":
                        korpa.KlijentId = parsedUserId;
                        break;
                    case "Zaposlenik":
                        korpa.ZaposlenikId = parsedUserId;
                        break;
                    case "Autoservis":
                        korpa.AutoservisId = parsedUserId;
                        break;
                    default:
                        throw new Exception("Unknown user role." );
                    }
                }

                Console.WriteLine($"Assigned KlijentId: {korpa.KlijentId}");
                Console.WriteLine($"Assigned ZaposlenikId: {korpa.ZaposlenikId}");
                Console.WriteLine($"Assigned AutoservisId: {korpa.AutoservisId}");
            }
            else
            {
                throw new Exception("User role is not available.");
            }

            await _dbContext.Korpas.AddAsync(korpa);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Korpa>(korpa);
        }
        public override IQueryable<Database.Korpa> AddInclude(IQueryable<Database.Korpa> query, KorpaSearchObject? search = null)
        {
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
            var query = _dbContext.Korpas.AsQueryable();
            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;
            query = query.Include(x => x.Proizvod);
            if (userRole != null)
            {
                switch (userRole)
                {
                    case "Klijent":
                        query = query.Where(x => x.KlijentId == id);
                        query = query.Include(x => x.Klijent);
                        break;
                    case "Zaposlenik":
                        query = query.Where(x => x.ZaposlenikId == id);
                        query = query.Include(x => x.Zaposlenik);
                        break;
                    case "Autoservis":
                        query = query.Where(x => x.AutoservisId == id);
                        query = query.Include(x => x.Autoservis);
                        break;
                    default:
                        throw new Exception("Nepoznata uloga korisnika.");
                }
            }
            else
            {
                throw new Exception("Korisnička uloga nije dostupna.");
            }
            var result = await query.ToListAsync(); 
            return _mapper.Map<List<Model.Korpa>>(result);
        }
        public virtual async Task<bool> DeleteProizvodIzKorpe(int? korpaId, int? proizvodId)
        {
            var korpa = await _dbContext.Set<CarCareHub.Services.Database.Korpa>()
                                        .FirstOrDefaultAsync(k => k.KorpaId == korpaId && k.ProizvodId == proizvodId);
            if (korpa == null)
                throw new Exception("Proizvod ne postoji u korpi");
            _dbContext.Set<CarCareHub.Services.Database.Korpa>().Remove(korpa);
            await _dbContext.SaveChangesAsync();

            return true;
        }
        public virtual async Task<bool> OčistiKorpu(int? klijentId, int? zaposlenikId, int? autoservisId)
        {
            IQueryable<CarCareHub.Services.Database.Korpa> query = _dbContext.Set<CarCareHub.Services.Database.Korpa>();
            if (klijentId.HasValue)
            {
                query = query.Where(k => k.KlijentId == klijentId);
            }
            else if (zaposlenikId.HasValue)
            {
                query = query.Where(k => k.ZaposlenikId == zaposlenikId);
            }
            else if (autoservisId.HasValue)
            {
                query = query.Where(k => k.AutoservisId == autoservisId);
            }
            else
            {
                return false; 
            }
            var korpaItems = await query.ToListAsync();
            if (!korpaItems.Any())
                return false; 
            _dbContext.Set<CarCareHub.Services.Database.Korpa>().RemoveRange(korpaItems);
            await _dbContext.SaveChangesAsync();

            return true;
        }
        public async Task<bool> UpdateKolicina(int? korpaId, int? proizvodId, int novaKolicina)
        {
            var korpaStavka = await _dbContext.Korpas
                .FirstOrDefaultAsync(x => x.KorpaId == korpaId && x.ProizvodId == proizvodId);
            if (korpaStavka == null)
            {
                throw new Exception("Stavka u korpi nije pronađena.");
            }
            korpaStavka.Kolicina = novaKolicina;
            korpaStavka.UkupnaCijenaProizvoda= korpaStavka?.Proizvod?.CijenaSaPopustom != null ? korpaStavka.Proizvod.CijenaSaPopustom * novaKolicina : korpaStavka?.Proizvod?.Cijena * novaKolicina;
            await _dbContext.SaveChangesAsync();
            return true;
        }
    }
}
