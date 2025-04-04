using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace CarCareHub.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, Model.ProizvodiInsert, Model.ProizvodiUpdate>
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
         
           var query = _dbContext.Proizvods.Where(x => x.StateMachine == "active" && x.Vidljivo==true);
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
            if (!string.IsNullOrWhiteSpace(search?.NazivGrada)) {
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

            if (search?.GodisteVozila!=null)
            {
                query = query.Where(x => x.Model.Godiste.Godiste_ == search.GodisteVozila);
            }
            if (search?.KategorijaId!=null)
            {
                query = query.Where(x => x.KategorijaId==search.KategorijaId);
            }
            if (search.CijenaOpadajuca == true)
            {

                query = query.OrderByDescending(h => h.CijenaSaPopustom) ; 
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


    }


}
