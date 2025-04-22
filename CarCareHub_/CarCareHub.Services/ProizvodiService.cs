using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CarCareHub.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, CarCareHub.Services.Database.Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, Model.ProizvodiInsert, Model.ProizvodiUpdate>
        , IProizvodiService
    {
        public BaseState _baseState { get; set; }
        public ProizvodiService(BaseState baseState, CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _baseState = baseState;
        }

        public override Task<Model.Proizvod> Insert(Model.ProizvodiInsert insert)
        {
            var state = _baseState.CreateState("initial");
            insert.Cijena = Math.Round((decimal)(insert.Cijena), 2);
            // Standardni popust ako je postavljen
            if (insert.Popust.HasValue && insert.Popust > 0)
            {
                var pom = insert.Cijena * insert.Popust.Value / 100;
                insert.CijenaSaPopustom = insert.Cijena - pom;
            }
            // Dodaj automatski 5% popusta za autoservise ako nema drugog popusta
            else if (insert.CijenaSaPopustom == null)
            {
                insert.CijenaSaPopustomZaAutoservis = insert.Cijena * 0.95m; // 5% popusta
            }

            return state.Insert(insert);
        }

        public override async Task<Model.Proizvod> Update(int id, Model.ProizvodiUpdate update)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);

            // Ako je popust eksplicitno postavljen
            if (update.Popust.HasValue)
            {
                if (update.Popust > 0)
                {
                    // Izračunaj standardni popust i zaokruži na 2 decimale
                    var pom = update.Cijena * update.Popust.Value / 100;
                    update.CijenaSaPopustom = Math.Round((decimal)(update.Cijena - pom), 2);
                    // Resetiraj autoservis popust
                    update.CijenaSaPopustomZaAutoservis = null;
                }
                else
                {
                    // Ako je popust 0, obriši standardni popust
                    update.CijenaSaPopustom = null;
                    // Postavi autoservis popust (5%) i zaokruži na 2 decimale
                    update.CijenaSaPopustomZaAutoservis = Math.Round((decimal)(update.Cijena * 0.95m), 2);
                }
            }
            // Ako je popust null (nije postavljen)
            else
            {
                // Obriši standardni popust
                update.CijenaSaPopustom = null;

                // Dodaj automatski 5% popusta za autoservise samo ako nije bilo prijašnjeg popusta i zaokruži
                if (entity.CijenaSaPopustom == null)
                {
                    update.CijenaSaPopustomZaAutoservis = Math.Round((decimal)(update.Cijena * 0.95m), 2);
                }
            }

            return await state.Update(id, update);
        }

        public virtual async Task<PagedResult<CarCareHub.Model.Proizvod>> GetForUsers([FromQuery] ProizvodiSearchObject search = null)
        {

            var query = _dbContext.Proizvods.Where(x => x.StateMachine == "active" && x.Vidljivo == true);
            PagedResult<CarCareHub.Model.Proizvod> result = new PagedResult<CarCareHub.Model.Proizvod>();

            query = AddFilter(query, search); // Primjenjuje filtere
            query = AddInclude(query, search); // Ako koristiš include za relacije

            result.Count = await query.CountAsync(); // Broj ukupnih stavki

            // Ispravka paginacije
            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value) // Pravi ispravnu paginaciju
                             .Take(search.PageSize.Value); // Uzimanje traženog broja stavki
            }


            var list = await query.ToListAsync(); // Dobijanje rezultata

            result.Result = _mapper.Map<List<CarCareHub.Model.Proizvod>>(list); // Mapiranje na odgovarajući model
            return result; // Vraćanje rezultata

        }
        public virtual async Task<PagedResult<CarCareHub.Model.Proizvod>> GetForAutoservisSapoputomArtikli(int autoservisID, [FromQuery] ProizvodiSearchObject search = null)
        {
            // Inicijalizacija osnovnog upita za proizvode
            var query = _dbContext.Proizvods
                                  .Where(x => x.StateMachine == "active" && x.Vidljivo == true);

            // Provera da li je filter za autoservis prisutan u upitu
            if (autoservisID != 0) // Ako je autoservisID validan (razlikuje 0 od null)
            {
                // Dohvatanje firmi autodijelova koje imaju listu autoservisa
                var firmaAutodijelovaIds = await _dbContext.FirmaAutodijelovas
                    .Where(f => f.BPAutodijeloviAutoservis.Any(a => a.AutoservisId == autoservisID))
                    .Select(f => f.FirmaAutodijelovaID)
                    .ToListAsync();

                // Filtriranje proizvoda na osnovu firmi koje imaju odgovarajući autoservis
                if (firmaAutodijelovaIds.Any()) // Ako postoji barem jedna firma sa odgovarajućim autoservisom
                {
                    query = query.Where(p => firmaAutodijelovaIds.Contains(p.FirmaAutodijelovaID ?? 0));
                }
                else
                {
                    return new PagedResult<CarCareHub.Model.Proizvod> { Count = 0, Result = new List<CarCareHub.Model.Proizvod>() };
                }
            }

            // Primena ostalih filtera
            query = AddFilter(query, search);
            query = AddInclude(query, search);

            // Broj ukupnih stavki
            PagedResult<CarCareHub.Model.Proizvod> result = new PagedResult<CarCareHub.Model.Proizvod>
            {
                Count = await query.CountAsync()
            };

            // Ispravka paginacije
            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            // Dobijanje rezultata sa mapiranjem
            var list = await query.ToListAsync();
            var mappedList = _mapper.Map<List<CarCareHub.Model.Proizvod>>(list);

            // Primjena 5% popusta za autoservise gdje je potrebno
            foreach (var proizvod in mappedList)
            {
                if (proizvod.CijenaSaPopustom == null && proizvod.Cijena != null)
                {
                    proizvod.CijenaSaPopustomZaAutoservis = proizvod.Cijena * 0.95m; // 5% popusta
                }
            }

            result.Result = mappedList;
            return result;
        }



        public async Task<Model.Proizvod> Activate(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            return await state.Activate(id);
        }

        public async Task<Model.Proizvod> Hide(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            return await state.Hide(id);
        }

        public async Task<List<string>> AllowedActions(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity?.StateMachine ?? "initial");
            return await state.AllowedActions(id);
        }

        public override IQueryable<Database.Proizvod> AddInclude(IQueryable<Database.Proizvod> query, ProizvodiSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Kategorija);
                query = query.Include(z => z.Proizvodjac);
                query = query.Include(z => z.FirmaAutodijelova);
                query = query.Include(z => z.FirmaAutodijelova.Grad);
                query = query.Include(z => z.FirmaAutodijelova.Grad.Drzava);
                query = query.Include(z => z.FirmaAutodijelova.Uloga);
                query = query.Include(h => h.Model);
                query = query.Include(h => h.Model.Vozilo);
                query = query.Include(h => h.Model.Godiste);



            }
            return base.AddInclude(query, search);
        }
        public override IQueryable<Database.Proizvod> AddFilter(IQueryable<Database.Proizvod> query, ProizvodiSearchObject search = null)
        {
            query = base.AddFilter(query, search);

            // Primijeni dodatni filter po nazivu proizvoda
            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                query = query.Where(x => x.Naziv.Contains(search.Naziv));
            }

            // Primijeni dodatni filter po nazivu firme
            if (!string.IsNullOrWhiteSpace(search?.NazivFirme))
            {
                query = query.Where(x => x.FirmaAutodijelova.NazivFirme.StartsWith(search.NazivFirme));
            }

            // Primijeni dodatni filter po JIB-u ili MBS-u firme
            if (!string.IsNullOrWhiteSpace(search?.JIB_MBS))
            {
                query = query.Where(x => x.FirmaAutodijelova.JIB.StartsWith(search.JIB_MBS) || x.FirmaAutodijelova.MBS.StartsWith(search.JIB_MBS));
            }

            // Primijeni dodatni filter po gradu firme
            if (!string.IsNullOrWhiteSpace(search?.NazivGrada))
            {
                //{
                //    query = query.Where(x => x.FirmaAutodijelova != null &&
                //                              x.FirmaAutodijelova.Grad != null &&
                //                              x.FirmaAutodijelova.Grad.NazivGrada.Contains(search.Naziv));
                query = query.Where(x => x.FirmaAutodijelova.Grad.NazivGrada.StartsWith(search.NazivGrada));
            }

            if (!string.IsNullOrWhiteSpace(search?.MarkaVozila))
            {

                query = query.Where(x => x.Model.Vozilo.MarkaVozila.StartsWith(search.MarkaVozila));
            }

            //if (search.GodisteVozila != null)
            //{
            //    query = query.Where(x => x.Vozilo.GodisteVozila == search.GodisteVozila);
            //}

            //   if (!string.IsNullOrWhiteSpace(search?.ModelProizvoda))
            // {
            //    query = query.Where(x => x.ModelProizvoda.StartsWith(search.ModelProizvoda));
            //}

            if (!string.IsNullOrWhiteSpace(search?.NazivModela))
            {
                query = query.Where(x => x.Model.NazivModela.StartsWith(search.NazivModela));
            }

            if (search?.GodisteVozila != null)
            {
                query = query.Where(x => x.Model.Godiste.Godiste_ == search.GodisteVozila);
            }
            if (search?.KategorijaId != null)
            {
                query = query.Where(x => x.KategorijaId == search.KategorijaId);
            }
            if (search.CijenaOpadajuca == true)
            {

                query = query.OrderByDescending(h => h.CijenaSaPopustom);
            }
            if (search.CijenaRastuca == true)
            {
                query = query.OrderBy(h => h.CijenaSaPopustom);
            }


            return query;

        }

        public virtual async Task<PagedResult<CarCareHub.Model.Proizvod>> GetByFirmaAutodijelovaID(int firmaautodijelovaid)
        {
            var query = _dbContext.Proizvods
                .Where(x => x.Vidljivo == true && x.FirmaAutodijelovaID == firmaautodijelovaid);

            PagedResult<CarCareHub.Model.Proizvod> result = new PagedResult<CarCareHub.Model.Proizvod>
            {
                Count = await query.CountAsync() // Broj proizvoda
            };

            var list = await query.ToListAsync(); // Dohvati rezultate

            result.Result = _mapper.Map<List<CarCareHub.Model.Proizvod>>(list); // Mapiranje
            return result;
        }


        public async Task AddInitialProizvodiAsync()
        {
            // Provjera koliko proizvoda već postoji u bazi
            var initialCount = await _dbContext.Proizvods.CountAsync();
            Console.WriteLine($"Broj proizvoda prije dodavanja: {initialCount}");

            byte[] sampleImage = Convert.FromBase64String(
"/9j/4AAQSkZJRgABAQEBLAEsAAD/4QCpRXhpZgAASUkqAAgAAAAEAA4BAgBLAAAAPgAAAJiCAgAIAAAAiQAAABoBBQABAAAAkQAAABsBBQABAAAAmQAAAAAAAABPcGVuZWQgYmxhbmsgY2FyZGJvYXJkIGJveCBpc29sYXRlZCBvbiB3aGl0ZSBiYWNrZ3JvdW5kIHdpdGggY2xpcHBpbmcgcGF0aC5reW9zaGlubywBAAABAAAALAEAAAEAAAD/4QXaaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCI/Pgo8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIj4KCTxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CgkJPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczpJcHRjNHhtcENvcmU9Imh0dHA6Ly9pcHRjLm9yZy9zdGQvSXB0YzR4bXBDb3JlLzEuMC94bWxucy8iICAgeG1sbnM6R2V0dHlJbWFnZXNHSUZUPSJodHRwOi8veG1wLmdldHR5aW1hZ2VzLmNvbS9naWZ0LzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGx1cz0iaHR0cDovL25zLnVzZXBsdXMub3JnL2xkZi94bXAvMS4wLyIgIHhtbG5zOmlwdGNFeHQ9Imh0dHA6Ly9pcHRjLm9yZy9zdGQvSXB0YzR4bXBFeHQvMjAwOC0wMi0yOS8iIHhtbG5zOnhtcFJpZ2h0cz0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3JpZ2h0cy8iIGRjOlJpZ2h0cz0ia3lvc2hpbm8iIHBob3Rvc2hvcDpDcmVkaXQ9IkdldHR5IEltYWdlcy9pU3RvY2twaG90byIgR2V0dHlJbWFnZXNHSUZUOkFzc2V0SUQ9IjUyMDYxOTM5NiIgeG1wUmlnaHRzOldlYlN0YXRlbWVudD0iaHR0cHM6Ly93d3cuaXN0b2NrcGhvdG8uY29tL2xlZ2FsL2xpY2Vuc2UtYWdyZWVtZW50P3V0bV9tZWRpdW09b3JnYW5pYyZhbXA7dXRtX3NvdXJjZT1nb29nbGUmYW1wO3V0bV9jYW1wYWlnbj1pcHRjdXJsIiBwbHVzOkRhdGFNaW5pbmc9Imh0dHA6Ly9ucy51c2VwbHVzLm9yZy9sZGYvdm9jYWIvRE1JLVBST0hJQklURUQtRVhDRVBUU0VBUkNIRU5HSU5FSU5ERVhJTkciID4KPGRjOmNyZWF0b3I+PHJkZjpTZXE+PHJkZjpsaT5reW9zaGlubzwvcmRmOmxpPjwvcmRmOlNlcT48L2RjOmNyZWF0b3I+PGRjOmRlc2NyaXB0aW9uPjxyZGY6QWx0PjxyZGY6bGkgeG1sOmxhbmc9IngtZGVmYXVsdCI+T3BlbmVkIGJsYW5rIGNhcmRib2FyZCBib3ggaXNvbGF0ZWQgb24gd2hpdGUgYmFja2dyb3VuZCB3aXRoIGNsaXBwaW5nIHBhdGguPC9yZGY6bGk+PC9yZGY6QWx0PjwvZGM6ZGVzY3JpcHRpb24+CjxwbHVzOkxpY2Vuc29yPjxyZGY6U2VxPjxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPjxwbHVzOkxpY2Vuc29yVVJMPmh0dHBzOi8vd3d3LmlzdG9ja3Bob3RvLmNvbS9waG90by9saWNlbnNlLWdtNTIwNjE5Mzk2LT91dG1fbWVkaXVtPW9yZ2FuaWMmYW1wO3V0bV9zb3VyY2U9Z29vZ2xlJmFtcDt1dG1fY2FtcGFpZ249aXB0Y3VybDwvcGx1czpMaWNlbnNvclVSTD48L3JkZjpsaT48L3JkZjpTZXE+PC9wbHVzOkxpY2Vuc29yPgoJCTwvcmRmOkRlc2NyaXB0aW9uPgoJPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KPD94cGFja2V0IGVuZD0idyI/Pgr/7QCkUGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAIccAlAACGt5b3NoaW5vHAJ4AEtPcGVuZWQgYmxhbmsgY2FyZGJvYXJkIGJveCBpc29sYXRlZCBvbiB3aGl0ZSBiYWNrZ3JvdW5kIHdpdGggY2xpcHBpbmcgcGF0aC4cAnQACGt5b3NoaW5vHAJuABhHZXR0eSBJbWFnZXMvaVN0b2NrcGhvdG8A/9sAQwAKBwcIBwYKCAgICwoKCw4YEA4NDQ4dFRYRGCMfJSQiHyIhJis3LyYpNCkhIjBBMTQ5Oz4+PiUuRElDPEg3PT47/9sAQwEKCwsODQ4cEBAcOygiKDs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7/8IAEQgBowJkAwERAAIRAQMRAf/EABoAAQEAAwEBAAAAAAAAAAAAAAABAgMEBQb/xAAYAQEBAQEBAAAAAAAAAAAAAAAAAQIDBP/aAAwDAQACEAMQAAAB+zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMIwl3agAAAAA1Y1z892qloVLVLZS2ZVUtAAAAAAAAAAAAAAAAAAAAAYxql051rzdWbqmsIp6Xfl17yAAAAB53m76OewAAAAAAqlspbLVS1UtZWZWZanTvAAAAAAAAAAAGEas61Zuqa05urNxlpAUFSLbPV78ujeQAAANeb5fk9IpCgAAAAEAAAIAKhv68/T78QAPOl86X6HWaAAAAAcmNcvPerN151gUAAoKAAUJa9b0cd2oAAAODz9ubl0oAKQAAAAAAgAAIDu9Xn695Go8jOuFeg9m56bAAAAABol8Xzd0oqFJQpAKAAAUz1PW9HHZYAAMJfL8fpAFAAAAAAIAAACAmp7Hr83FL5UvPL2Vur1LjaAAAAAADkzryPN3sClApCqEAFIADbrPr+jjlQAHFw68nHrQUAAAAAAAAAAgMa4+vPHpgdVZG6z0bnYAAAAAAADgxvzPP2ygUAoAFEAAAHRvPq9+NoCR5Xk9MlFAAAAAAAAAAAMDzO3Pr642GRlW5PQucwAAAAAAAAeVy6cfDrQUAFICigBEAp1dMen35UHLx6cXDsKAAAAACggAAABgeV25+j1xkUzranfc5gAAAAAAAAEPF4dtPLdBQAAAUlACAqd/Xn6HbnDzPJ6cM0UAoAABACkKQAoIYnk9ufpdcZFM63J3XOQAAAAAAAAABjHhcO+PPVBQAAAAKgEQHqd+O2uDzdxQAUAAAAAAhQAYHmdsd/XnkZGdbk7bnIAAAAAAAAAAA1R4Xm9FzaAUAAAAGJFwNMupfU1jLGqUJapQAAAAAAADE8/rjr7c8ymytqdtzkAAAAAAAAAAAAcub43m9GUCgAAAEXA55dC6pcDA77PQkyKDIAFqoKCgAyAAMTk6Yz7c9lZGdbk7bnIAAAAAAAAAAAAA4ca8vzd6UAAhF1nNLpNMoxWEMDts9GM0oKUFAKUFFUAFKkOPrjb1xmmVbDbZ33OQAAAAAAAAAAAAAB5vPfn+ftQRcTXHMaV0iWEqCUDE6rPRjYZIKUAoAAKACghz9cZ9eedZJqXzc31dZ9/eAAAAAAAAAAAAAAAPJ49eDj11RzGldQMTEBaAJRjXSnoRsMimSAUFAKAAADR0w64ysHnZvLLtr3t8/b3kAAAAAAAAAAAAADCXDN1Y15nLryy4Gk0mk0ywpQoAGJ0J3zWxMymSCgpSFAKAAaumMOmLXHHJLkZmVnvbx7G8gAAAAAAAAAADGMJrDN1y4Z1IxlkoFAKU1mk0rqjUal0xpXRLlZ6GdbEzMjIqFqCgFKACmveNHXPMccvVJhVLWSe90x62sgAAAAAAAAAao8/O9edZZu+AJKIqAKUWACgAAtVMJda4S4xiuMYmMuJJRUKSlBTXvPB0xyLYtdSYChmnvdMeprIAAAAAAAAAAGuOeXkWSyMZdebhNZRvOgyAAABQABSBAAQAGMuJjLiYy4muXj1nzd5hnWRkdLOtZVTI9/pj0tZAAAAAAAAAAAAAAAwjxvP386WmVmRtMrNi743lAAAAIAAAQpAcFnlrxy5WDIzqlToTWqqlr6HfPv1AAAAAAAAAAAAAAAB5Pm78ON64xMSFRWqzCthnZurcmJvOiXeQAgAAMTyrPKXDOgNes76zMkFOlNVClr6LfPt1AAAAAAAAAAAAAAAB5fn7cPPpgYxiQhCAhADOzCtVmNbkyramwpvOiXA8yuDNs0ICJp3noM6qUp02aSlFfR9OfXYAAAAAAAAAAAAAAAPN8/bh59MDEhIhCAhARCxBAsJQyTGoajKWAgpEs5956ayKlMjos0lLQ+l6c+iwAAAAAAAAAAAAAAAefw68HLriQxJCpEBCEAICJCAGIWVCAgICJy9M9RlZSlMhWSKp9N05bqAAAAAAAAAAAAAAAHDx6+fx6wxBCEBCEECAhARIpIQgIShACHH0z1VklKUtVKWh9T15ZgAAAAAAAAAAAAAAA4uPTz+PaEICAhCAEBBEBiCAhEEIQVAYnH0z1GVgyBlQyS1D6vryoAAAAAAAAAAAAAAAOTl087h2gIQEAICAhAQEhUJAhEgIQAwrh6Z6jKqVKUVkgV9Z15AAAAAAAAAAAAAAAAcvPfnebvBUAICAgBAQEICEgQEIkUkBief1z1FqlKgtZIMq+q68gAAAAAAAAAAAABAAU5+e/M83cQAEABKEABCEBIUMYVCQBELhZ53SdSC1QVKWhss+p68gAAAAAAAABAAAAAADTjXmeX0QAEABACFJSIKgBAQhAQRC1rTzuk3pSgoqpRW2z6nryhQQoAAAAAIAAAAAAADXnXleX0IAEAAIAAQAlQAgICAgBrPM6Z3pSgG2zWoqb7Pp+3IAAAAACgAgAAAAAAAMM3yfJ6QAABAAACAgAICUBCAQrWeXvO6qlWG2zNNEqidNn0/bkICgAAAAAEBQAAAAAAYy+T4/SAABAAACAAgBACAlAAajy9521QDamVmiUSuy5+l7cgAAAAAAAAKAAAAAAAeP4vUAAABAAACAAAgIAQUEaq8vedlUA2JU0KIdus/S9uQAAAAAAAhkCgAAAAAAHkeP1SAKQAAAgAABAAQAgBCmo8vpnYCA2WU51iYnp7x9F15gAAAAAACGYKAAAAAAAeT5PTjmgAAAAARakAABACAAhTSeZ0zkUhDZZDnXE1XPu9ufs3OZkAUEKAAAAZAoAAAAAAB5Xk9OGaAAAACkAAAikAEABAU0Hm9M0EIZpic1uq59Drj2Lnss2GRSlBQAAAAZAoAAAAAAB5nl9GrGgAAAAUhSAoIIAAQAAGg87pkDExMkwOXU7OuPUs7U32ZmRkUFBQAAADIoAAAAAAAPN83o0Y1YAKQFIUAEBQQAQAAEAOevP3kQwXFKadZ39ceinXZ0m2zMyKUFBQAAUgMigAAAAAAA0Y1y43pxrVnWeaUUAAAAAIUCFQQAEKc1cO84mJrXBMbOnrz7rOqzoNtbEzMgUoKAAUAApQAAAAAAACAGiXVjWnOtWN6s62ZFpAUAAAAIIAADlrj3nWuBqTTqdvTn6FnTZvNtbEyMilKCgAoAABkAAAAAAAACAAAEOXN1Z1rxvVnWGNbJRSAFABAVIFIOSuPU11qNGs9XTn6NnXZ0GyzYZGRSgoABQAAAZAAAAAAAAAEAAAAAIcubqxvVnWrGpnWyWAAAAAJx1ybzpXmuerrz9Ozrs6DZZmUyBSgAoAAAABkAAAAAAAAACAAAAAAAGBz51qxrVjerOmLkoEKCJyVybzxWdPXn69nZZuszMilBQAUAAAAAAyAAAAAAAAAIAAAAAAAAAAapefN143qzrVjWWbVJx15nTHT25+5c9VmZSgFAKAAAAAAADIAAAAAAAAAAgAAAAAAAAAAANEurGtedccuzrz9TWcgACgAAAAAAAAAGQAAAAAAAAAAAAAIAAAAAAAAAAAQAAAAAoAAAAAIAZAAAAAAAAAAAAAAhQCAAAAAFBAAAAAAAAAAAAAAAQH/xAAtEAABAwIDCAICAgMAAAAAAAABAAIDBBESE0AQICEwMTIzUAUUNEEiYCNwgP/aAAgBAQABBQL/AKXLgEJWE8x78Az1nrPCzws9qzmrOYs1izWLMYsbVcK/rCQEZowjUtX2SjNIUXOO2GXFzJXYn8+5WJyxuWY9Zr1nPWc9Z7lnlfYX2AhM0nTlwCz4wjUtRqXIzyFFzjyopMY5L3YW6uFt5d2WugjRqaqVw6cuWbLJqXrOkKLidACQY34xyJnXdq6cf49j5GRh/wAjcuE06jgAMUIj5ssYlbxDtE1xaWOD27zjhGrtddBNVwwJ1ZUSkU93BqawuLGBg508OaNGx5YQQ4bs7tWSGj7rGudJVTpkDGIBWTWlxa0MGgqIS5A30ccmA9dzoCbnUuc2Nn8qotYG7LbGsLi1oaNFUQ2Ojhlw7kzuGpe9sbAHVT7bLbGtuWtDRpJ48l2jgl2vOJ2oe9sbAH1T7bjW3IAaNKQHB8Zgdo4JcSldZuoc4MbhNS+241tyBYad7BIyxY7n3WJGQBZ5CbUZ7bq6xLEFcLhoiQ0OY6Z+41t0BYamaESt48y6xIzNRlcUSTsceFKf43V1dXV9nDbxXFXKuVdYgsQVxvEhouXkbjW3QFhq6iHGAb8i6L0Z2oyvK6q6vtPSm6cm6urq6urq6uuC4bS7CCXPfuMs54FhraiFA323WJGQBGcIyPOy6ur7p6UyGkLsIuXEbXzMiD6mWRfGNDfQTwYXXTpAEZ0XvK4K6vyT0ptJew6nYXBodUuesPFfHdutxBZgRlKfA2Q/RajRPRo5kaWcIxShHhyT0p9I47OidUXTmklW2fHdmouAswLMWNyvyzGxyNNAUaGAo/Hxo/HFH4+VGiqAjTzhOa5qpyhonG2x9Q1qdjegA1O3Pj/DpZHFjXVtl96EoVEJ1BAKyo1kRr67F9dZBWU9Zb1Y8rMFnzNYi6SVABuyyPXb8f8Aj6d0bHI0kBJ+Mp19CxNNVgFla05lUF9xrR92BCeEoWOpwtWWxZTVkhZKynJwLFUvwxl0j0Ghu6eu2h/H1+Ft5o4xIYIrYcJEk4X2Kpo+1KD94IV1MU2eF6H8tLLWwRGSsnkPc8SOc/rvHrtovxvQVHkO5ZXIVzYta5ZUVwCFmVIb9mpaftyBw+RiX3aZCaJx5TiGiT5BqkfPOgLbY939o9dn6pPxfQVHk5uNwQ4DLjyzExC7XCWqCFTV3FbJYfIwECupSWzRPMlRDGH1z3IgvO6xDc/aPXZ+qb8b0FR36XE5Xu08ThF9+NDcHVHb+oPB6Cp6689I0NwcN09IvD6Co9AekfQck9GdnoKjprz0j7eSenoajs17ukfb6ufx693bH28kd3oZvFr3drOzks8noZfFr39kfZyYvN6GTx69/ZH4921htg8/oX9mvk7GePcYj02035PoXduvk8bPHuMTum2k/K/oMnjZ4txid27aP8r+gy+Jni3GJ3bsuqAXn9E7u10vib49xnR3RXVyTSMywD6J/frpvE3s3G9HdLokkwxWTAh6KTya6bxDt3B0eeB4mOOyYE1D0Uvk10/h/W4DwebqOOya1NCHo3xB6MD0WSBYgF11dR4Nwq/Bkdk1qAQHqDBE5GmCMEoREjVmM09T+OdhRRPGNlk1qAQCt6wgFGlhK+qjDMEcxqzG6Kp8B4bCieMcdk1iDUArK3sSAUaaIo0pRinCuQg9p5tT4HdSnHjFFZMYg1AKyt7dzGuRpYkaZyMcwROFBzXcip8Mnc93GGFMiQYrK3vnRRvX1Y0aeQIslCLgEOO2o4MkdZQUxKZDZBqt/RXQxOX1mrIep6aaRsNA1iDQP9a//8QAJhEAAQMDAwUBAAMAAAAAAAAAAQACERJAUBMwMQMQICFgQTJwgP/aAAgBAwEBPwH/AExB3WiVprTWmtMrTK0yqCqHKgqkqkqMdSVQqFSFHdzY3GCBYQoCpCpCoCoCoC0wtMLTWmiwi5pKoKoVIUbREbTRJvOofKFG61sqgKkKLEiNlg9TeOMnwjvO6DCBmzIlER5gTeEwO0KLNpi0Inz6Y/bx3terZrotCJ8gIuyblrrRzZ8OmP27Ju2utHN/e4EC6JvWum0c2EwSbom+BhAzZQoQbTck4AGN+L0nBNdGKJwjXYgnxhOwDXYYnwju6+hUoM7SpUqdwWhOw66pKpVI3ZUqpVKpSFI7CzJ2XW8BRdSVJVSqUqVO2TtOuZKqVSqVSlTeypUqVKkI7bucC3hQoUL3dSoKjcdzgWcbEKFChe7GlRvHnA9PjfhQoUKCvfefCLE84Hp8W8KAoszgenjDgen8b0/jenz8b0+fjWc/Gs5xZwTecWeME3nDHxPGCHOGPi7j413HxrsGOMSSjg28YgnCt4w5MYZn8cMTGHDiFqKsKRgicZJVZWoqwpF4TGSkqsrUVYU2xMZioqsrUVQsSYz1RWotQKobZMfByqytRVhSPAomPiZKrK1EXhE/1t//xAAnEQABAwMDBQEBAAMAAAAAAAABAAIREkBQEzAxAxAgIWAyQVFwgP/aAAgBAgEBPwH/AKYqG651IWqtVaq1QtULUC1GrUaq2qtqqCkY6oLUC1FWVJ7tdO51DJsJKqKqKrcq3LUctQrUK1StVaoQeDcSq2rUC1FWVJ2munacYF50x/fOd1zoWoVWVJsAUDOz1D7i8YIHhNgRKIizBhAz5kwLxok9pU2bhKPqzaYQ9+XVP8vGCF7UWrmzaNdHkTJm7a25e3+2jHR4dQ+ou2tu3ttGO/ndxk3TW3r2xaMdPpdQwLprb4+04RZynOqNy1uAIlERi2twTmzimjCPbOIa3wlSm4B7f7hmjwnu2+kKsIv7QoUKNw2gHefFt1UFWqip3IUKFSqVBUHsbMDZbxbyVJuoUBUqlUqFG2BtN4uYCpVCoVCpUKFF3ChQqVCgpo228YF5gqoqpSF67Qot4XpShtjjA9T9ecqoqpVKQvShQo3Y/wAqQp3hxgepzvyVUVWqgpC9KFCg+FViOMD1ObeSpKk2YwPV+N6vxvV4+N6nHxvU4+N6n5xYwT/zixzgnfnFjnBO4xbecEeMW3n41vPxrRgzziQJQwbucQBOFf8ArDgThn/rDAThywFaS0yqTggJxkBabVpLTKg3gE5KAtMLSWmVBtgJzFIWmFpKgqN0dwJz1IWmFpFUHZHYCfhKAtMLTKpPgOUBPxMBUNWkh0zKA/1t/8QAPRAAAQIDAwkGBAQFBQAAAAAAAQACESExAxJxICIwMkBBUFGBEBNhcpGhBCMzUkJgYoIUJLHB4XCAktHw/9oACAEBAAY/Av8AcvMgKF7SxWr7rVWqqFUK39lVVawWsFXhsytZSBUmhVU3Htga6TDYKlaxWsVrKvZuVAqBaqoVCc9omQFrKQKk0Kq1j66Lx0Udsj9uVC9fdybNAMHd8hVT0kIRKoAtZTcdgiF46GHLbL33T7YvcGjxKhYWZf8AqMgvnWkvtEgoMbNc3c9LD0Ra7WGxxCiMuO2QFTJQUHOi77RVfKaLNvMzKv2ri93MqUgoCqlp4jWFCpiBFRscVEZV3a4uIAG8oFjHWnss53dN5NUh2wCgNhvs1h77J4ZUdqL3mDRUq+8XbP8AC3+6kMmA2PvWfuGyQNMi7z2oveYNG9C0tBdsxqM/7yYKA2WI1He2yXD07Y7SXvMGhd5aC7ZjUZlS2aBEQrv4TqnZLpqoc9pLnGACv2kmN1W/+37cWuVx9f67FVRar8IeCoqKh7KquxRNEHPk0UbwD9QoVAycK6aqkPVTOip2VKqty3KioVv7K5UTRRMoU8OBXm6499HKeC5KZJ2inZUqqiXSUXShQcv85N28Ijdt/eMrvHNRyaqU1yU57dEmSvGXIcv85EXmCzPlt571aQ8OAd4yh1h2VWaCVWGC58AmonoOXbFxgFCxEB9xUTnO5nsft1eyQVXN8qk89QpWg9F+E9V9P3U7N/opy4DCyF7x3KNo68ch+O100s2NPRfSHRUcOqk96la+rVJzCtSOBX0neim1wxGyePZBuc7wUbQ/tCgMl3m2aIYXeAWdZWrB4sX1IYgqVqz12iYBWo30Wr7qpWt7KoW5aqodFmmKmYnkp5jeSkMs+baM5gOIRPdCaF28yG8FZnxFq1vKKzfiQT4skpCyf/ZQd8LGG8FA2llasB3kLOJbi1fVZ6qRBw2nVC1VvVStZblnS6qBvT5KAzG+CloevAIwEU8CzbOskINuw3tM1mWloxsKAo/zGALUCRYv/SJKB+HveLHSUDY2l4VA3L6nWCzbVh6qU8Nlul9532smsz5TfVyvOmfFPLjGGjbwepUKjkUIsbmmIgIf0WqQIarTAL69sBuANFH+JBdyuyKm2ztAdwkQrrvhXR/SYhEOZaBwq2FEPmTJhCCgLVhPm0cXEAcyrti3vDzMgFC1tcz7WiCl2uxyeuUzgPTTax9UYNbOuarndgCkqqLL1m7e4GazPiLVrd4M1AfENcIVcN6IDLJ0N8aqP8K6EYE06oG7aXT+KElDvYSjMQUG2rSRuipvGAXyWXfFyvWji45Rx0bMOAjDZtY+qumBHKCiQKx1VGE9AcdGzy8BbwE46NnlHAW8B66MYcBHAep4YMeA9TwzrwArqdE3HgR4AV1OiZ5uBHgBXU6JnmHAjwAoddEzHgTsOAFDJOSzgR4AU3DJOSz8hOVnhknJb1/ITkzDJOTH7RwM47e5MwyTjkQbXghx29yZhoICvBTt7k3DLgK8GO3uQwyoCvB4xIKk5pxkp2Z6TU83zCCltbkMBkwFV48L+mOizXuHupFjvZTsndJqboYy2d2TAV4jMRWpDyyWbauGM1+B3ss6yd0mqwxlsTlDtgKrx4tMRWrd8slm2p/cIrVa7AwWdZvb0UnDSntgKrx45nNBxUgW+UrNtf8AkFqB3lKzmvbiFJwOg6oqAqvH8hZzGnos0ubgVK0B8zVOzj5Ss6LfMIKRj2jEKA1lE/kidmFmve3rFSeDiEGtDa81etHXnf6bf//EAC0QAAIBAgMHBQEBAQADAAAAAAABESExEEFRIEBhcYGhsTBQkcHw0fHhYHCA/9oACAEBAAE/If8A6X7mjIDRt+raUvJYb9ScZ84d/gn7I4j+D908SH+oT2T5Iar2yzC5suC9KiN0NthzcmSVyRdR1xgz09/UpGVHqxhL1I7fIf7pGHGH7pHEXwfosY7i7xZpLtCUKd47njHqnJGbZkhzcmgeSLo/0SbTlOGhMTtv6U3my3zhZZ6un9+dpjD8NwFs5OhU+rJQonOPUShZnQbsJ3z9Ei5Dm9wU2Q0Jnsl16MQtrue+Rcb8Mu2PG/0Rzbn+oX/b/wCBn1FRH6Cubl/VSlR5tBpZRc48dzW73k/Iltpa2Q225d3vbZc5gJJCKErDb5Yh6WkD/gu4/jEksUlT9hAWdWhG7s3r66E0DE5lWBobnG1s1qLLpT2qiTm97YbxmQkJiYpikJtMs8Wu+ruQ0BR0KuXkzWZvTcsnxtaBCyv83N+u90JpE05T2G0xuyGPbPeliVZYKpaL9+bj4ksXzIEI/akAV83pugiaRM2M+ImmpVVuUkmavtsRKnNvSIKsth+Zmft4vAhAhEjIn+bsA12PluckEN5sZX4bygCrLbFN9mp5fHwL4IQkJDYl/hGN2Pc4uiWq9I4bnJDnps9Tjajec/smQ0jU6fF6+AtChLBISGxL50FxLeF5SmNra2ej12NBoX4OimmqyxymV7VE9Hyc8gHM+DhidD5wjcHl8IMZya7c+Pi2ollkrLCBIa8L50ERLetJgJya7BPTkYapC2p8DJAXRfIlKyJHKtCv2QlaIjQKcfkkJ/xJ1/A4I/V4bgfA4vY4Io80QQRg8vhMxwPoPy/gThCQhISHv9iIlvmTYIloautNuRqIV3BrjCwJd46iIKygYnC+PX0ExE4ySSTtA5iRyHIOQ6HUl6xbVkl5R+Fnv+QJCEIl1gpcqpCIlv08op6AQkLbBi8IuZlr5TO0vyOHVm3Etwy2bw1GMJk4T6skkiGxkuyHnh/3flBIphJEDoWbKDL5H+CzObk3d39gaxP4ZGojqiJf4hfVXQXTdqxlmX6FwajExMTJ252pxaMbQkN0i34cfAsI/EZsngmlUpsuCUi/Kvvfmm6DXaWZIQ8Os1JHHWshmDzZCdul/RmR8kZZV1kmobcUStfQuD3ExMTJ2J9Oc2VK3Vlp/wBJJSNtwlmyU5jXYJbmlkirUZaCCErbzdw0hp1Y9Ibs4Gzu2/SlncuVl17LwWDkf7MgucMyG/xqI+Ua+jIHIl16cvAmdszEKl1GExMknZnGdqevxEyx30oRXTq1gSAlVyIMxIWt+UW7NLmuaxCtoDcu1BmXlaFNJpQRpwnaVQq2h8t2l6ncQQ2fVAfDcmHkJ6jTJ+oabE1ZN1IMw13V0JgnCdppRod2iqQ66Sqy8eAuxVEQ1KYvIURhmdw8LeGKcHapAzkt0UIKIyyrvMVJxRqizrMyMjqaEpClGbdargJORJo3rHIfKFZvQhmXSmHTHQh0pm4ScXOlRu7CSHpu97jZdnQbMhy3U0SbZJ8D1G6iVOMnClKiJxJxTV8JyEFBdIFuS9WXEhqhnhq+Gosc7+wN0jtUCwFZS1lFweEQqLCkyBll23MoZMqE6S5Wjf2LWUZW+W4KdHcxI6tBStfBGTqIlpkmm5PFOJRGl4vGSS6TVpI3OBncTkSIRDTVTrZDzSa7tsc4pJTkS7hISwgWGhIyYkcZvz7ClfJCDRBAxChI5Mnd3JdEpmVWZhVshezTJ9Sc/wCDxxNrti9RUw01/McfoEobIVXiMxJHDzDnI4xSShBU6ho/y+UJkKaga+ncVGpZJJZDalVI9GH1ZkCLbYinOgY+olYSCDMSrzdF2EJUxycnkWKrmY8zy/YbRY0QQQQQQQQQQQKyNBRFZCKRvhjKpQV7sfeVao0F2g22Pgq0gY89H7LZFiVQ8OPOgzYUg3Dkat/CNYluhCHFalAtCTEh8R9eyGlSJU+9WWTagdb+eTnUpkJKFRLIgggaP35CbCs5isXMEO4WPYUtQMZBBBBBBBBBBBBBBBBBApTo45Deob1ow2RAXRkgaBi1A4X1Et1XNOEEEEEDRZ+7bKzzLJyVN4Idwkct7CnwMaGRhBBGEEEEEEEEEEEEEEYQQRjBGCDyCzYqJjrfFF0WEfiPYfuHjA0QQQQQQQQQQQQQQQQQQQQRhBBBAlRc5izYWCwRfEhOiewrX4j2IIwggggggggggggggggggimEEEEF7lgytsoRljqij2UIwjCCCCCCCCCMIIwjCCCCKEEEEECV8sMVvRdV19ukEEEEEYQRhBBBBBBBBBB2mGZC20Vo1Tz7F4nrRjGEEEEEEEEYQQQQL8QtGAvQrVwefYqxe5wRhBBBGEYQQJ8IlL/Ei9rZ2u6xsQRhBBBB2onyeQti7K1ur8bFXL+xd83ONmNiMIw7M83yLY+gv4ZElXN+vYklfB73Gynwi9f7bP0F3Yq6nh+xXRlv/bH4eL2foGqJJJKuD9PY3ePVz3LsD8fF7NvMPUSTgkpqPJ7HQji3/tBYTw+doHrGxh/4EK5m7vBkn2DuW/8AYHZdhl/mOWEC+7Cfs9SNYF7D3u55ep2x2fFjY/fgWeYux17uyETAheweP43+nli7bFsbwLWVZiLq3dkWIQvYXXMSF+1n/RcXxdf9DerfMeQqJqXD1s/V7Edl08QxjYxNpVYXVdrvYcSEL2V1Ll1SH2Psn9juiJ/0d0kUIHEnRfsKqlVXDduxK30XgYwwx3DC145vYNQSEiPaUMITih3MX1/gN18dE2d/L/Ylh8YJ2KsNW0/sZbj24kuCgxhzuGOea72KUEEiPb0sKTihtKm1Z+Ajb8ED8rHMfy+qXYZxK0mpHq2+ONd0xzDXZDjqCEe7I45Gk8iVCOfwl8QXXpnsz8teaO0QyHpt3lqgyp6sZm2GXu12RKxEIoQR753nQ/5G/DPhv+xHd0t+YGdHPO4ZLKk1TIeDSn+mMa82Rnw3diVsJWCCP/A2szdUofyP9gdZGvwYSkUW26KMe1FfQS0RBH/rP//aAAwDAQACAAMAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH4AAAAAC8ZnuO4YAAAAAAAAAAAAAAAAAAAAAdh8poAAAAAT3f/wD+33NdZ54TAAAAAAAAAAAB0xKFMM9cAAAAC+q20022/wDvt/8ANQAATAAAAAAp6pptMAEif4AAAH7dokst/wD+3/8Atv8AAmpwAAAAAEghFIJpNskQgAAERtIMAJbLf/8A+32Rr3CAAAAAABNtkpoCbTZN2AAPTSbabDSSz223/YusaAAAAAAAAIklkkhbaSYEAHTSbbbbbLaaTy2nWoSAAAAAAAABWslstkIBaRYAzSbbbbbSbbbbfuVp6AAAAAAAAAJus3ltspIJCxJaTSSSTbTTbSam1oyAAAAAAAAAAGO+2+0klJEt7abaSSSSSSaSbhdgiAAAAAAAAAAAPu/22232+rRdl7ZJSTCSSSbkVgiAAAAAAAAAAAAPr2//AP8A6iiShJqC0NNJNWSSf2mgAAAAAAAAAAAAAL7bb4mP+S0TtpptbygkgPgdRgAAAAAAAAAAAAAArLk/lyN2SmTPJJJvpJpfCDgwAAAAAAAAAAAAAAAwfEJtktyGe2f/AO322Ta9oW5wAAAAAAAAAAAAABGxtKVuQASWus//AN9/t/8ArTNXYAAAAAAAAAAAHCoPxpWyTmo9V3+Tz/8A2/8AvyRVjkAAAAAAAAAAOBbnOJbIk0l/YHSMI6pNfvvWKSCMAAAAAAAAAAABsQ3r0kkm3tJIJck22oooorSA6HgAAAAAAAAAAAAAAAdVVZjb/bbJ2kkmm2y3IA/B1gAAAAAAAAAAAAAAAaZZM8rh/wCXJtpJJktUBtVPrAAAAAAAAAAAAAAAAsmSWy2SIsMPpKmAAcwpkrcgAAAAAAAAAAAAAAAHEgSWSS676QnAqywRIlKxYiAAAAAAAAAAAAAAAA4gmCSS2ST/AG+hIINOVbeo4GAAAAAAAAAAAAAAAAIIAIJIkltnn/26aSzKb4fAQAAAAAAAAAAAAAAAPZJIBIBBFllku3+baVa+IyQAAAAAAAAAAAAAAABrQaIABAJIEJkv2+3bpC1H4AAAAAAAAAAAAAAAAK8YTTbIIIJBMsl8/wD3SQ+FgAAAAAAAAAAAAACSQLv9v9um0ASDAaTJPGJwQuCAAAAAAAAAASSSSSSSv/v/AP8A93fzQIBIIsKP/wBwuQQCAAAAAASSSSSSSSCtt/8Ab/bfbtooggAEn/fojckkkkkkAAAAAAAEkkf/AP8A9/vttv8Ab7pMkUGlWEYPAkAAAAEkkgAAAAAkgbbbf7fb7b7f77pAEUEiLccAAAAEkkkkAAAAAEkH/wC+2/8A/t/tt99vkeaABfv+QAAAJJJLSAAAAACSQP8Af7b7/fbf/f77f6SWYA/8kAA22ySWkAAAAAEklf8A/wB/tt5/9t/v9vvLNswBCQbJZJJJJSAAAAAASTf/AP8A/wDpttt7tv8A7/eX7f8AOObtlkkltkpAAAAAABI33/8A/wD3TaTf/wC/+/8AOkv9yImJZZLbbbQAAAAAACQVtr8fZb1btv8A7b/89McM9RKSyyW2y2gAAAAAAkjDr2SWiWGDQWb7b7PJj0tcJGyyW2SSUAAAAAAEgEkConymAkASTf8A22TBZSXDZMslskkkgAAAAAAAAJJJIeVFopIkls/m5pBmVTQFktskkkkAAAAAAAAAJJJJJIeiyJttskvLEnUTBIlsklttsgAAAAAAAAAJJJJJJJJQUHksl9WlrQBAtkkttttsAAAAAAAAAJJJJJJJJJJImg/njNZBIJAEttttttgAAAAAAAAABJJJJJJJJJJJJFIiJJAABJJNttttsAAAAAAAAAAAAABJJJJJJJJJJAJJJJJIAAAEkltgAAAAAAAAAAAAAIAJJJJJIBJJAAAAAAAAAAAklt//xAAkEQEAAgEDBQEBAQEBAAAAAAABABExIEBQECEwQVFhcWBwgP/aAAgBAwEBPxD/ANLguIkXXlt1P7n9S32fpP0Or/lPxn5z8Zb5KeMBcQT1Be4D2wOAMHXIMeTuH3YUfU/KfjPzn46PP0n9xX2AW7gFxD5w90D7YH6gD14r354uwbzsBqEwJnzAl+MAYNgglMveGv8ATeXPWrh9wAxFjbyorgCzZgKYip12AIFdjd3D0EwJmYx0Wot+e1BvGzAVERp4EKHdjrRAEvqtRb2NynaVolaAtolCjdKGenehai3s/U7TIM6LHdFrOrWot7W4p2nqdag3K0T26VqLe2FGyANnUzCd8+blalWlYt7hFZCGwqVCKuZUqVKlSpW51qLe6vQbPLXRUroxx4+0qVKlSmd/Buhai3vLFMO/hqVK1OJ689Suvfr2lUdC1v6uzqqV4nEMbfe/ULgCevAet6V5nEMbbe/SofXX13wn1BwPcGiupSUlnicTDar36VDRmbkFxBIfbCABK8VstLy0/iU6X7Sx2izpUroaM9sFw+0AaK2lQ7T9OlafxKyspLPFd2mdJoy3Fp0rT+ZWBlfsBLlkvc2y0vLz+ZWfpHRXFlsIlZXptKjvLlwRlm1RBM9pSOa1nGHRK469pULLly5Z4rlr2JZywBjr71mjNx7RKSs/uL6i2X8lJcuFuIH3q96zRm4HJtqJT5LPUoeD3pdWTwODwPt8eTwPtwPt8RmOeByeB98Zk/3C44LHxbh4LDxeDwWPh776MnBYeHGjNwWDhxoyf4hhnRn4MxwrDOhlVweDhWHWid3B4eFYdKIseDx8Kw6h4TBwBpegz3jwplEPog8Gw7000R78WFhgcPogsE97g0hbjx9wL3AofUFgHZOkfrL5W4B7gWYD3Bvcs8ro133YvNimIF7gvcPZBvcs8DCVot92LL/wAjEAgvcGzBsOjDoF+xZf+GC9wGH0RR2lrL/5r//EACkRAQACAQMEAwEAAAcAAAAAAAEAETFAQVAQITBhIFFxYHCAkbHB0fD/2gAIAQIBAT8Q/wAy6hmCND5e8T8Sn1KfU9DPS9e9k909k9pPZLOMUMxPeOxF7EXi2XriOfJ2X689sA3ntZ757J7up+ueifiH0R2jUIMsQ3jsRexFd4tv4RrvAPvxWzrO8/IoSzjy/TjtEV3imXQINkM34b/RrKE+CNp3YECvKApjunRurIAs+ZIsVW3V0J0QS7iVeelaATAqnRq4gWfLDq4K0SzbLUppatkSu2ju+oN9/goFsRFqgVo6QBjUW9mktU4+FdG+qBWiFq6e5pN11t3UgrRAx/r/ANStWl9mWrNJlMzsv3qQVon/AK/4ga0ApivQ3LgjuRLGX0uXpDvChrzMReW5cvqTfz3O07dKldauWQPrgasRGvDcvwb+S+ly5fXt1Le0tgV2Pga+lZMdvhcvxkc6Ut7HQCux1QRbib+Av7Jcv414nOkz0TsV0uo/XrjrkN4hF2Ilt9S0tKfHlpc7FHR+kz8MdSoZiEfoRkply/DUpKyvRbpeiUkz0mdiLHvrJaiW0WneXL09PrpUn6lpeW+pT4t9hRwJQz1Skp0KioslpaVqaJSVlZ+peeiWN8WUMRQn3Sm507e8ocPRaImdMN7zs9y0FHjxcQW+4FL7kp9dO3vC2Oi0rydhcVYIpz12PHi4H/b81s9071w+xDcJbP1P1FGehTAWdjMfpLv4HiOmDgcWmtnslW8U3+Z5MDgcjgDxuIY4HZwB43gsHAGeNx/vAGf43M+MycFk4Dfx5HBZuLwcFm4vFwWX84Y+ODgu5cMfHD/EHET2eKa74PNxUFcHl4nBUODycA5+bwFdjhc2vI/J1ArscM3bEbMRxEcmsI/FFAoo4tTJFNo/RiMSyacz8XgA7HIrZIrH6MRiWTRGYdb0Cijl1MkXxFbMT2ijJ5curwFFHOUMXyRbEdhiO0RM+DLo6gV2JUr+AQcxXaO0xLETyfDFHUCiiV/DqZIttEbMB3QQr/Db/8QALBABAAIBAgQGAgMBAQEBAAAAAQARITFBEFFhcYGRobHB8CDRQFDhMPFggP/aAAgBAQABPxD/APS/pUBA+iLDT46f9S1wasq4Pfyf4gN399pzPJQ3R7V+5/5z9w3w94N4fHBt326Qfb5ME+Rgmnl4ax9hBWi7v/WeiuE1E+P2S8E9lAH1v0h2d6n6RTAeR/MwRfJdeUoNCX1pNOkDTlh5f3/0uS7bvv8AekrPHvw8J24vCjlKcpQaEo0R2YEwuyh/tYaLxm4Dk8YP1KOf7cpXvd4od3R/1DdXwf3OYniwex4f5mwXZGUrXACl5Yf5Hp6RHKSuo+xBeogHvFON636RLSXYj/YOhLsqvKFGh+Jrwu4bQixNmYig4czmf8ui6hzdp78/wqVKm804MYHFiSvwqVrKjcrnwAlfucPIPI/JY0tm3i6PFuHuiom7bCq7BWcxNAK4Kwejv/0rcVaVB6Z/yINQ6YVPX4gGEdB7E3O+eyg0Kma4d+Pzx6wzx04KmVYyv9hy39f8bFbnUv8APfhU6ysStJUJUqVwqVxeFSvCavFJUSbaQLQItrVTm+ReIHx4qznYB7XrCUANWdbYq2jqHjLJ2AKMcjuurMUoemNPN5RHpOc9Dkf9Vr05HVc5tAa5Nh0+8pcO3A4d5jgTaBs6cKh+KM0NR0HJgrcwjquX56BwuufSK2tLXrCE8fxZpKzwrlK4VwrPCpREnhK6SokTOIcahIal4XwLfCGCAANAjwo6Zrw0PFJfnVVqbM56mKghSRbgMYt0Ohzh8EdKILc6LTrZqaWX1X/dwNZV6PRjJBVgyv1BhDgZ4JNJ34DjhX431ms1Y2xK0Qx+Vi2n+J96cCHb895XDWVw7zWVNuO/BlY4HNCyAc1ZRe+MOxuGBTA6yzzzdtht+khBrJCrTXygFDA8CFY10nNAmTwBhwe7uv8ABpawc6TlPx9sDfW46rcesqE1hwOkrlPty84l3NeFzXhcuDMytPa6nX3hlgWJv+DhUFr0mus77ciHE47Tbh14M0/CpZw34VyjmVKzNqDgA+XkasLLDhjJw7OFlacxuEYDvS3zjb9R0uu0L1izlBP2wYZDG66rzf4aNIpS0cnU+9ATiFjCduGnOGkueMuXfC504bcG+BCHebV38+0143Qzl2H+8alfhUzx2eFeH5VtCpmHWY850mw+Qh06roBllmMyc363Tzc7ZQBgAqjQJoowS5qoMZ05c4e1XV2EBhjd3X+IgiJY6jAot4V9ieOJcvEvEvPXjpLx7zRl8L8Pw2lwi1gnCbdP1wWi2cm1rs24eEr8KlcHr/w1lTvNeGE4cr+xj5XQDVl762uv3/6GczSAAKA0CCsBLP3G5YducLFnd2ErFXN3f4x3g0m8MMqy+r8f+cDqwuZ5S/HheIM6x7kL43NHlGMWHXKTCMm39zGn4W/3r+O0MTrLz+WnDeExwOFHAgdz2u3Q5rsbxxfAURcwx2LA0W5hUAAoDQIGMSzoTR5e8qh32CUb7u6/yCoD8nmT0/n5nf7z4Y6weF9eGk1lhwvhfLgg1xAbwm8vaB5as2UCaqSAgHOFXrfWHPa5QPfwEZzA8JzUd1BHBd2DaL2EC9JblKxPCVKlSr4eE3jN5UOcuXmbgCNWroAGVXAGVmejkJvpkasu0wMNyYAACg0CBtDKbz/7NLlawOHQev8AKqAmZynl9/xNfz+wQmsJfDeP2pfjLnjEBBCXBaCModFmzQE818Ty6cCbUOsrfSV2NAmSCdJmX5zdp4kU1bwmH2MQDpXs5bYvG5yH4iVb3eM2r4pKNR4f5l6b8JGcwoOh7og2nnw2E7Mu7S/Ak3n91dgN1dDeBUBV6r4rsUN10AoKAMEBtORpwKOY58hDh0Hr/MWjAY6OXf7yS3VOp9VM5vh4SwjiKRBAbwNQHNYBRckL9YzindbR5lerjylGg7Jaa3Fu8XOsVdmUB0grYr6Y5w0S2W84K4LnmW5wdy1dIOtIdUrNesNOUzZblL0eUbar4Sun2ZReOycNjx6YD8bX6dXYDLABcl5jLzMUdjgyrC6ActouU8kZgCGpmmCjRraHDoPX+cul7F9L+9w3+J5S+sUiAgG8JskN1RLTXRjzZhOzZS31Wd+kxoUHIjlLIvWXLlxeXKj6EXMywtXaXkhA25hrLqXLgy5eal4ltzKVpBSCvWoKX1YcItp916QCtlbu2/P0aDNsAAKDBCHVC9l6vYNWDpr3ZHp+nnGoLYa13L/QXKswbPJ8/aNi5au+sJUjz0ec1KGxb5xM4eY3LOnQi7RZzLl84MuXLzLj8iU9n5mvLpiJSswYOdYMvEuyXOyWMHzlzUzmbTAnhN+ULoC1Y4rF2u7m8/pm4vCDHWpxaI7zQD2P35Rrr0VtxGLpKl6f856aruaU7BUq+YZjza7QA7CMcj0BP3I/R9j2G56L3PYS+s3P25mnZzxedTBcoMe8GcDwlwcy2XLly8R+RKg9PmZmuFoZmxly85gtTDuy5bBgwcS62xL5DBzLnb0YgFADLcqKmzBv5v1XeHVElsxSgOswxuNHsbsoLWxY7BMClDQaShLh0OnxO5yen+/yfXMZpT2D9x/nWbY7Cev43FixJUqVKlQs0WXCKpyWYj7uZJo3vq94nqSb8ov7u7EAPZEPUU0Curo0g5v8tJrH73zQjqVeE8yYaHG3eas6200u0wDvC0uCc5fSXiYcpeZZjgHMvOkvUuDznlKZV6gfV39tdZayKydK7B3ZzMDGHfnFIGMYi5vrMAHf/ZWH3lAvPKd5P+MC8W6x7VoesHMApVFrd6ck12uFOmA0EtGw45dOcuKkMhXQprLTFW33QxEaSvweFSpUqVKlQPwqVxD0R4z0bN95r93Q9kTo/sbzdF2PxKWN2H5mrfvZNG7Q/MdW/an2nqbMlcGUvWXjMPog132g1iXmFsLUDWW1Msig14t3jpnq4sfqj15eMCq13cHVlbx57sXdWOZkOsaTXH7gLCVn70gV9c4a6rfyBMU7QWcy5jnO9rVpo6m3KWJWbJNQGy9u3KUQnVAHMHwqqqEtuSC2y6FxdYdiFxHKYVYal535S6UlosTIUr0b3KWaAAEasKI4XTTO8ABeI+hpaDi335Meu6IMKWlG8mNZtol4fZEtUdyVK4VKlSuFcKlcWMr8c82OFZHJnqpGap4CnzFbos5fvFtB3B/UDqO9IPTssvaMAeJFnGM5mNBmXhvsXLL11o5VcMBqVyH9VM34rMpVrcpPvWZp0r2gautweiCxX3SBZUDK7+8qHmfY+P6DAvKsVrlczsMAtI21vbDAzmpU7Ct2HJ6ciUmx1HVFZVYApKxvcDgvcOWKS6hY5vSMDWhg28oKlHK7YC651AFlqbOgO9c5c7ZwaNNqCFUuzASDtHEjdKMm/M5kaQAFQASxpzSZuFX7QAfEijUSVK/OuFSpX4VKgloF7QPC5q/RrA92dZho5m/ai9ZUMTPrUrUB/Uqxa3HLTbnHVsbB2l4dviBdfdSVfl8MbeL8wZPvKfB8QUHb4Jsfd5WTp8S1cz6v6GpubffKBLyOtj0TJpCgZ1AiYa7I7wbHQnbuBtxqVtd1M834i23hS5A3eyFoBqIAVZ0HFtXi9VlCmgFEXDklDtrTmwV9LlmnNohkMW4gwMaVRZoZBAenOAo2EXFC09bVp3KUUsGzDWVCDh9IBUbUhzC7TD5QqCmlmcxRqJ4TT89Ir1zCHrCK3Df1C1b2oWXC5XQ7ilp09ZhqYvKr3XL4y9naBQmtGibYvffJDiuh7MoGNviBm63+ZWDt8QFiA6GpmGm9vYge3xB6vmJk6Q12F/Qx8p7sN3MDHCNe8yxXA2iPCatJlHZK8oUSsdpoUrSlMsq0WsJagN0ubvMQM7DhioGUFW+7ArJqGEb2GqC86hII8rFEFdwphtq9CJyl1XdrCiuBuvK8gUuGBic2Avs1NLgt3mlMp5hF3xaZSwqpRW3WaVeTnBVk0HQEVFFjuynQRImlI5iimLooc3NB1UJo6tG85mGnY8EK0LVpR634YOkCAMIBQeEdUacFVu8xEVzd6fqYC+R7QMHb4gZ8fmVp2+IfI+8FV5ufvhDl5ffiBj71hz4/qaDpKJ3+bf8AQ96V8l/cMDmKIqMNi6IzhHpjhELwatOI5TE08Y9EcGNyAayN1UWYAtCNdGHKUVYS6QSsW+bM8HpadatcGZbAnIWjziWbxFhUcqZvzHHgxLWhC9xeyDTP2oHtA0gZ+9ILE1p8xRCAH9zMc1+YF/eswfD4Ifp1lR6vof0OQ5h7cAax0FRJ7oxqia4jojhpxHRHV0heWJiXHO46p2TVcbDExjSOWs6jeOETTMpuGreOUq2ZjdYm9XU8CD67SusqB0+4iRcpevUT5ibKtf8AYHM+5hnz+SHT7tB5M6BB6P6Etv70giZiYjhME0aMYcmaOUYYekmo6x5p18DhmOUw2ntmqU/UwNI52zenjHE6RMkfNPpjJhMTphg8fS7EHo+IGv3lKx96wMmd4PvlD3gtIafekF/e8w7U6Hj0/oexmen+TVUqJEjhMpXSOpjD0Rsxhwmqo7puI4aR0bm80cDR01jDhO2ZXGCaRz0nNGOqHP1e0Fr6aQ/Xabz9Q18YbfeU0fek2feUrxf5D75yyusFPIV/Qm35H2YmZUQjh0lTVKjDwOgqOqo0JujDTQidI5TdKxHRnMqZEaTqj6kazJjDYmjBKO+9pmg87rwDWuvzCXDQl4PD4hp96Tavu8GCg5g9f6IWHkH3jEjExwSVcrPRlZlZYhym7rHCMOGlzomBzzE5zdyjhElMxwI5RsuJb6R2fEcljyVFazZpADnP7QXbn7007pk9mE5/ecufEuDz5xY+9IOir+iG+g+4jrxrEqbymVKlQDWPTMrN6k1MrMTM5WJjSPqlqj5p1xsERy0m7FxCRPOa2Pqjo5yrKu79pV1E9ZqTdD76T77z77y8P3nLz96xc+MNPvKDrw+j+iNDt7kFMqeESVEuVKlHKVmonL1lZibSpUR0iSpW3LWUSaupEPGIxHRG8cImkwuJjvNAQp5Sqjn9pqbMGiHL8F++cNZcGorHrep/RCz74kD8ElYuZ4VKiXEoiSsSt5W3CpWI2qoGrK0iTKOGkQsmXSWrPKbOUyqCl2v7QB93N0vKEvM1YSkAyugbyuhV7QOZeIMsfqeX/K/5AsvtUYe0qVKm2JtxqVKlRM8ElViU3MomOsqUcSRMXEmTKs6zV03gZuCsebz6/XNHC8kOk1rpD8mXpLq0KMNB53yUvhcuXL4XLly/yv8Ag9YC9JqDNieMJX4V5SpUrMZvKm8rEqVKxdxMyokSVKxGzKt0gY0iaZlEa3rmZdx9cJtwI8QflS4uIM8zmuXLly5cuXLly5cuXLly/wCClhzKlYdpWJpweCTfgayuHaokqZiTTPGpUrGZWZUTESklW8K5zeesyjVrMTQqXwf27zyr5I+SMEeEl6/xuXLl8Lly5cuXLl/whS5FJpwqes1ZtngEx4cO02lRtMypW03hKvgkTlK1lKVEqV0gYgSpjgk0PLhr4LFl6D0/2AfXeNBiZQmP9Ni5XAo85cuXL43L/G5f8XsIPWGZ3nWO81ZrwuM7SskI6w0njExw3lXE4VwqOhHWVy1gVn5iSph9GsuQqvWSejLxwYsWlv8AAlX23mrKjWHytaroeb+oTi3XHLLiF+C/5+B/S4Zj0mjfDv8AhvxNNIw49ZWtkSPSVKxGVKx0m/Gpt1m6+rgTc/czlFixRV1H7Ez+57yq8wEb1HYc2EmqraaqVQR0axwYMGX/ADRQ90OO/wCHWe07Tvw3rg8GazMciO8xvNWOrw3m8qVN5i793BqY26qrzXrwYuBmd3sQinUgwr8gc2ENFyJqsMGJQEEHAcD+bh3vYl6zpL6TThfC9eNlzabwqsTlOt8N8zaJbOvDffj1nPE014VFaNSSBGxX4Ri8DBKvGzMGrDYObB7iTdh0olNQ1DBAgcA/mqbDrW33EZ5GKnmfCWdYbM8rPRK8o7ewiMsjnIT0mTpLyy9Js8fbhvw3mm0eJziVrNZReSbRiZ58No6w0jphqRVaqSdazRFrwsMAJkVyM6szg1CasMrEqDEr4ZghwP6FyI5HZik1/wCyozLejJHoX1mYN5M+ZT0l5j830TfpMTOaH6CYTjbqydGXLxh0m+0NJm+FzN5nTiTebTlN5W0uZvh6mR0t3b9sMeGkU6krIKPkORzYAAV5TVlQYmhjhVcUICBA/plHLAkjAq7y/ZPKeA9S/WDNH0U9aTyQn1S/SeDoFeVIZsZHROC6y9vx2l8d7vjvGIGZRFqTyFR0Svwg49gbHVhm3cJuysMSsMSvb8MCAgSpX9Xc5NiT1jy27t9Us6zYB5lPrNhfN15BPWXdAbvXXl8Hmg8jmWNSby5cNZc6Ttx34Y8toiS9VvLBIIHZHLqytbeQm8pGJXWJTtxwgIEqVK/saEzkPuicvdB8rr0mpg2F6rJo5m9ryD3i27oqeoes1D+RrENeC+WsyHA7xXMFmyhPOWtYxecUA2xy6vSCyHMXeUUEDEM2gEIICVKlf2+ZrkcyXzmuf2HR5h6TQN6J809psrP8JZKUx0Q8RXrO5TkRDbgOgBoMlteTq9IxUptTLCJAukCbcapUqVK/vlCL2vkMwzfSir0xp58kfmL7TZijeA8rbqtOcU3PbCrQ4GBK8FSpUqVK/wDhKlSpX/03/9k=");            // Ako nema proizvoda u bazi, dodaj tri početna proizvoda
            if (initialCount == 0)
            {
                var proizvodiInsert = new List<ProizvodiInsert>
        {
            new ProizvodiInsert
            {
                
                Naziv = "Motorna ulja",
                Cijena = 150m,
                Popust = 0,
                Vidljivo = true,
                Opis = "Visokokvalitetna motorna ulja za automobile.",
                KategorijaId = 1, // Pretpostavljamo da KategorijaId 1 odgovara 'Automobilima'
                FirmaAutoDijelovaID = 1, // Pretpostavljamo da FirmaAutodijelovaID 1 postoji
                ModelId = 1, // Model automobila
                ProizvodjacId = 1, // Proizvođač proizvoda
                Slika = sampleImage, // Ako imate sliku, dodajte byte array ovde
                OriginalniBroj = "23442",
                Sifra = "11111"
                
            },
            new ProizvodiInsert
            {
                Naziv = "Kočione pločice",
                 Sifra ="11111",
                 OriginalniBroj = "297346",
                Cijena = 120m,
                Popust = 0,
                Vidljivo = true,
                Opis = "Kočione pločice za kamione.",
                KategorijaId = 2, // Pretpostavljamo da KategorijaId 2 odgovara 'Kamionima'
                FirmaAutoDijelovaID = 1, // Pretpostavljamo da FirmaAutodijelovaID 2 postoji
                ModelId = 2, // Model kamiona
                ProizvodjacId = 2, // Proizvođač proizvoda
                Slika = sampleImage // Ako imate sliku, dodajte byte array ovde
            },
            new ProizvodiInsert
            {
                Naziv = "Filteri za zrak",
                Sifra = "33333",
                OriginalniBroj = "097739439",
                Cijena = 80m,
                Popust = 0,
                Vidljivo = true,
                Opis = "Filteri za zrak za motocikle.",
                KategorijaId = 3, // Pretpostavljamo da KategorijaId 3 odgovara 'Motociklima'
                FirmaAutoDijelovaID = 1, // Pretpostavljamo da FirmaAutodijelovaID 3 postoji
                ModelId = 3, // Model motocikla
                ProizvodjacId = 3, // Proizvođač proizvoda
                Slika = sampleImage // Ako imate sliku, dodajte byte array ovde
            }
        };

                var proizvodiEntities = proizvodiInsert.Select(p =>
                {
                    var entity = _mapper.Map<CarCareHub.Services.Database.Proizvod>(p);
                    entity.StateMachine = "active"; // Postavi početno stanje
                    return entity;
                }).ToList();

                // Dodavanje u bazu
                await _dbContext.Proizvods.AddRangeAsync(proizvodiEntities);
                await _dbContext.SaveChangesAsync();
                Console.WriteLine("Proizvodi su dodani.");

            }

            // Provjera broja proizvoda nakon dodavanja
            var finalCount = await _dbContext.Proizvods.CountAsync();
            Console.WriteLine($"Broj proizvoda nakon dodavanja: {finalCount}");
        }


    }


}
