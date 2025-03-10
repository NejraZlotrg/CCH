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
using System.Security.Claims;

namespace CarCareHub.Services
{


    public class NarudzbaService : BaseCRUDService<Model.Narudzba, Database.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>, INarudzbaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }
        private readonly IHttpContextAccessor _httpContextAccessor;


        public NarudzbaService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task<Model.Narudzba> Insert(Model.NarudzbaInsert insert)
        {
            var korpe = await _dbContext.Korpas.Where(x => (!insert.KlijentId.HasValue || x.KlijentId == insert.KlijentId) &&
                                                            (!insert.AutoservisId.HasValue || x.AutoservisId == insert.AutoservisId) &&
                                                            (!insert.ZaposlenikId.HasValue || x.ZaposlenikId == insert.ZaposlenikId)) .ToListAsync();

            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            var narudzba = new CarCareHub.Services.Database.Narudzba();
            narudzba.DatumNarudzbe = DateTime.Now;
            narudzba.DatumIsporuke = DateTime.Now.AddDays(2);
            narudzba.Vidljivo = true;
            narudzba.UkupnaCijenaNarudzbe = 0;
            if (insert.KlijentId.HasValue && userRole=="Klijent")
            {
                narudzba.KlijentId = insert.KlijentId.Value;
                narudzba.ZaposlenikId = null;
                narudzba.AutoservisId = null;
            }
            else if (insert.ZaposlenikId.HasValue && userRole == "Zaposlenik")
            {
                narudzba.ZaposlenikId = insert.ZaposlenikId.Value;
                narudzba.KlijentId = null;
                narudzba.AutoservisId = null;
            }
            else if (insert.AutoservisId.HasValue && userRole == "Autoservis")
            {
                narudzba.AutoservisId = insert.AutoservisId.Value;
                narudzba.KlijentId = null;
                narudzba.ZaposlenikId = null;
            }


            await _dbContext.AddAsync(narudzba);


            await _dbContext.SaveChangesAsync();
            decimal ukupnaCijena = 0;

            foreach (var item in korpe)
            {
                var proizvod = await _dbContext.Proizvods.FindAsync(item.ProizvodId);
                if (proizvod != null)
                {
                    decimal cijenaProizvoda = proizvod.Cijena ?? 0;  // Ako je null, postavi na 0
                    int kolicina = item.Kolicina ?? 1;  // Ako je null, podrazumijevana količina je 1
                    decimal ukupnaStavka = cijenaProizvoda * kolicina;

                    ukupnaCijena += ukupnaStavka; // Dodaj u ukupnu cijenu

                    var stavkaNarudzbe = new CarCareHub.Services.Database.NarudzbaStavka
                    {
                        ProizvodId = item.ProizvodId,
                        NarudzbaId = narudzba.NarudzbaId,
                        Kolicina = kolicina,
                      
                    };

                    narudzba.NarudzbaStavkas.Add(stavkaNarudzbe);
                }
            }
            // Datum kada je narudžba kreirana (univerzalno vreme)
            // Datum kada je narudžba kreirana (univerzalno vreme)
            insert.DatumNarudzbe = DateTime.UtcNow;  // Čuva se kao DateTime, UTC vremenska zona

            // Datum kada je predviđena isporuka (lokalno vreme sa predviđenim rokom isporuke za 7 dana)
            insert.DatumIsporuke = DateTime.Now.AddDays(7);  // Čuva se kao DateTime, lokalno vreme

                // Ako treba da pošaljete ili prikažete podatke u specifičnom formatu, koristite:
                //string? datumNarudzbeStr = insert.DatumNarudzbe.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");
                //string datumIsporukeStr = insert.DatumIsporuke.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");


                narudzba.UkupnaCijenaNarudzbe = ukupnaCijena;

                _mapper.Map<Database.Narudzba>(insert);

            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Narudzba>(narudzba);
            }
        

        public override async Task<Model.Narudzba> Update(int id, Model.NarudzbaUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Narudzba> Delete(int id)
        {
            return await base.Delete(id);
        }


        public async Task<Model.Narudzba> PotvrdiNarudzbu(int narudzbaId)
        {
            // Pronalaženje narudžbe u bazi
            var narudzba = await _dbContext.Narudzbas.FindAsync(narudzbaId);
            if (narudzba == null)
                throw new Exception("Narudžba nije pronađena.");

            // Postavljanje narudžbe kao završene
            narudzba.ZavrsenaNarudzba = true;
            narudzba.DatumIsporuke = DateTime.Now;

            // Spremanje promjena u bazu
            _dbContext.Narudzbas.Update(narudzba);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Narudzba>(narudzba);
        }

        //public async Task<Model.Narudzba> DodajStavkuUKosaricu(int proizvodId, int kolicina)
        //{
        //    Provjeriti postoji li aktivna narudžba
        //   var aktivnaNarudzba = await _dbContext.Narudzbas
        //       .Where(n => n.ZavrsenaNarudzba == false) // Provjera da li je narudžba aktivna
        //       .FirstOrDefaultAsync();

        //    if (aktivnaNarudzba != null)
        //    {
        //        var proizvod = await _dbContext.Proizvods.FindAsync(proizvodId);
        //        if (proizvod == null)
        //        {
        //            throw new Exception("Proizvod nije pronađen.");
        //        }

        //        var novaStavka = new NarudzbaStavkaInsert
        //        {
        //            ProizvodId = proizvodId,
        //            Kolicina = kolicina,
        //            NarudzbaId = aktivnaNarudzba.NarudzbaId,
        //            UkupnaCijenaProizvoda = proizvod.CijenaSaPopustom * kolicina
        //        };

        //        var stavkaService = new NarudzbaStavkaService(_dbContext, _mapper);
        //        var stavka = await stavkaService.Insert(novaStavka);

        //        _dbContext.Narudzbas.Update(aktivnaNarudzba);
        //        await _dbContext.SaveChangesAsync();

        //        Mapiranje entiteta na model prije vraćanja
        //        var aktivnaNarudzbaModel = _mapper.Map<CarCareHub.Model.Narudzba>(aktivnaNarudzba);
        //        return aktivnaNarudzbaModel;
        //    }
        //    else
        //    {
        //        var novaNarudzba = new NarudzbaInsert
        //        {
        //            UkupnaCijenaNarudzbe = 0,
        //            ZavrsenaNarudzba = false,
        //            NarudzbaStavkas = new List<Model.NarudzbaStavka>()
        //        };

        //        var narudzba = await base.Insert(novaNarudzba);
        //        var narudzbaModel = _mapper.Map<CarCareHub.Model.Narudzba>(narudzba);

        //        return narudzbaModel;
        //    }
        //}


        public override IQueryable<Database.Narudzba> AddInclude(IQueryable<Database.Narudzba> query, NarudzbaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                //query = query.Include(z => z.NarudzbaStavke);
                //query = query.Include(z => z.NarudzbaStavke.Proizvod);
                //query = query.Include(z => z.NarudzbaStavke.Proizvod.Proizvodjac);
                //query = query.Include(z => z.NarudzbaStavke.Proizvod.Kategorija);
                //query = query.Include(z => z.Popust.Autoservis);
                //query = query.Include(z => z.Popust.Autoservis.Grad);
                //query = query.Include(z => z.Popust.Autoservis.Grad.Drzava);
                //query = query.Include(z => z.Popust.Autoservis.Uloga);
                //query = query.Include(z => z.Popust.Autoservis.Usluge);
                //query = query.Include(z => z.Popust.Autoservis.Vozilo);
                //query = query.Include(z => z.Popust.FirmaAutodijelova);
                //query = query.Include(z => z.Popust.FirmaAutodijelova.Grad);
                //query = query.Include(z => z.Popust.FirmaAutodijelova.Izvjestaj);
                //query = query.Include(z => z.Popust.FirmaAutodijelova.Uloga);
            }
            return base.AddInclude(query, search);
        }
        public  async Task<List<Model.Narudzba>> GetByLogeedUser_(int id)
        {
            // Početni upit
            var query = _dbContext.Narudzbas.AsQueryable();

            // Dohvati trenutnu prijavljenu ulogu korisnika
            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;
            query = query.Include(x => x.Klijent) // Uključivanje Klijenta
                         .Include(x => x.Zaposlenik) // Uključivanje Zaposlenika
                         .Include(x => x.Autoservis); // Uključivanje Autoservisa (ako je potrebno)

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

            // Dohvatanje podataka iz baze
            var result = await query.ToListAsync();

            // Mapiranje rezultata na Model.Narudzba
            return _mapper.Map<List<Model.Narudzba>>(result);
        }



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


    }


}






