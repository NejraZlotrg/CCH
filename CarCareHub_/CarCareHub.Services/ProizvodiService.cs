using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, Model.ProizvodiInsert, Model.ProizvodiUpdate>
        , IProizvodiService
    {
        public BaseState _baseState { get; set; }
        public ProizvodiService(BaseState baseState, CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _baseState = baseState;
        }

        public override Task<Model.Proizvod> Insert(Model.ProizvodiInsert insert)
        {
            var state = _baseState.CreateState("initial");
            var pom = insert.Cijena * insert.Popust / 100;
            insert.CijenaSaPopustom = insert.Cijena - pom;
            return state.Insert(insert);
        }

        public override async Task<Model.Proizvod> Update(int id, Model.ProizvodiUpdate update)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            var pom = update.Cijena * update.Popust / 100;
            update.CijenaSaPopustom = update.Cijena - pom;
            return await state.Update(id, update);
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
            if (!string.IsNullOrWhiteSpace(search?.JIB_MBS) && int.TryParse(search.JIB_MBS, out int jibMbsInt))
            {
                query = query.Where(x => x.FirmaAutodijelova.JIB == jibMbsInt || x.FirmaAutodijelova.MBS == jibMbsInt);
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
                query = query.OrderByDescending(h => h.Cijena);
            }
            if (search.CijenaRastuca == true)
            {
                query = query.OrderBy(h => h.Cijena);
            }
            

            return query;

        }


    }


}
