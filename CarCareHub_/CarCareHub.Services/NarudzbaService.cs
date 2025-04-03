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
            narudzba.Adresa = insert.Adresa;

            narudzba.UkupnaCijenaNarudzbe = 0;
            if (insert.KlijentId.HasValue && userRole=="Klijent")
            {
                var k = _dbContext.Klijents.FirstOrDefault(x => x.KlijentId == insert.KlijentId);
                narudzba.KlijentId = insert.KlijentId.Value;
                narudzba.ZaposlenikId = null;
                narudzba.AutoservisId = null;
                narudzba.Adresa = k.Adresa;
            }
            else if (insert.ZaposlenikId.HasValue && userRole == "Zaposlenik")
            {
                var Z = _dbContext.Zaposleniks.FirstOrDefault(x => x.ZaposlenikId == insert.ZaposlenikId);

                narudzba.ZaposlenikId = insert.ZaposlenikId.Value;
                narudzba.KlijentId = null;
                narudzba.AutoservisId = null;
                narudzba.Adresa = Z.Adresa;

            }
            else if (insert.AutoservisId.HasValue && userRole == "Autoservis")
            {
                var A = _dbContext.Autoservis.FirstOrDefault(x => x.AutoservisId == insert.AutoservisId);

                narudzba.AutoservisId = insert.AutoservisId.Value;
                narudzba.KlijentId = null;
                narudzba.ZaposlenikId = null;
                narudzba.Adresa = A?.Adresa ?? insert.Adresa;

                // Dobavi ID-e firmi autodijelova povezanih sa ovim autoservisom
                var firmaAutodijelovaIds = await _dbContext.FirmaAutodijelovas
                    .Where(f => f.BPAutodijeloviAutoservis.Any(a => a.AutoservisId == insert.AutoservisId))
                    .Select(f => f.FirmaAutodijelovaID)
                    .ToListAsync();
            }

            await _dbContext.AddAsync(narudzba);
            await _dbContext.SaveChangesAsync();
            decimal ukupnaCijena = 0;

            foreach (var item in korpe)
            {
                var proizvod = await _dbContext.Proizvods
                    .Include(p => p.FirmaAutodijelova) // Uključite FirmaAutodijelova ako je potrebno
                    .FirstOrDefaultAsync(p => p.ProizvodId == item.ProizvodId);

                if (proizvod != null && insert.AutoservisId!=null)
                {
                    decimal cijenaProizvoda;
                    int kolicina = item.Kolicina ?? 1;
                    var firmaAutodijelovaIds = await _dbContext.FirmaAutodijelovas
                   .Where(f => f.BPAutodijeloviAutoservis.Any(a => a.AutoservisId == insert.AutoservisId))
                   .Select(f => f.FirmaAutodijelovaID)
                   .ToListAsync();
                    // Provjeri da li je proizvod u listi firmi autodijelova povezanih sa autoservisom
                    bool isInFirmaAutodijelovaList = firmaAutodijelovaIds.Contains((int)proizvod.FirmaAutodijelovaID);

                    // Logika odabira cijene
                    if (userRole == "Autoservis" &&
                        proizvod.CijenaSaPopustomZaAutoservis.HasValue &&
                        isInFirmaAutodijelovaList)
                    {
                        cijenaProizvoda = proizvod.CijenaSaPopustomZaAutoservis.Value;
                    }
                    else if (proizvod.CijenaSaPopustom.HasValue)
                    {
                        cijenaProizvoda = proizvod.CijenaSaPopustom.Value;
                    }
                    else
                    {
                        cijenaProizvoda = proizvod.Cijena ?? 0;
                    }

                    decimal ukupnaStavka = cijenaProizvoda * kolicina;
                    ukupnaCijena += ukupnaStavka;

                    var stavkaNarudzbe = new CarCareHub.Services.Database.NarudzbaStavka
                    {
                        ProizvodId = item.ProizvodId,
                        NarudzbaId = narudzba.NarudzbaId,
                        Kolicina = kolicina,
                       
                    };

                    narudzba.NarudzbaStavkas.Add(stavkaNarudzbe);
                }
            }



            narudzba.UkupnaCijenaNarudzbe = ukupnaCijena;
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
                .Include(n => n.Autoservis) // Include Autoservis navigation property
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


    }
}






