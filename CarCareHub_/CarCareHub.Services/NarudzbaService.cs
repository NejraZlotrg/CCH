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
        private readonly IRabbitMQProducer _rabbitMQProducer;

        public NarudzbaService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor, IRabbitMQProducer rabbitMQProducer) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
            _httpContextAccessor = httpContextAccessor;
            _rabbitMQProducer = rabbitMQProducer;
        }
        public override async Task<Model.Narudzba> Insert(Model.NarudzbaInsert insert)
        {
            var korpe = await _dbContext.Korpas
                .Where(x => (!insert.KlijentId.HasValue || x.KlijentId == insert.KlijentId) &&
                            (!insert.AutoservisId.HasValue || x.AutoservisId == insert.AutoservisId) &&
                            (!insert.ZaposlenikId.HasValue || x.ZaposlenikId == insert.ZaposlenikId))
                .ToListAsync();

            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;

            var narudzba = new CarCareHub.Services.Database.Narudzba
            {
                DatumNarudzbe = DateTime.Now,
                DatumIsporuke = DateTime.Now.AddDays(2),
                Vidljivo = true,
                Adresa = insert.Adresa,
                UkupnaCijenaNarudzbe = 0
            };

            string email = "";
            string imePrezime = "";

            if (insert.KlijentId.HasValue && userRole == "Klijent")
            {
                var k = await _dbContext.Klijents.FirstOrDefaultAsync(x => x.KlijentId == insert.KlijentId);
                narudzba.KlijentId = insert.KlijentId.Value;
                narudzba.Adresa = k?.Adresa ?? insert.Adresa;

                email = k?.Email ?? "";
                imePrezime = $"{k?.Ime} {k?.Prezime}";
            }
            else if (insert.ZaposlenikId.HasValue && userRole == "Zaposlenik")
            {
                var z = await _dbContext.Zaposleniks.FirstOrDefaultAsync(x => x.ZaposlenikId == insert.ZaposlenikId);
                narudzba.ZaposlenikId = insert.ZaposlenikId.Value;
                narudzba.Adresa = z?.Adresa ?? insert.Adresa;

                email = z?.Email ?? "";
                imePrezime = $"{z?.Ime} {z?.Prezime}";
            }
            else if (insert.AutoservisId.HasValue && userRole == "Autoservis")
            {
                var a = await _dbContext.Autoservis.FirstOrDefaultAsync(x => x.AutoservisId == insert.AutoservisId);
                narudzba.AutoservisId = insert.AutoservisId.Value;
                narudzba.Adresa = a?.Adresa ?? insert.Adresa;

                email = a?.Email ?? "";
                imePrezime = $"{a?.Naziv}";
            }

            await _dbContext.AddAsync(narudzba);
            await _dbContext.SaveChangesAsync();

            decimal ukupnaCijena = 0;
            List<int> firmaAutodijelovaIds = null;

            if (userRole == "Autoservis" && insert.AutoservisId.HasValue)
            {
                firmaAutodijelovaIds = await _dbContext.FirmaAutodijelovas
                    .Where(f => f.BPAutodijeloviAutoservis.Any(a => a.AutoservisId == insert.AutoservisId))
                    .Select(f => f.FirmaAutodijelovaID)
                    .ToListAsync();
            }

            foreach (var item in korpe)
            {
                var proizvod = await _dbContext.Proizvods
                    .Include(p => p.FirmaAutodijelova)
                    .FirstOrDefaultAsync(p => p.ProizvodId == item.ProizvodId);

                if (proizvod == null) continue;

                decimal cijenaProizvoda;
                int kolicina = item.Kolicina ?? 1;

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

            narudzba.UkupnaCijenaNarudzbe = ukupnaCijena;
            narudzba.DatumNarudzbe = DateTime.UtcNow;
            narudzba.DatumIsporuke = DateTime.Now.AddDays(7);

            await _dbContext.SaveChangesAsync();

            _rabbitMQProducer.SendMessage(new NarudzbaMessage
            {
                Email = email,
                ImePrezime = imePrezime,
                BrojNarudzbe = narudzba.NarudzbaId.ToString(),
                DatumNarudzbe = narudzba.DatumNarudzbe ?? DateTime.Now
            });


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
            var narudzba = await _dbContext.Narudzbas.FindAsync(narudzbaId);
            if (narudzba == null)
                throw new Exception("Narudžba nije pronađena.");
            narudzba.ZavrsenaNarudzba = true;
            narudzba.DatumIsporuke = DateTime.Now;
            _dbContext.Narudzbas.Update(narudzba);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Narudzba>(narudzba);
        }
        public override IQueryable<Database.Narudzba> AddInclude(IQueryable<Database.Narudzba> query, NarudzbaSearchObject? search = null)
        {
            return base.AddInclude(query, search);
        }
        public async Task<List<Model.Narudzba>> GetByLogeedUser_(int id)
        {
            var query = _dbContext.Narudzbas.AsQueryable();
            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;
            query = query.Include(x => x.Klijent)
                         .Include(x => x.Zaposlenik)
                         .Include(x => x.Autoservis);
            if (userRole != null)
            {
                switch (userRole)
                {
                    case "Klijent":
                        query = query.Where(x => x.KlijentId == id);
                        break;
                    case "Zaposlenik":
                        query = query.Where(x => x.ZaposlenikId == id);
                        break;
                    case "Autoservis":
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
            var result = await query.ToListAsync();
            if (result == null || !result.Any())
            {
                return new List<Model.Narudzba>();
            }
            var mappedResult = _mapper.Map<List<Model.Narudzba>>(result);
            return mappedResult;
        }
        public async Task<List<IzvjestajNarudzbi>> GetIzvjestajNarudzbi(DateTime? odDatuma, DateTime? doDatuma, int? kupacId, int? zaposlenikId, int? autoservisId)
        {
            var query = _dbContext.Narudzbas
                .Include(n => n.Klijent)
                .Include(n => n.Zaposlenik)
                .Include(n => n.Autoservis)
                .Where(x => x.ZavrsenaNarudzba == true)
                .AsQueryable();
            if (odDatuma.HasValue)
                query = query.Where(n => n.DatumNarudzbe >= odDatuma.Value);
            if (doDatuma.HasValue)
                query = query.Where(n => n.DatumNarudzbe <= doDatuma.Value);
            if (kupacId.HasValue)
                query = query.Where(n => n.KlijentId == kupacId.Value);
            if (zaposlenikId.HasValue)
                query = query.Where(n => n.ZaposlenikId == zaposlenikId.Value);
            if (autoservisId.HasValue)
                query = query.Where(n => n.AutoservisId == autoservisId.Value);
            var narudzbe = await query.ToListAsync();
            var izvjestaj = narudzbe.Select(n => new IzvjestajNarudzbi
            {
                NarudzbaId = n.NarudzbaId,
                DatumNarudzbe = n.DatumNarudzbe,
                Klijent = n.Klijent != null ? new Model.Klijent
                {
                    KlijentId = n.Klijent.KlijentId,
                    Ime = n.Klijent.Ime,
                    Prezime = n.Klijent.Prezime
                } : null,
                Autoservis = n.Autoservis != null ? new Model.Autoservis
                {
                    AutoservisId = n.Autoservis.AutoservisId,
                    Naziv = n.Autoservis.Naziv
                } : null,
                Zaposlenik = n.Zaposlenik != null ? new Model.Zaposlenik
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
                var startDate = DateTime.Now.AddDays(-30);
                var endDate = DateTime.Now;
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
                var report = orders
                    .GroupBy(n => n.AutoservisId)
                    .Select(g =>
                    {
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
            var query = _dbContext.NarudzbaStavkas.AsQueryable();
            var userRole = _httpContextAccessor.HttpContext.User?.FindFirst(ClaimTypes.Role)?.Value;
            query = query.Include(x => x.Proizvod)
                         .ThenInclude(ns => ns.FirmaAutodijelova).Where(f => f.Proizvod.FirmaAutodijelova.FirmaAutodijelovaID == id);
            var query2 = _dbContext.Narudzbas.AsQueryable();
            var narudzbaIdsIzQuery1 = await query.Select(x => x.NarudzbaId).Distinct().ToListAsync();
            query2 = query2.Where(n => narudzbaIdsIzQuery1.Contains(n.NarudzbaId))
                           .Include(x => x.NarudzbaStavkas)
                           .ThenInclude(ns => ns.Proizvod);
            var result = await query2.ToListAsync();
            if (result == null || !result.Any())
            {
                return new List<Model.Narudzba>();
            }
            var mappedResult = _mapper.Map<List<Model.Narudzba>>(result);
            return mappedResult;
        }
        public async Task<List<KlijentIzvjestaj>> GetNarudzbeZaSveKlijente()
        {
            try
            {
                var startDate = DateTime.Now.AddDays(-30);
                var endDate = DateTime.Now;
                var orders = await _dbContext.Narudzbas
                    .Include(n => n.Klijent)
                    .Include(n => n.NarudzbaStavkas)
                        .ThenInclude(ns => ns.Proizvod)
                    .Where(n => n.KlijentId != null
                              && n.ZavrsenaNarudzba == true
                              && n.DatumNarudzbe >= startDate
                              && n.DatumNarudzbe <= endDate)
                    .AsNoTracking()
                    .ToListAsync();
                if (orders == null || !orders.Any())
                {
                    return new List<KlijentIzvjestaj>();
                }
                var report = orders
                    .GroupBy(n => n.KlijentId)
                    .Where(g => g.Key.HasValue)
                    .Select(g =>
                    {
                        var firstOrder = g.FirstOrDefault();
                        if (firstOrder == null || firstOrder.Klijent == null)
                        {
                            return null;
                        }
                        var narudzbaStavke = g.SelectMany(n => n.NarudzbaStavkas ?? Enumerable.Empty<Database.NarudzbaStavka>());
                        var proizvodiGroups = narudzbaStavke
                            .Where(ns => ns.Proizvod != null)
                            .GroupBy(ns => ns.Proizvod);
                        var popularniProizvodi = proizvodiGroups
                            .OrderByDescending(pg => pg.Sum(ns => ns.Kolicina))
                            .Take(3)
                            .Select(pg => new ProizvodStatistika
                            {
                                ProizvodId = pg.Key?.ProizvodId ?? 0,
                                Naziv = pg.Key?.Naziv ?? "Nepoznato",
                                UkupnaKolicina = (int)pg.Sum(ns => ns.Kolicina),
                                UkupnaVrijednost = (decimal)pg.Sum(ns => ns.Kolicina * (pg.Key?.Cijena ?? 0))
                            })
                            .ToList();
                        return new KlijentIzvjestaj
                        {
                            KlijentId = g.Key.Value,
                            ImePrezime = $"{firstOrder.Klijent.Ime} {firstOrder.Klijent.Prezime}".Trim(),
                            UkupanIznos = (decimal)g.Sum(n => n.UkupnaCijenaNarudzbe),
                            BrojNarudzbi = g.Count(),
                            ProsjecnaVrijednost = g.Any() ? (decimal)g.Average(n => n.UkupnaCijenaNarudzbe) : 0,
                            NajpopularnijiProizvodi = popularniProizvodi
                        };
                    })
                    .Where(x => x != null)
                    .OrderByDescending(x => x.UkupanIznos)
                    .ToList();
                return report ?? new List<KlijentIzvjestaj>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Greška pri generisanju izvještaja za klijente: {ex.Message}");
                throw;
            }
        }
        public async Task<List<ZaposlenikIzvjestaj>> GetNarudzbeZaSveZaposlenike()
        {
            try
            {
                var startDate = DateTime.Now.AddDays(-30);
                var endDate = DateTime.Now;
                var orders = await _dbContext.Narudzbas
                    .Include(n => n.Zaposlenik)
                    .Include(n => n.NarudzbaStavkas)
                        .ThenInclude(ns => ns.Proizvod)
                    .Where(n => n.ZaposlenikId != null
                              && n.ZavrsenaNarudzba == true
                              && n.DatumNarudzbe >= startDate
                              && n.DatumNarudzbe <= endDate)
                    .AsNoTracking()
                    .ToListAsync();
                if (orders == null || !orders.Any())
                {
                    return new List<ZaposlenikIzvjestaj>();
                }
                var report = orders
                    .GroupBy(n => n.ZaposlenikId)
                    .Where(g => g.Key.HasValue)
                    .Select(g =>
                    {
                        var firstOrder = g.FirstOrDefault();
                        if (firstOrder == null || firstOrder.Zaposlenik == null)
                        {
                            return null;
                        }
                        var narudzbaStavke = g.SelectMany(n => n.NarudzbaStavkas ?? Enumerable.Empty<Database.NarudzbaStavka>());
                        var proizvodiGroups = narudzbaStavke
                            .Where(ns => ns.Proizvod != null)
                            .GroupBy(ns => ns.Proizvod);
                        var popularniProizvodi = proizvodiGroups
                            .OrderByDescending(pg => pg.Sum(ns => ns.Kolicina))
                            .Take(3)
                            .Select(pg => new ProizvodStatistika
                            {
                                ProizvodId = pg.Key?.ProizvodId ?? 0,
                                Naziv = pg.Key?.Naziv ?? "Nepoznato",
                                UkupnaKolicina = (int)pg.Sum(ns => ns.Kolicina),
                                UkupnaVrijednost = (decimal)pg.Sum(ns => ns.Kolicina * (pg.Key?.Cijena ?? 0))
                            })
                            .ToList();
                        return new ZaposlenikIzvjestaj
                        {
                            ZaposlenikId = g.Key.Value,
                            ImePrezime = $"{firstOrder.Zaposlenik.Ime} {firstOrder.Zaposlenik.Prezime}".Trim(),
                            UkupanIznos = (decimal)g.Sum(n => n.UkupnaCijenaNarudzbe),
                            BrojNarudzbi = g.Count(),
                            ProsjecnaVrijednost = g.Any() ? (decimal)g.Average(n => n.UkupnaCijenaNarudzbe) : 0,
                            NajpopularnijiProizvodi = popularniProizvodi,
                            Autoservis = firstOrder.Autoservis?.Naziv ?? "Nepoznato"
                        };
                    })
                    .Where(x => x != null)
                    .OrderByDescending(x => x.UkupanIznos)
                    .ToList();
                return report ?? new List<ZaposlenikIzvjestaj>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Greška pri generisanju izvještaja za zaposlenike: {ex.Message}");
                throw;
            }
        }



        public async Task AddSampleNarudzbeAsync()
        {
            if (!_dbContext.Narudzbas.Any())
            {
                var klijentId = 1;
                var zaposlenikId = 1;
                var autoservisId = 1;
                var proizvodIds = Enumerable.Range(1, 5).ToList();

                var klijentExists = await _dbContext.Klijents.AnyAsync(k => k.KlijentId == klijentId);
                var zaposlenikExists = await _dbContext.Zaposleniks.AnyAsync(z => z.ZaposlenikId == zaposlenikId);
                var autoservisExists = await _dbContext.Autoservis.AnyAsync(a => a.AutoservisId == autoservisId);
                var proizvodiExist = await _dbContext.Proizvods
                    .Where(p => proizvodIds.Contains(p.ProizvodId))
                    .CountAsync() == proizvodIds.Count;

                if (!klijentExists || !zaposlenikExists || !autoservisExists || !proizvodiExist)
                {
                    throw new Exception("Nedostaju potrebni podaci u bazi (klijent, zaposlenik, autoservis ili proizvodi sa ID 1-5)");
                }

                var klijentAdresa = await _dbContext.Klijents
                    .Where(k => k.KlijentId == klijentId)
                    .Select(k => k.Adresa)
                    .FirstOrDefaultAsync();

                var zaposlenikAdresa = await _dbContext.Zaposleniks
                    .Where(z => z.ZaposlenikId == zaposlenikId)
                    .Select(z => z.Adresa)
                    .FirstOrDefaultAsync();

                var autoservisAdresa = await _dbContext.Autoservis
                    .Where(a => a.AutoservisId == autoservisId)
                    .Select(a => a.Adresa)
                    .FirstOrDefaultAsync();

                var narudzbe = new List<Database.Narudzba>
        {
            new Database.Narudzba
            {
                KlijentId = klijentId,
                DatumNarudzbe = DateTime.Now.AddDays(-10),
                DatumIsporuke = DateTime.Now.AddDays(-5),
                Adresa = klijentAdresa,
                UkupnaCijenaNarudzbe = 648.0m,
                ZavrsenaNarudzba = true,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 1, Kolicina = 2, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 2, Kolicina = 1, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 3, Kolicina = 3, Vidljivo = true }
                }
            },
            new Database.Narudzba
            {
                KlijentId = klijentId,
                DatumNarudzbe = DateTime.Now.AddDays(-7),
                DatumIsporuke = DateTime.Now.AddDays(-2),
                Adresa = klijentAdresa,
                UkupnaCijenaNarudzbe = 325m,
                ZavrsenaNarudzba = true,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 2, Kolicina = 2, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 4, Kolicina = 1, Vidljivo = true }
                }
            },
            new Database.Narudzba
            {
                ZaposlenikId = zaposlenikId,
                DatumNarudzbe = DateTime.Now.AddDays(-5),
                DatumIsporuke = DateTime.Now.AddDays(-1),
                Adresa = zaposlenikAdresa,
                UkupnaCijenaNarudzbe = 727.0m,
                ZavrsenaNarudzba = true,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 1, Kolicina = 1, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 2, Kolicina = 3, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 3, Kolicina = 2, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 5, Kolicina = 1, Vidljivo = true }
                }
            },
            new Database.Narudzba
            {
                ZaposlenikId = zaposlenikId,
                DatumNarudzbe = DateTime.Now.AddDays(-3),
                DatumIsporuke = DateTime.Now,
                Adresa = zaposlenikAdresa,
                UkupnaCijenaNarudzbe = 304.0m,
                ZavrsenaNarudzba = false,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 3, Kolicina = 4, Vidljivo = true }
                }
            },
            new Database.Narudzba
            {
                AutoservisId = autoservisId,
                DatumNarudzbe = DateTime.Now.AddDays(-2),
                DatumIsporuke = DateTime.Now.AddDays(2),
                Adresa = autoservisAdresa,
                UkupnaCijenaNarudzbe = 967.0m,
                ZavrsenaNarudzba = false,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 1, Kolicina = 5, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 3, Kolicina = 2, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 5, Kolicina = 1, Vidljivo = true }
                }
            },
            new Database.Narudzba
            {
                AutoservisId = autoservisId,
                DatumNarudzbe = DateTime.Now.AddDays(-1),
                DatumIsporuke = DateTime.Now.AddDays(3),
                Adresa = autoservisAdresa,
                UkupnaCijenaNarudzbe = 530.0m,
                ZavrsenaNarudzba = false,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 2, Kolicina = 3, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 4, Kolicina = 2, Vidljivo = true }
                }
            },
            new Database.Narudzba
            {
                KlijentId = klijentId,
                DatumNarudzbe = DateTime.Now.AddDays(-4),
                DatumIsporuke = DateTime.Now.AddDays(1),
                Adresa = klijentAdresa,
                UkupnaCijenaNarudzbe = 496.0m,
                ZavrsenaNarudzba = true,
                Vidljivo = true,
                NarudzbaStavkas = new List<Database.NarudzbaStavka>
                {
                    new Database.NarudzbaStavka { ProizvodId = 1, Kolicina = 1, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 2, Kolicina = 1, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 3, Kolicina = 1, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 4, Kolicina = 1, Vidljivo = true },
                    new Database.NarudzbaStavka { ProizvodId = 5, Kolicina = 1, Vidljivo = true }
                }
            },
new Database.Narudzba
{
    AutoservisId = 2,
    DatumNarudzbe = DateTime.Now.AddDays(-3),
    DatumIsporuke = DateTime.Now.AddDays(2),
    Adresa = await _dbContext.Autoservis
              .Where(a => a.AutoservisId == 2)
              .Select(a => a.Adresa)
              .FirstOrDefaultAsync(),
    UkupnaCijenaNarudzbe = 1040.25m,
    ZavrsenaNarudzba = false,
    Vidljivo = true,
    NarudzbaStavkas = new List<Database.NarudzbaStavka>
    {
        new Database.NarudzbaStavka { ProizvodId = 1, Kolicina = 3, Vidljivo = true },
        new Database.NarudzbaStavka { ProizvodId = 2, Kolicina = 2, Vidljivo = true },
        new Database.NarudzbaStavka { ProizvodId = 4, Kolicina = 4, Vidljivo = true },
        new Database.NarudzbaStavka { ProizvodId = 5, Kolicina = 1, Vidljivo = true }
    }
}
        };

                await _dbContext.Narudzbas.AddRangeAsync(narudzbe);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
