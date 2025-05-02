using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class FirmaAutodijelovaService : BaseCRUDService<Model.FirmaAutodijelova, Database.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>, IFirmaAutodijelovaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }
        public override async Task BeforeInsert(CarCareHub.Services.Database.FirmaAutodijelova entity, FirmaAutodijelovaInsert insert)
        {
            entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, insert.Password);
        }
        public static string GenerateSalt()
        {
            RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
            var byteArray = new byte[16];
            provider.GetBytes(byteArray);

            return Convert.ToBase64String(byteArray);
        }
        public override IQueryable<Database.FirmaAutodijelova> AddFilter(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivFirme))
            {
                query = query.Where(x => x.NazivFirme.StartsWith(search.NazivFirme));
                query = query.Include(y => y.Grad);
            }
            return base.AddFilter(query, search);
        }
        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];
            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);
            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }
        public FirmaAutodijelovaService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override async Task<Model.FirmaAutodijelova> Insert(Model.FirmaAutodijelovaInsert insert)
        {
            // Provjera da li username već postoji
            if (await UsernameExists(insert.Username))
            {
                throw new UserException("Korisničko ime već postoji"); // Koristite UserException
            }

            return await base.Insert(insert);
        }
        public override async Task<Model.FirmaAutodijelova> Update(int id, Model.FirmaAutodijelovaUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.FirmaAutodijelova> Delete(int id)
        {
            return await base.Delete(id);
        }
        public override IQueryable<Database.FirmaAutodijelova> AddInclude(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search = null)
        {
            if (search?.IsAllncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.Uloga);
                query = query.AsQueryable();
            }
            return base.AddInclude(query, search);
        }
        public async Task<Model.FirmaAutodijelova> Login(string username, string password)
        {
            var entity = await _dbContext.FirmaAutodijelovas
                .Include(x => x.Uloga)
                .FirstOrDefaultAsync(x => x.Username.ToLower() == username.ToLower());
            if (entity == null)
            {
                return null;
            }
            var hash = GenerateHash(entity.LozinkaSalt, password);
            if (hash != entity.LozinkaHash)
            {
                return null;
            }
            return _mapper.Map<Model.FirmaAutodijelova>(entity);
        }
        public async Task AddFirmaAsync()
        {
            byte[] sample = Convert.FromBase64String("/9j/4AAQSkZJRgABAQEBLAEsAAD/4QDcRXhpZgAASUkqAAgAAAADAA4BAgCSAAAAMgAAABoBBQABAAAAxAAAABsBBQABAAAAzAAAAAAAAABDYXIgcmVwYWlyIGdlYXIgb3V0bGluZSBpY29uIGluIGZsYXQgc3R5bGUuIEVsZW1lbnRzIG9mIGNhciByZXBhaXIgaWxsdXN0cmF0aW9uIGljb24uIFNpZ25zIGFuZCBzeW1ib2xzIGNhbiBiZSB1c2VkLiBGb3Igd2ViLCBsb2dvLCBtb2JpbGUgYXBwLCBVSSwBAAABAAAALAEAAAEAAAD/4QYMaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIj4KCTxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CgkJPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczpJcHRjNHhtcENvcmU9Imh0dHA6Ly9pcHRjLm9yZy9zdGQvSXB0YzR4bXBDb3JlLzEuMC94bWxucy8iICAgeG1sbnM6R2V0dHlJbWFnZXNHSUZUPSJodHRwOi8veG1wLmdldHR5aW1hZ2VzLmNvbS9naWZ0LzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGx1cz0iaHR0cDovL25zLnVzZXBsdXMub3JnL2xkZi94bXAvMS4wLyIgIHhtbG5zOmlwdGNFeHQ9Imh0dHA6Ly9pcHRjLm9yZy9zdGQvSXB0YzR4bXBFeHQvMjAwOC0wMi0yOS8iIHhtbG5zOnhtcFJpZ2h0cz0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3JpZ2h0cy8iIHBob3Rvc2hvcDpDcmVkaXQ9IkdldHR5IEltYWdlcyIgR2V0dHlJbWFnZXNHSUZUOkFzc2V0SUQ9IjExOTA2Nzk2MzUiIHhtcFJpZ2h0czpXZWJTdGF0ZW1lbnQ9Imh0dHBzOi8vd3d3LmlzdG9ja3Bob3RvLmNvbS9sZWdhbC9saWNlbnNlLWFncmVlbWVudD91dG1fbWVkaXVtPW9yZ2FuaWMmYW1wO3V0bV9zb3VyY2U9Z29vZ2xlJmFtcDt1dG1fY2FtcGFpZ249aXB0Y3VybCIgcGx1czpEYXRhTWluaW5nPSJodHRwOi8vbnMudXNlcGx1cy5vcmcvbGRmL3ZvY2FiL0RNSS1QUk9ISUJJVEVELUVYQ0VQVFNFQVJDSEVOR0lORUlOREVYSU5HIiA+CjxkYzpjcmVhdG9yPjxyZGY6U2VxPjxyZGY6bGk+VmFsZW50aW4gQW1vc2Vua292PC9yZGY6bGk+PC9yZGY6U2VxPjwvZGM6Y3JlYXRvcj48ZGM6ZGVzY3JpcHRpb24+PHJkZjpBbHQ+PHJkZjpsaSB4bWw6bGFuZz0ieC1kZWZhdWx0Ij5DYXIgcmVwYWlyIGdlYXIgb3V0bGluZSBpY29uIGluIGZsYXQgc3R5bGUuIEVsZW1lbnRzIG9mIGNhciByZXBhaXIgaWxsdXN0cmF0aW9uIGljb24uIFNpZ25zIGFuZCBzeW1ib2xzIGNhbiBiZSB1c2VkLiBGb3Igd2ViLCBsb2dvLCBtb2JpbGUgYXBwLCBVSTwvcmRmOmxpPjwvcmRmOkFsdD48L2RjOmRlc2NyaXB0aW9uPgo8cGx1czpMaWNlbnNvcj48cmRmOlNlcT48cmRmOmxpIHJkZjpwYXJzZVR5cGU9J1Jlc291cmNlJz48cGx1czpMaWNlbnNvclVSTD5odHRwczovL3d3dy5pc3RvY2twaG90by5jb20vcGhvdG8vbGljZW5zZS1nbTExOTA2Nzk2MzUtP3V0bV9tZWRpdW09b3JnYW5pYyZhbXA7dXRtX3NvdXJjZT1nb29nbGUmYW1wO3V0bV9jYW1wYWlnbj1pcHRjdXJsPC9wbHVzOkxpY2Vuc29yVVJMPjwvcmRmOmxpPjwvcmRmOlNlcT48L3BsdXM6TGljZW5zb3I+CgkJPC9yZGY6RGVzY3JpcHRpb24+Cgk8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSJ3Ij8+Cv/tANxQaG90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");
            if (!_dbContext.FirmaAutodijelovas.Any())
            {
                var firmaAutodijelovaInsert =
            new FirmaAutodijelovaInsert
            {
                NazivFirme = "Auto Parts Sarajevo",
                Adresa = "Ulica bb, Sarajevo",
                GradId = 1, 
                JIB = "123456789",
                MBS = "987654321",
                UlogaId = 3, 
                Telefon = "38733123456",
                Email = "kontakt@autoparts.ba",
                Username = "firma",
                Password = "firma",
                PasswordAgain = "firma",
                Vidljivo = true,
                SlikaProfila = sample 
            };
                var firmaAutodijelovaEntities = _mapper.Map<Database.FirmaAutodijelova>(firmaAutodijelovaInsert);
                BeforeInsert(firmaAutodijelovaEntities, firmaAutodijelovaInsert);
                await _dbContext.FirmaAutodijelovas.AddRangeAsync(firmaAutodijelovaEntities);
                await _dbContext.SaveChangesAsync();
            }
        }
        public int? GetIdByUsernameAndPassword(string username, string password)
        {
            var user = _dbContext.FirmaAutodijelovas
                .SingleOrDefault(x => x.Password == password && x.Username == username);
            return user?.FirmaAutodijelovaID;
        }


        public bool? GetVidljivoByUsernameAndPassword(string username, string password)
        {
            var user = _dbContext.FirmaAutodijelovas
                .SingleOrDefault(x => x.Password == password && x.Username == username);
            return user?.Vidljivo;
        }
        public async Task<string> GeneratePaidOrdersReportAsync()
        {
            var korpe = await _dbContext.Korpas
                .Include(k => k.NarudzbaStavkas)
                .ThenInclude(ns => ns.Proizvod) 
                .Where(k => k.AutoservisId.HasValue)
                .ToListAsync();
            var placeneKorpe = korpe
                .Where(k => _dbContext.PlacanjeAutoservisDijelovis
                    .Any(p => p.AutoservisId == k.AutoservisId)) 
                .ToList();
            var ukupnaZarada = placeneKorpe.Sum(k => k.NarudzbaStavkas.Sum(ns => ns.Proizvod?.Cijena * ns.Kolicina ?? 0));
            var najboljiAutoservis = placeneKorpe
                .GroupBy(k => k.AutoservisId)
                .OrderByDescending(g => g.Sum(k => k.NarudzbaStavkas.Sum(ns => ns.Proizvod?.Cijena * ns.Kolicina ?? 0)))
                .FirstOrDefault();
            var autoservisInfo = najboljiAutoservis != null
                ? new
                {
                    Autoservis = najboljiAutoservis.First().Autoservis.Naziv, 
                    UkupnoPotroseno = najboljiAutoservis.Sum(k => k.NarudzbaStavkas.Sum(ns => ns.Proizvod?.Cijena * ns.Kolicina ?? 0))
                }
                : null;
            
            // Generiši izvještaj u CSV formatu
            var csv = new StringBuilder();
            csv.AppendLine("Izvještaj o Narudžbama");
            csv.AppendLine($"Ukupna Zarada: {ukupnaZarada}");
            csv.AppendLine($"Najbolji Autoservis: {autoservisInfo?.Autoservis ?? "Nema podataka"}");
            csv.AppendLine($"Ukupno Potrošeno od Najboljeg Autoservisa: {autoservisInfo?.UkupnoPotroseno ?? 0}");
            csv.AppendLine();
            csv.AppendLine("Korpe:");
            csv.AppendLine("Korpa ID, Autoservis, Proizvod, Cijena, Količina, Ukupno, Iznos Plačanja");
            
            foreach (var korpa in placeneKorpe)
            {
                var iznosPlacanja = _dbContext.PlacanjeAutoservisDijelovis
                    .Where(p => p.AutoservisId == korpa.AutoservisId)
                    .Sum(p => p.Iznos);

                foreach (var stavka in korpa.NarudzbaStavkas)
                {
                    csv.AppendLine($"{korpa.KorpaId}, {korpa.Autoservis?.Naziv}, {stavka.Proizvod?.Naziv}, {stavka.Proizvod?.Cijena}, {stavka.Kolicina}, {stavka.Proizvod?.Cijena * stavka.Kolicina}, {iznosPlacanja}");
                }
            }
            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "Placene_Korpe_Report.csv");
            await File.WriteAllTextAsync(filePath, csv.ToString());
            return filePath; 
        }
        public override async Task<List<Model.FirmaAutodijelova>> GetByID_(int id)
        {
            var temp = _dbContext.FirmaAutodijelovas.Where(x => x.FirmaAutodijelovaID == id).ToList().AsQueryable();
            return _mapper.Map<List<Model.FirmaAutodijelova>>(temp);
        }



        public async Task<bool> UsernameExists(string username)
        {
            return await _dbContext.FirmaAutodijelovas
                .AnyAsync(x => x.Username.ToLower() == username.ToLower());
        }
    }
}

