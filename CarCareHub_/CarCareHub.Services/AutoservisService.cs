using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{


    public class AutoservisService : BaseCRUDService<Model.Autoservis, Database.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>, IAutoservisService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }
        public override async Task BeforeInsert(CarCareHub.Services.Database.Autoservis entity, AutoservisInsert insert)
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
        public AutoservisService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.Autoservis> Insert(Model.AutoservisInsert insert)
        {
            //// Check if a record with the same username already exists
            //var existingUsername =  _dbContext.Autoservis
            //    .FirstOrDefaultAsync(a => a.Username == insert.Username);

            //if (existingUsername != null)
            //{
            //    throw new Exception("Username already exists.");
            //}

            //// Check if a record with the same email already exists
            //var existingEmail =  _dbContext.Autoservis
            //    .FirstOrDefaultAsync(a => a.Email == insert.Email);

            //if (existingEmail != null)
            //{
            //    throw new Exception("Email already exists.");
            //}

            //// If no duplicates found, proceed to insert the new record


            return base.Insert(insert);

        }



        public override async Task<Model.Autoservis> Update(int id, Model.AutoservisUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Autoservis> Delete(int id)
        {
            return await base.Delete(id);
        }


        public override IQueryable<Database.Autoservis> AddInclude(IQueryable<Database.Autoservis> query, AutoservisSearchObject? search = null)
        {
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(entity => entity.Grad);
                query = query.Include(entity => entity.Grad.Drzava);
                query = query.Include(entity => entity.Uloga);
                query = query.Include(entity => entity.Usluges);
                query = query.Include(entity => entity.Zaposleniks);
                query = query.Include(entity => entity.Vozilo);

            }
            return base.AddInclude(query, search);
        }
        public override IQueryable<Database.Autoservis> AddFilter(IQueryable<Database.Autoservis> query, AutoservisSearchObject search = null)
        {
           

            if (!string.IsNullOrWhiteSpace(search?.NazivGrada))
            {
                query = query.Where(x => x.Grad.NazivGrada.StartsWith(search.NazivGrada));

            }

            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                query = query.Where(x => x.Naziv.StartsWith(search.Naziv));

            }

            return base.AddFilter(query, search);

        }

        public async Task<Model.Autoservis> Login(string username, string password)
        {
            var entity = await _dbContext.Autoservis.Include(x => x.Uloga).FirstOrDefaultAsync(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.LozinkaSalt, password);

            if (hash != entity.LozinkaHash)
            {
                return null;
            }

            return _mapper.Map<Model.Autoservis>(entity);
        }

        public override async Task<List<Model.Autoservis>> GetByID_(int id)
        {
            var temp = _dbContext.Autoservis.Where(x => x.AutoservisId == id).ToList().AsQueryable();

            temp = temp.Include(x => x.BPAutodijeloviAutoservis);


            return _mapper.Map<List<Model.Autoservis>>(temp);
        }
        public int? GetIdByUsernameAndPassword(string username, string password)
        {
            // Koristi SingleOrDefault ako očekuješ da korisničko ime bude jedinstveno.
            var user = _dbContext.Autoservis
                .SingleOrDefault(x => x.Password == password && x.Username == username);

            // Ako korisnik nije pronađen, vraća null.
            return user?.AutoservisId;
        }


        public async Task AddAutoserviceAsync()
        {
            // Provjerite da li autoservisi već postoje u bazi
            if (!_dbContext.Autoservis.Any())
            {
                // Kreirajte listu autoservisa za unos
                var autoservisInsert =
            new AutoservisInsert
            {
                Naziv = "Auto servis Sarajevo",
                Adresa = "Ulica bb, Sarajevo",
                GradId = 1, // Assuming GradId = 1 corresponds to Sarajevo
                VlasnikFirme = "John Doe",
                Telefon = "8733 123 456",
                Email = "kontakt@autoservis.ba",
                Username = "autoservis",
                Password = "autoservis",
                PasswordAgain = "autoservis",
                Jib = "123456789",
                Mbs = "987654321",
                SlikaProfila = null, // Add profile image byte array if necessary
                SlikaThumb = null, // Add thumbnail image byte array if necessary
                UlogaId = 2, // Assuming UlogaId corresponds to a specific role in the database
                VoziloId = 1, // Assuming VoziloId corresponds to a specific vehicle
                 Vidljivo=true,
            };

                // Mapirajte svaki Insert model u Database.Autoservis entitet
                var autoservisEntities = _mapper.Map<Database.Autoservis>(autoservisInsert);
                BeforeInsert(autoservisEntities, autoservisInsert);
                // Dodajte autoservise u bazu podataka
                await _dbContext.Autoservis.AddRangeAsync(autoservisEntities);
                await _dbContext.SaveChangesAsync();
            }
        }


    }
}
