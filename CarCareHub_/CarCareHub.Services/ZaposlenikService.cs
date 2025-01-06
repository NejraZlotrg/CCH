using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ZaposlenikService : BaseCRUDService<Model.Zaposlenik, Database.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>, IZaposlenikService
    {
        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }
     


        public override async Task BeforeInsert(CarCareHub.Services.Database.Zaposlenik entity, ZaposlenikInsert insert)
        {

        entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, insert.Password);

        }

        public override Task<Model.Zaposlenik> Insert(Model.ZaposlenikInsert insert)

        {
            var existingUsername = _dbContext.Zaposleniks
                    .FirstOrDefaultAsync(a => a.Username == insert.Username);

            if (existingUsername != null)
            {
                throw new Exception("Username already exists.");
            }

            // Check if a record with the same email already exists
            var existingEmail = _dbContext.Zaposleniks
                .FirstOrDefaultAsync(a => a.Email == insert.Email);

            if (existingEmail != null)
            {
                throw new Exception("Email already exists.");
            }

            // If no duplicates found, proceed to insert the new record


            return base.Insert(insert);

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



        public override IQueryable<Database.Zaposlenik> AddInclude(IQueryable<Database.Zaposlenik> query, ZaposlenikSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
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
                                        .Include(g => g.Zaposleniks) // Uključujemo Zaposlenike koji pripadaju tom gradu
                                        .FirstOrDefaultAsync(g => g.GradId == id);

            if (temp == null || temp.Zaposleniks == null || !temp.Zaposleniks.Any())
            {
                return null; // ili neki drugi odgovor koji je prikladan za vaš slučaj
            }

            // Mapiramo svakog zaposlenika pojedinačno
            var mappedZaposlenici = temp.Zaposleniks.Select(z => _mapper.Map<CarCareHub.Model.Zaposlenik>(z)).ToList();

            // Ako želite vratiti samo jednog zaposlenika, možete vratiti prvi ili specifičan
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
            // Koristi SingleOrDefault ako očekuješ da korisničko ime bude jedinstveno.
            var user = _dbContext.Zaposleniks
                .SingleOrDefault(x => x.Password == password && x.Username == username);

            // Ako korisnik nije pronađen, vraća null.
            return user?.ZaposlenikId;
        }

        public async Task AddZaposlenikAsync()
        {
            // Provjerite da li postoji zaposlenik s ulogom "Zaposlenik"
            if (!_dbContext.Zaposleniks.Any(z => z.UlogaId == 1)) // 1 pretpostavlja ID za ulogu "Zaposlenik"
            {
                var noviZaposlenik = new ZaposlenikInsert
                {
                    Ime = "Zaposlenik", // Ime zaposlenika
                    Prezime = "Test", // Prezime zaposlenika
                    DatumRodjenja = new DateTime(1990, 5, 15), // Datum rođenja
                    MaticniBroj = 56789, // Matični broj zaposlenika
                    BrojTelefona = 000000000, // Broj telefona
                    GradId = 1, // ID grada, pretpostavlja se da grad sa ID 1 postoji
                    Email = "zaposlenik@test.com", // Email adresa zaposlenika
                    Username = "zaposlenik", // Korisničko ime
                    Password = "zaposlenik", // Lozinka
                    PasswordAgain = "zaposlenik", // Ponovljena lozinka
                    UlogaId = 1, // Pretpostavlja se da je ID za "Zaposlenik" 1
                    AutoservisId = 1, // Nijedna veza s autoservisom
                    FirmaAutodijelovaId = 1 // Nijedna veza s firmom autodijelova
                };

                // Mapiraj noviZaposlenik u entitet Zaposlenik za bazu podataka
         
                var zapEntity = _mapper.Map<Database.Zaposlenik>(noviZaposlenik);
                BeforeInsert(zapEntity, noviZaposlenik);
                // Dodajte zaposlenika u bazu podataka
                await _dbContext.Zaposleniks.AddAsync(zapEntity);
                await _dbContext.SaveChangesAsync();
            }
        }



    }


}
