using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Services.Database;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class KlijentService : BaseCRUDService<Model.Klijent, Database.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>, IKlijentService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }
        public KlijentService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override async Task BeforeInsert(CarCareHub.Services.Database.Klijent entity, KlijentInsert insert)
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
        public override IQueryable<Database.Klijent> AddFilter(IQueryable<Database.Klijent> query, KlijentSearchObject? search = null)
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
        public override async Task<Model.Klijent> Insert(Model.KlijentInsert insert)
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
            return await _dbContext.Klijents
                .AnyAsync(x => x.Username.ToLower() == username.ToLower());
        }
        public bool? GetVidljivoByUsernameAndPassword(string username, string password)
        {
            var user = _dbContext.Klijents
                .SingleOrDefault(x => x.Password == password && x.Username == username);
            return user?.Vidljivo;
        }
        public override IQueryable<Database.Klijent> AddInclude(IQueryable<Database.Klijent> query, KlijentSearchObject? search = null)
        {
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.ChatAutoservisKlijent);
                query = query.Include(z => z.ChatKlijentZaposlenik);
                query = query.Include(z => z.uloga);
            }
            return base.AddInclude(query, search);
        }
        public async Task<Model.Klijent> Login(string username, string password)
        {
            var entity = await _dbContext.Klijents.FirstOrDefaultAsync(x => x.Username == username);
            if (entity == null)
            {
                return null;
            }
            var hash = GenerateHash(entity.LozinkaSalt, password);
            if (hash != entity.LozinkaHash)
            {
                return null;
            }
            return _mapper.Map<Model.Klijent>(entity);
        }
        public int? GetIdByUsernameAndPassword(string username, string password)
        {
            var user = _dbContext.Klijents
                .SingleOrDefault(x => x.Password == password && x.Username == username);

            return user?.KlijentId;
        }
        public async Task AddKlijentAsync()
        {
            if (!_dbContext.Klijents.Any())
            {
                var klijentInsert1 =
            new KlijentInsert
            {
                Ime = "Marko",
                Prezime = "Markovic",
                Email = "marko@example.com",
                Username = "klijent",
                Password = "klijent",
                PasswordAgain = "klijent",
                Spol = "Muško",
                BrojTelefona = "38761123456",
                GradId = 1,
                UlogaId = 4,
                Vidljivo = true, 
                Adresa= "D.Večeriska, Vitez"
            };
                var klijentInsert2 =
           new KlijentInsert
           {
               Ime = "Admin",
               Prezime = "Admin",
               Email = "admin@example.com",
               Username = "Admin",
               Password = "Admin",
               PasswordAgain = "Admin",
               Spol = "Muško",
               BrojTelefona = "38761123456",
               GradId = 1,
               UlogaId = 5,
               Vidljivo = true, 
               Adresa="Livač bb Mostar"
           };
                var klijentEntities = _mapper.Map<Database.Klijent>(klijentInsert1);
                BeforeInsert(klijentEntities, klijentInsert1);

                var klijentEntities2 = _mapper.Map<Database.Klijent>(klijentInsert2);
                BeforeInsert(klijentEntities2, klijentInsert2);

                await _dbContext.Klijents.AddRangeAsync(klijentEntities);
                await _dbContext.SaveChangesAsync();
                await _dbContext.Klijents.AddRangeAsync(klijentEntities2);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}