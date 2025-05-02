using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class ZaposlenikService : BaseCRUDService<Model.Zaposlenik, Database.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, IZaposlenikService
    {
        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }
        public override async Task BeforeInsert(CarCareHub.Services.Database.Zaposlenik entity, ZaposlenikInsert insert)
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

        public override async Task<Model.Zaposlenik> Insert(Model.ZaposlenikInsert insert)
        {
            // Provjera da li username već postoji
            if (await UsernameExists(insert.Username))
            {
                throw new UserException("Korisničko ime već postoji"); // Koristite UserException
            }

            return await base.Insert(insert);
        }


        public async Task<bool> UsernameExists(string username)
        {
            return await _dbContext.Zaposleniks
                .AnyAsync(x => x.Username.ToLower() == username.ToLower());
        }


        public override IQueryable<Database.Zaposlenik> AddFilter(IQueryable<Database.Zaposlenik> query, ZaposlenikSearchObject? search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.Ime))
            {
                query = query.Where(x => x.Ime.StartsWith(search.Ime));
            }
            if (!string.IsNullOrWhiteSpace(search?.Prezime))
            {
                query = query.Where(x => x.Prezime.StartsWith(search.Prezime));
            }
            return base.AddFilter(query, search);
        }
        public override IQueryable<Database.Zaposlenik> AddInclude(IQueryable<Database.Zaposlenik> query, ZaposlenikSearchObject? search = null)
        {
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Uloga);
                query = query.Include(z => z.FirmaAutodijelova);
                query = query.Include(z => z.Autoservis);
                query = query.Include(z => z.Grad);
            }
            return base.AddInclude(query, search);
        }
        public async Task<CarCareHub.Model.Zaposlenik> GetByGrad(int id)
        {
            var temp = await _dbContext.Set<CarCareHub.Services.Database.Grad>()
                                        .Include(g => g.Zaposleniks) 
                                        .FirstOrDefaultAsync(g => g.GradId == id);
            if (temp == null || temp.Zaposleniks == null || !temp.Zaposleniks.Any())
            {
                return null; 
            }
            var mappedZaposlenici = temp.Zaposleniks.Select(z => _mapper.Map<CarCareHub.Model.Zaposlenik>(z)).ToList();
            return mappedZaposlenici.FirstOrDefault();
        }
        public async Task<Model.Zaposlenik> Login(string username, string password)
        {
            var entity = await _dbContext.Zaposleniks.Include(x => x.Uloga).FirstOrDefaultAsync(x => x.Username == username);
            if (entity == null)
            {
                return null;
            }
            var hash = GenerateHash(entity.LozinkaSalt, password);
            if (hash != entity.LozinkaHash)
            {
                return null;
            }
            return _mapper.Map<Model.Zaposlenik>(entity);
        }
        public override async Task<List<Model.Zaposlenik>> GetByID_(int id)
        {
            var temp = _dbContext.Zaposleniks.Where(x => x.autoservisId == id).ToList().AsQueryable();
            temp = temp.Include(x => x.Autoservis);
            return _mapper.Map<List<Model.Zaposlenik>>(temp);
        }
        public int? GetIdByUsernameAndPassword(string username, string password)
        {
            var user = _dbContext.Zaposleniks
                .SingleOrDefault(x => x.Password == password && x.Username == username);
            return user?.ZaposlenikId;
        }
        public async Task AddZaposlenikAsync()
        {
            if (!_dbContext.Zaposleniks.Any(z => z.UlogaId == 1))
            {
                var noviZaposlenik = new ZaposlenikInsert
                {
                    Ime = "Zaposlenik",
                    Prezime = "Test",
                    DatumRodjenja = new DateTime(1990, 5, 15),
                    mb = "637454647484", 
                    BrojTelefona = "060000000", 
                    GradId = 1, 
                    Email = "zaposlenik@test.com", 
                    Username = "zaposlenik", 
                    Password = "zaposlenik", 
                    PasswordAgain = "zaposlenik", 
                    UlogaId = 1, 
                    AutoservisId = 1, 
                    FirmaAutodijelovaId = 1, 
                    Vidljivo = true,
                    Adresa = "Donje Putićevo bb"
                };
                var zapEntity = _mapper.Map<Database.Zaposlenik>(noviZaposlenik);
                BeforeInsert(zapEntity, noviZaposlenik);
                await _dbContext.Zaposleniks.AddAsync(zapEntity);
                await _dbContext.SaveChangesAsync();
            }
        }
        public override async Task<Model.Zaposlenik> Update(int id, Model.ZaposlenikUpdate update)
        {
            var entity = await _dbContext.Zaposleniks.FindAsync(id);

            if (entity == null)
            {
                throw new ArgumentException("Zaposlenik nije pronađen.");
            }

            if (update.Ime != null)
                entity.Ime = update.Ime;

            if (update.Prezime != null)
                entity.Prezime = update.Prezime;

            if (update.DatumRodjenja.HasValue)
                entity.DatumRodjenja = update.DatumRodjenja.Value;

            if (update.BrojTelefona != null)
                entity.BrojTelefona = update.BrojTelefona;

            if (update.Email != null)
                entity.Email = update.Email;

            if (update.Adresa != null)
                entity.Adresa = update.Adresa;

            if (update.Username != null)
                entity.Username = update.Username;

            if (update.Password != null)
                entity.Password = update.Password; 

            if (update.UlogaId.HasValue)
                entity.UlogaId = update.UlogaId.Value;

            entity.autoservisId = update.AutoservisId.HasValue ? update.AutoservisId.Value : null;

            entity.FirmaAutodijelovaId = update.FirmaAutodijelovaId.HasValue ? update.FirmaAutodijelovaId.Value : null;

            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Zaposlenik>(entity);
        }
    }
}
