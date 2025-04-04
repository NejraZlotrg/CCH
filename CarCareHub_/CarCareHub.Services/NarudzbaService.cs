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
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

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
            // Get items from cart
            var korpe = await _dbContext.Korpas
                .Where(x => (!insert.KlijentId.HasValue || x.KlijentId == insert.KlijentId) &&
                            (!insert.AutoservisId.HasValue || x.AutoservisId == insert.AutoservisId) &&
                            (!insert.ZaposlenikId.HasValue || x.ZaposlenikId == insert.ZaposlenikId))
                .ToListAsync();

            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            // Create new order
            var narudzba = new CarCareHub.Services.Database.Narudzba
            {
                DatumNarudzbe = DateTime.Now,
                DatumIsporuke = DateTime.Now.AddDays(2),
                Vidljivo = true,
                Adresa = insert.Adresa,
                UkupnaCijenaNarudzbe = 0
            };

            // Set order owner based on role
            if (insert.KlijentId.HasValue && userRole == "Klijent")
            {
                var k = await _dbContext.Klijents.FirstOrDefaultAsync(x => x.KlijentId == insert.KlijentId);
                narudzba.KlijentId = insert.KlijentId.Value;
                narudzba.Adresa = k?.Adresa ?? insert.Adresa;
            }
            else if (insert.ZaposlenikId.HasValue && userRole == "Zaposlenik")
            {
                var z = await _dbContext.Zaposleniks.FirstOrDefaultAsync(x => x.ZaposlenikId == insert.ZaposlenikId);
                narudzba.ZaposlenikId = insert.ZaposlenikId.Value;
                narudzba.Adresa = z?.Adresa ?? insert.Adresa;
            }
            else if (insert.AutoservisId.HasValue && userRole == "Autoservis")
            {
                var a = await _dbContext.Autoservis.FirstOrDefaultAsync(x => x.AutoservisId == insert.AutoservisId);
                narudzba.AutoservisId = insert.AutoservisId.Value;
                narudzba.Adresa = a?.Adresa ?? insert.Adresa;
            }

            await _dbContext.AddAsync(narudzba);
            await _dbContext.SaveChangesAsync();

            decimal ukupnaCijena = 0;
            List<int> firmaAutodijelovaIds = null;

            // Get autoparts companies for autoservice only once
            if (userRole == "Autoservis" && insert.AutoservisId.HasValue)
            {
                firmaAutodijelovaIds = await _dbContext.FirmaAutodijelovas
                    .Where(f => f.BPAutodijeloviAutoservis.Any(a => a.AutoservisId == insert.AutoservisId))
                    .Select(f => f.FirmaAutodijelovaID)
                    .ToListAsync();
            }

            // Process each cart item
            foreach (var item in korpe)
            {
                var proizvod = await _dbContext.Proizvods
                    .Include(p => p.FirmaAutodijelova)
                    .FirstOrDefaultAsync(p => p.ProizvodId == item.ProizvodId);

                if (proizvod == null) continue;

                decimal cijenaProizvoda;
                int kolicina = item.Kolicina ?? 1;

                // Pricing logic based on user role
                switch (userRole)
                {
                    case "Autoservis":
                        bool isInFirmaAutodijelovaList = firmaAutodijelovaIds?.Contains(proizvod.FirmaAutodijelovaID ?? 0) ?? false;

                        if (isInFirmaAutodijelovaList && proizvod.CijenaSaPopustomZaAutoservis.HasValue)
                            cijenaProizvoda = proizvod.CijenaSaPopustomZaAutoservis.Value;
                        else if (proizvod.CijenaSaPopustom.HasValue)
                            cijenaProizvoda = proizvod.CijenaSaPopustom.Value;
                        else
                            cijenaProizvoda = proizvod.Cijena ?? 0;
                        break;

                    case "Zaposlenik":
                    case "Klijent":
                        cijenaProizvoda = proizvod.CijenaSaPopustom.HasValue
                            ? proizvod.CijenaSaPopustom.Value
                            : proizvod.Cijena ?? 0;
                        break;

                    default:
                        cijenaProizvoda = proizvod.Cijena ?? 0;
                        break;
                }

                decimal ukupnaStavka = cijenaProizvoda * kolicina;
                ukupnaCijena += ukupnaStavka;

                var stavkaNarudzbe = new CarCareHub.Services.Database.NarudzbaStavka
                {
                    ProizvodId = item.ProizvodId,
                    NarudzbaId = narudzba.NarudzbaId,
                    Kolicina = kolicina,
                    Vidljivo = true

                };

                narudzba.NarudzbaStavkas.Add(stavkaNarudzbe);
            }

            // Update order totals
            narudzba.UkupnaCijenaNarudzbe = ukupnaCijena;
            narudzba.DatumNarudzbe = DateTime.UtcNow;
            narudzba.DatumIsporuke = DateTime.Now.AddDays(7);

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


        public async Task<List<Model.Narudzba>> GetByLogeedUser_(int id)
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

            // Provjera da li je rezultat null
            if (result == null || !result.Any())
            {
                // Vrati praznu listu ako nema podataka
                return new List<Model.Narudzba>();
            }

            // Mapiranje rezultata na Model.Narudzba
            var mappedResult = _mapper.Map<List<Model.Narudzba>>(result);

            // Vrati mapiranu listu
            return mappedResult;
        }


        public async Task<List<IzvjestajNarudzbi>> GetIzvjestajNarudzbi(DateTime? odDatuma, DateTime? doDatuma, int? kupacId, int? zaposlenikId, int? autoservisId)
        {
            var query = _dbContext.Narudzbas
                .Include(n => n.Klijent) // Include Klijent navigation property
                .Include(n => n.Zaposlenik) // Include Zaposlenik navigation property
                .Include(n => n.Autoservis)
                .Where(x=> x.ZavrsenaNarudzba == true)// Include Autoservis navigation property
                .AsQueryable();

            // Filtriranje prema vremenskom periodu
            if (odDatuma.HasValue)
                query = query.Where(n => n.DatumNarudzbe >= odDatuma.Value);

            if (doDatuma.HasValue)
                query = query.Where(n => n.DatumNarudzbe <= doDatuma.Value);

            // Filtriranje po kupcu, zaposleniku ili autoservisu
            if (kupacId.HasValue)
                query = query.Where(n => n.KlijentId == kupacId.Value);

            if (zaposlenikId.HasValue)
                query = query.Where(n => n.ZaposlenikId == zaposlenikId.Value);

            if (autoservisId.HasValue)
                query = query.Where(n => n.AutoservisId == autoservisId.Value);

            var narudzbe = await query.ToListAsync();

            // Mapiranje u listu izvještaja
            var izvjestaj = narudzbe.Select(n => new IzvjestajNarudzbi
            {
                NarudzbaId = n.NarudzbaId,
                DatumNarudzbe = n.DatumNarudzbe,
                Klijent = n.Klijent != null ? new Model.Klijent // Map Klijent navigation property
                {
                    KlijentId = n.Klijent.KlijentId,
                    Ime = n.Klijent.Ime,
                    Prezime = n.Klijent.Prezime
                } : null,
                Autoservis = n.Autoservis != null ? new Model.Autoservis // Map Autoservis navigation property
                {
                    AutoservisId = n.Autoservis.AutoservisId,
                    Naziv = n.Autoservis.Naziv
                } : null,
                Zaposlenik = n.Zaposlenik != null ? new Model.Zaposlenik // Map Zaposlenik navigation property
                {
                    ZaposlenikId = n.Zaposlenik.ZaposlenikId,
                    Ime = n.Zaposlenik.Ime,
                    Prezime = n.Zaposlenik.Prezime
                } : null,
                UkupnaCijena = n.UkupnaCijenaNarudzbe,
                Status = n.ZavrsenaNarudzba
            }).ToList();

            return izvjestaj;
        }

        public async Task<List<AutoservisIzvjestaj>> GetAutoservisIzvjestaj()
        {
            try
            {
                // Calculate date range (last 30 days)
                var startDate = DateTime.Now.AddDays(-30);
                var endDate = DateTime.Now;

                // Get all completed orders for autoservices in the last 30 days
                var orders = await _dbContext.Narudzbas
                    .Include(n => n.Autoservis)
                    .Include(n => n.NarudzbaStavkas)
                        .ThenInclude(ns => ns.Proizvod)
                    .Where(n => n.AutoservisId != null
                              && n.ZavrsenaNarudzba == true
                              && n.DatumNarudzbe >= startDate
                              && n.DatumNarudzbe <= endDate)
                    .AsNoTracking()
                    .ToListAsync();

                // Group by autoservice and calculate statistics
                var report = orders
                    .GroupBy(n => n.AutoservisId)
                    .Select(g => {
                        var firstOrder = g.First();
                        return new AutoservisIzvjestaj
                        {
                            AutoservisId = g.Key.Value,
                            NazivAutoservisa = firstOrder.Autoservis?.Naziv ?? "Nepoznato",
                            UkupanIznos = (decimal)g.Sum(n => n.UkupnaCijenaNarudzbe),
                            BrojNarudzbi = g.Count(),
                            ProsjecnaCijena = (decimal)g.Average(n => n.UkupnaCijenaNarudzbe),
                            NajpopularnijiProizvodi = g.SelectMany(n => n.NarudzbaStavkas)
                                .GroupBy(ns => ns.Proizvod)
                                .OrderByDescending(pg => pg.Sum(ns => ns.Kolicina))
                                .Take(3)
                                .Select(pg => new ProizvodStatistika
                                {
                                    ProizvodId = pg.Key.ProizvodId,
                                    Naziv = pg.Key.Naziv,
                                    UkupnaKolicina = (int)pg.Sum(ns => ns.Kolicina),
                                    UkupnaVrijednost = (decimal)pg.Sum(ns => ns.Kolicina * (ns.Proizvod.Cijena ?? 0))
                                }).ToList()
                        };
                    })
                    .OrderByDescending(x => x.UkupanIznos)
                    .ToList();

                return report;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error generating autoservice report: {ex.Message}");
                throw;
            }
        }

        public async Task<List<Model.Narudzba>> GetNarudzbeZaFirmu(int id)
        {
            // Početni upit za Narudžbe
            var query = _dbContext.NarudzbaStavkas.AsQueryable();

            // Dohvati trenutnu prijavljenu ulogu korisnika
            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            // Uključivanje potrebnih entiteta
            query = query.Include(x => x.Proizvod)
                         .ThenInclude(ns => ns.FirmaAutodijelova).Where(f => f.Proizvod.FirmaAutodijelova.FirmaAutodijelovaID == id);
                      

            var query2 = _dbContext.Narudzbas.AsQueryable();

            // Filtriranje na temelju korisničke uloge
            // Prvo dobijte distinct NarudzbaID iz query1
            var narudzbaIdsIzQuery1 = await query.Select(x => x.NarudzbaId).Distinct().ToListAsync();

            // Zatim filtrirajte query2
            query2 = query2.Where(n => narudzbaIdsIzQuery1.Contains(n.NarudzbaId))
                           .Include(x => x.NarudzbaStavkas)
                           .ThenInclude(ns => ns.Proizvod);

            // Dohvatanje podataka iz baze
            var result = await query2.ToListAsync();

            // Provjera da li je rezultat null
            if (result == null || !result.Any())
            {
                return new List<Model.Narudzba>();
            }

            // Mapiranje rezultata na Model.Narudzba
            var mappedResult = _mapper.Map<List<Model.Narudzba>>(result);

            return mappedResult;
        }
    }
}






