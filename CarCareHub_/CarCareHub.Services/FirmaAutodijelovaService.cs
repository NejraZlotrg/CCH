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



       

            public async Task<string> GeneratePaidOrdersReportAsync()
            {
                // Dobavi sve korpe povezane s narudžbama
                var korpe = await _dbContext.Korpas
                    .Include(k => k.NarudzbaStavkas) // Povezujemo stavke narudžbi
                    .ThenInclude(ns => ns.Proizvod) // Povezujemo proizvode za stavke
                    .Where(k => k.AutoservisId.HasValue) // Filtriramo samo korpe sa validnim AutoservisId
                    .ToListAsync();

                // Filtriramo plaćene korpe, povezivanjem sa placanjem
                var placeneKorpe = korpe
                    .Where(k => _dbContext.PlacanjeAutoservisDijelovis
                        .Any(p => p.AutoservisId == k.AutoservisId)) // Povezivanje sa placanjem kroz AutoservisId
                    .ToList();

                // Izračunaj ukupnu zaradu
                var ukupnaZarada = placeneKorpe.Sum(k => k.NarudzbaStavkas.Sum(ns => ns.Proizvod?.Cijena * ns.Kolicina ?? 0));

                // Nađi najbolji autoservis (onaj koji je potrošio najviše)
                var najboljiAutoservis = placeneKorpe
                    .GroupBy(k => k.AutoservisId)
                    .OrderByDescending(g => g.Sum(k => k.NarudzbaStavkas.Sum(ns => ns.Proizvod?.Cijena * ns.Kolicina ?? 0)))
                    .FirstOrDefault();

                var autoservisInfo = najboljiAutoservis != null
                    ? new
                    {
                        Autoservis = najboljiAutoservis.First().Autoservis.Naziv, // Pretpostavljamo da Autoservis ima Naziv
                        UkupnoPotroseno = najboljiAutoservis.Sum(k => k.NarudzbaStavkas.Sum(ns => ns.Proizvod?.Cijena * ns.Kolicina ?? 0))
                    }
                    : null;

                // Generiši izvještaj u CSV formatu
                var csv = new StringBuilder();

                // Dodaj header
                csv.AppendLine("Izvještaj o Narudžbama");
                csv.AppendLine($"Ukupna Zarada: {ukupnaZarada}");
                csv.AppendLine($"Najbolji Autoservis: {autoservisInfo?.Autoservis ?? "Nema podataka"}");
                csv.AppendLine($"Ukupno Potrošeno od Najboljeg Autoservisa: {autoservisInfo?.UkupnoPotroseno ?? 0}");
                csv.AppendLine();
                csv.AppendLine("Korpe:");
                csv.AppendLine("Korpa ID, Autoservis, Proizvod, Cijena, Količina, Ukupno, Iznos Plačanja");

                // Dodaj podatke o korpama
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

                // Spremi izvještaj u datoteku
                var filePath = Path.Combine(Directory.GetCurrentDirectory(), "Placene_Korpe_Report.csv");

                await File.WriteAllTextAsync(filePath, csv.ToString());

                return filePath; // Putanja do spremljenog izvještaja
            }

        public override async Task<List<Model.FirmaAutodijelova>> GetByID_(int id)
        {
            var temp = _dbContext.FirmaAutodijelovas.Where(x => x.FirmaAutodijelovaID == id).ToList().AsQueryable();

           


            return _mapper.Map<List<Model.FirmaAutodijelova>>(temp);
        }
    }

    }





       
       
    

