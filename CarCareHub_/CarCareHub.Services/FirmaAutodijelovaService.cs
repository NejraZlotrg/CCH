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



        public FirmaAutodijelovaService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        
    public override Task<Model.FirmaAutodijelova> Insert(Model.FirmaAutodijelovaInsert insert)

    {
           //var existingUsername = _dbContext.FirmaAutodijelovas
           //        .FirstOrDefaultAsync(a => a.Username == insert.Username);

           // if (existingUsername != null)
           // {
           //     throw new Exception("Username already exists.");
           // }

           // // Check if a record with the same email already exists
           // var existingEmail = _dbContext.FirmaAutodijelovas
           //     .FirstOrDefaultAsync(a => a.Email == insert.Email);

           // if (existingEmail != null)
           // {
           //     throw new Exception("Email already exists.");
           // }

           // // If no duplicates found, proceed to insert the new record


            return base.Insert(insert);

        }


    

        public override async Task<Model.FirmaAutodijelova> Update(int id, Model.FirmaAutodijelovaUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.FirmaAutodijelova> Delete(int id)
        {
            return await base.Delete(id);
        }

        //public override async Task<Model.FirmaAutodijelova> GetByID(int id)
        //{
        //    var temp = await _dbContext.FirmaAutodijelovas
        //        .Include(f => f.BPAutodijeloviAutoservis)
        //            .ThenInclude(bp => bp.Autoservis.Naziv)
        //        .FirstOrDefaultAsync(f => f.FirmaAutodijelovaID == id);

        //    // Ovdje ograničavamo broj podataka u kolekciji na primjer 10
        //    if (temp.BPAutodijeloviAutoservis != null)
        //    {
        //        temp.BPAutodijeloviAutoservis = temp.BPAutodijeloviAutoservis.Take(10).ToList();
        //    }

        //    return _mapper.Map<Model.FirmaAutodijelova>(temp);
        //}



        public override IQueryable<Database.FirmaAutodijelova> AddInclude(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.Uloga);
               
                query=query.AsQueryable();

            }
            return base.AddInclude(query, search);


        }


        public async Task<Model.FirmaAutodijelova> Login(string username, string password)
        {
            var entity = await _dbContext.FirmaAutodijelovas.Include(x => x.Uloga).FirstOrDefaultAsync(x => x.Username == username);

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

        //protected override IQueryable<Database.FirmaAutodijelova> GetCollection(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search)
        //{
        //    // Ako želite uključiti kolekciju 'BPAutodijeloviAutoservis' unutar 'FirmaAutodijelova'

        //    query = query.Include(firma => firma.BPAutodijeloviAutoservis).Where(k=>k.FirmaAutodijelovaID==2);

        //    return base.GetCollection(query, search);
        //}
        //public static string GenerateSalt()
        //{
        //    RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
        //    var byteArray = new byte[16];
        //   provider.GetBytes(byteArray);


        //    return Convert.ToBase64String(byteArray);
        //}
        //public static string GenerateHash(string salt, string password)
        //{
        //    byte[] src = Convert.FromBase64String(salt);
        //    byte[] bytes = Encoding.Unicode.GetBytes(password);
        //    byte[] dst = new byte[src.Length + bytes.Length];

        //    System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        //    System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        //    HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        //    byte[] inArray = algorithm.ComputeHash(dst);
        //    return Convert.ToBase64String(inArray);
        //}
        public async Task AddFirmaAsync()
        {
            // Provjerite da li firme autodijelova već postoje u bazi
            if (!_dbContext.FirmaAutodijelovas.Any())
            {
                // Kreirajte listu firmi autodijelova za unos
                var firmaAutodijelovaInsert = 
            new FirmaAutodijelovaInsert
            {
                NazivFirme = "Auto Parts Sarajevo",
                Adresa = "Ulica bb, Sarajevo",
                GradId = 1, // Assuming GradId = 1 corresponds to Sarajevo
                JIB = "123456789",
                MBS = "987654321",
                UlogaId = 3, // Assuming UlogaId corresponds to a specific role in the database
                Telefon = "38733123456",
                Email = "kontakt@autoparts.ba",
                Username = "firma",
                Password = "firma",
                PasswordAgain = "firma",
                SlikaProfila = null // Add profile image byte array if necessary
            };

                // Mapirajte svaki Insert model u Database.FirmaAutodijelova entitet
                // Mapirajte svaki Insert model u Database.Autoservis entitet
                var firmaAutodijelovaEntities = _mapper.Map<Database.FirmaAutodijelova>(firmaAutodijelovaInsert);
                BeforeInsert(firmaAutodijelovaEntities, firmaAutodijelovaInsert);
                // Dodajte firme autodijelova u bazu podataka
                await _dbContext.FirmaAutodijelovas.AddRangeAsync(firmaAutodijelovaEntities);
                await _dbContext.SaveChangesAsync();
            }
        }

        public int? GetIdByUsernameAndPassword(string username, string password)
        {
            // Koristi SingleOrDefault ako očekuješ da korisničko ime bude jedinstveno.
            var user = _dbContext.FirmaAutodijelovas
                .SingleOrDefault(x => x.Password == password && x.Username == username);

            // Ako korisnik nije pronađen, vraća null.
            return user?.FirmaAutodijelovaID;
        }
    }
}


       
       
    

